class_name RapidRoomGenerator
extends RefCounted

const ERROR_ORIGIN := "Production/Systems/RapidRoomGenerationSystem/rapid_room_generator.gd"

const KIND_WALL: int = 0
const KIND_FLOOR: int = 1
const KIND_DOOR: int = 2
const AXIS_HORIZONTAL: int = RapidRoomDoorway.Axis.HORIZONTAL
const AXIS_VERTICAL: int = RapidRoomDoorway.Axis.VERTICAL
const NO_AXIS: int = 255
const WALL_EROSION_CHANCE: float = 0.4

const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const OPPOSITE_SIDE := [2, 3, 0, 1]

# Canonical doorway templates traverse from top to bottom.
const DOORWAY_TEMPLATES := [
	["##.", "...", ".##"],
	["#.#", "#.#", "..."],
	["..#", "#.#", "..."],
	["...", "#.#", "..."],
	[".#.", "...", "#.#"],
	[".#.", "..#", "#.."],
	[".#.", ".#.", ".#."],
]


class RoomState:
	extends RefCounted

	var room_id: int
	var panel_count: int = 1
	var door_mask: int = 0

	func _init(requested_room_id: int) -> void:
		room_id = requested_room_id


class BuildState:
	extends RefCounted

	var top_size: int
	var top_room_ids: PackedInt32Array
	var rooms: Array[RoomState]
	var blueprint_size: int
	var kinds: PackedByteArray
	var room_ids: PackedInt32Array
	var door_axes: PackedByteArray


static func make_map(size: int) -> RapidRoomMapData:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return _generate(size, rng)


static func make_seeded_map(size: int, seed: int) -> RapidRoomMapData:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	return _generate(size, rng)


static func _generate(size: int, rng: RandomNumberGenerator) -> RapidRoomMapData:
	if size < 1:
		push_error("%s: size must be at least 1" % ERROR_ORIGIN)
		return null
	var state := _partition_top_layer(size, rng)
	_build_premerge_blueprint(state)
	_merge_same_room_dividers(state)
	if not _author_doorways(state, rng):
		return null
	_add_exterior_ring(state)
	var resolution := _resolve_final_tiles(state, rng)
	var final_cells: PackedInt32Array = resolution.cells
	var doorways: Array[RapidRoomDoorway] = resolution.doorways
	var rooms: Array[RapidRoom] = []
	for room: RoomState in state.rooms:
		rooms.append(RapidRoom.new(room.room_id, room.panel_count))
	return RapidRoomMapData.new(
		final_cells,
		rooms,
		doorways
	)


static func _partition_top_layer(size: int, rng: RandomNumberGenerator) -> BuildState:
	var state := BuildState.new()
	state.top_size = size
	state.top_room_ids = PackedInt32Array()
	state.top_room_ids.resize(size * size)
	state.top_room_ids.fill(-1)
	state.rooms = []
	for seed_y: int in range(size):
		for seed_x: int in range(size):
			var seed_index := seed_y * size + seed_x
			if state.top_room_ids[seed_index] != -1:
				continue
			var room := RoomState.new(state.rooms.size())
			var current := Vector2i(seed_x, seed_y)
			state.top_room_ids[seed_index] = room.room_id
			var allocated_steps := rng.randi_range(0, 3)
			for _step: int in range(allocated_steps):
				var candidates: Array[Vector2i] = []
				for direction: Vector2i in DIRECTIONS:
					var neighbor := current + direction
					if _in_square(neighbor, size) and state.top_room_ids[neighbor.y * size + neighbor.x] == -1:
						candidates.append(neighbor)
				if candidates.is_empty():
					break
				current = candidates[rng.randi_range(0, candidates.size() - 1)]
				state.top_room_ids[current.y * size + current.x] = room.room_id
				room.panel_count += 1
			state.rooms.append(room)
	return state


static func _build_premerge_blueprint(state: BuildState) -> void:
	state.blueprint_size = state.top_size * 4 - 1
	var count := state.blueprint_size * state.blueprint_size
	state.kinds = PackedByteArray()
	state.kinds.resize(count)
	state.kinds.fill(KIND_WALL)
	state.room_ids = PackedInt32Array()
	state.room_ids.resize(count)
	state.room_ids.fill(-1)
	state.door_axes = PackedByteArray()
	state.door_axes.resize(count)
	state.door_axes.fill(NO_AXIS)
	for top_y: int in range(state.top_size):
		for top_x: int in range(state.top_size):
			var room_id := state.top_room_ids[top_y * state.top_size + top_x]
			for local_y: int in range(3):
				for local_x: int in range(3):
					var position := Vector2i(top_x * 4 + local_x, top_y * 4 + local_y)
					var index := _index(position, state.blueprint_size)
					state.kinds[index] = KIND_FLOOR
					state.room_ids[index] = room_id


static func _merge_same_room_dividers(state: BuildState) -> void:
	var replacement_positions: Array[Vector2i] = []
	var replacement_room_ids := PackedInt32Array()
	var size := state.blueprint_size
	for y: int in range(size):
		for x: int in range(size):
			var position := Vector2i(x, y)
			if state.kinds[_index(position, size)] != KIND_WALL:
				continue
			var is_vertical := x % 4 == 3
			var is_horizontal := y % 4 == 3
			if is_vertical and is_horizontal:
				var cardinals_are_walls := true
				for direction: Vector2i in DIRECTIONS:
					var neighbor := position + direction
					if not _in_square(neighbor, size) or state.kinds[_index(neighbor, size)] != KIND_WALL:
						cardinals_are_walls = false
						break
				if not cardinals_are_walls:
					continue
				var diagonals: Array[Vector2i] = [
					position + Vector2i(-1, -1), position + Vector2i(1, -1),
					position + Vector2i(-1, 1), position + Vector2i(1, 1),
				]
				var first_room_id := state.room_ids[_index(diagonals[0], size)]
				var all_match := first_room_id >= 0
				for diagonal: Vector2i in diagonals:
					var diagonal_index := _index(diagonal, size)
					if state.kinds[diagonal_index] != KIND_FLOOR or state.room_ids[diagonal_index] != first_room_id:
						all_match = false
						break
				if all_match:
					replacement_positions.append(position)
					replacement_room_ids.append(first_room_id)
				continue
			var first: Vector2i
			var second: Vector2i
			if is_vertical:
				first = position + Vector2i.LEFT
				second = position + Vector2i.RIGHT
			elif is_horizontal:
				first = position + Vector2i.UP
				second = position + Vector2i.DOWN
			else:
				continue
			var first_index := _index(first, size)
			var second_index := _index(second, size)
			if (
				state.kinds[first_index] == KIND_FLOOR
				and state.kinds[second_index] == KIND_FLOOR
				and state.room_ids[first_index] == state.room_ids[second_index]
			):
				replacement_positions.append(position)
				replacement_room_ids.append(state.room_ids[first_index])
	for replacement_index: int in range(replacement_positions.size()):
		var index := _index(replacement_positions[replacement_index], size)
		state.kinds[index] = KIND_FLOOR
		state.room_ids[index] = replacement_room_ids[replacement_index]


static func _author_doorways(state: BuildState, rng: RandomNumberGenerator) -> bool:
	var room_floor_positions: Array = []
	for _room: RoomState in state.rooms:
		room_floor_positions.append([])
	for y: int in range(state.blueprint_size):
		for x: int in range(state.blueprint_size):
			var index := y * state.blueprint_size + x
			if state.kinds[index] == KIND_FLOOR:
				room_floor_positions[state.room_ids[index]].append(Vector2i(x, y))
	for room: RoomState in state.rooms:
		for side: int in range(4):
			var side_bit := 1 << side
			if room.door_mask & side_bit:
				continue
			var candidates := _doorway_candidates(
				state, room.room_id, side, room_floor_positions[room.room_id]
			)
			if candidates.is_empty():
				push_error("%s: room %d has no doorway candidate on side %d" % [ERROR_ORIGIN, room.room_id, side])
				return false
			var approach: Vector2i = candidates[rng.randi_range(0, candidates.size() - 1)]
			room.door_mask |= side_bit
			var direction := DIRECTIONS[side]
			var wall_position := approach + direction
			if not _in_square(wall_position, state.blueprint_size):
				continue
			var opposite_floor := approach + direction * 2
			if not _in_square(opposite_floor, state.blueprint_size):
				continue
			var wall_index := _index(wall_position, state.blueprint_size)
			var opposite_index := _index(opposite_floor, state.blueprint_size)
			if state.kinds[opposite_index] != KIND_FLOOR:
				push_error("%s: doorway has no opposite floor at %s" % [ERROR_ORIGIN, opposite_floor])
				return false
			state.kinds[wall_index] = KIND_DOOR
			state.door_axes[wall_index] = AXIS_HORIZONTAL if direction.x != 0 else AXIS_VERTICAL
			var neighbor_room_id := state.room_ids[opposite_index]
			state.rooms[neighbor_room_id].door_mask |= 1 << OPPOSITE_SIDE[side]
	return true


static func _doorway_candidates(
	state: BuildState, room_id: int, side: int, floor_positions: Array
) -> Array[Vector2i]:
	var size := state.blueprint_size
	var extreme := 2147483647 if side == 0 or side == 3 else -2147483648
	for position: Vector2i in floor_positions:
		var value := position.y if side == 0 or side == 2 else position.x
		if side == 0 or side == 3:
			extreme = mini(extreme, value)
		else:
			extreme = maxi(extreme, value)
	var candidates: Array[Vector2i] = []
	var direction := DIRECTIONS[side]
	var perpendiculars: Array[Vector2i] = []
	if side == 0 or side == 2:
		perpendiculars.assign([Vector2i.LEFT, Vector2i.RIGHT])
	else:
		perpendiculars.assign([Vector2i.UP, Vector2i.DOWN])
	for position: Vector2i in floor_positions:
		var value := position.y if side == 0 or side == 2 else position.x
		if value != extreme:
			continue
		if not _same_room_floor(state, position + perpendiculars[0], room_id):
			continue
		if not _same_room_floor(state, position + perpendiculars[1], room_id):
			continue
		var wall_position := position + direction
		if not _in_square(wall_position, size):
			candidates.append(position)
			continue
		var wall_kind := state.kinds[_index(wall_position, size)]
		var opposite_position := position + direction * 2
		if (
			(wall_kind == KIND_WALL or wall_kind == KIND_DOOR)
			and _in_square(opposite_position, size)
			and state.kinds[_index(opposite_position, size)] == KIND_FLOOR
		):
			candidates.append(position)
	return candidates


static func _add_exterior_ring(state: BuildState) -> void:
	var old_size := state.blueprint_size
	var new_size := old_size + 2
	var count := new_size * new_size
	var new_kinds := PackedByteArray()
	new_kinds.resize(count)
	new_kinds.fill(KIND_WALL)
	var new_room_ids := PackedInt32Array()
	new_room_ids.resize(count)
	new_room_ids.fill(-1)
	var new_axes := PackedByteArray()
	new_axes.resize(count)
	new_axes.fill(NO_AXIS)
	for y: int in range(old_size):
		for x: int in range(old_size):
			var old_index := y * old_size + x
			var new_index := (y + 1) * new_size + x + 1
			new_kinds[new_index] = state.kinds[old_index]
			new_room_ids[new_index] = state.room_ids[old_index]
			new_axes[new_index] = state.door_axes[old_index]
	state.blueprint_size = new_size
	state.kinds = new_kinds
	state.room_ids = new_room_ids
	state.door_axes = new_axes


static func _resolve_final_tiles(state: BuildState, rng: RandomNumberGenerator) -> Dictionary:
	var final_size := state.blueprint_size * 3
	var final_cells := PackedInt32Array()
	final_cells.resize(final_size * final_size)
	final_cells.fill(RapidRoomMapData.WALL)
	var doorways: Array[RapidRoomDoorway] = []
	for blueprint_y: int in range(state.blueprint_size):
		for blueprint_x: int in range(state.blueprint_size):
			var blueprint_position := Vector2i(blueprint_x, blueprint_y)
			var blueprint_index := _index(blueprint_position, state.blueprint_size)
			var kind := state.kinds[blueprint_index]
			if kind == KIND_FLOOR:
				_fill_final_block(final_cells, final_size, blueprint_position, RapidRoomMapData.FLOOR)
			elif kind == KIND_DOOR:
				var template_index := rng.randi_range(0, DOORWAY_TEMPLATES.size() - 1)
				var axis: int = state.door_axes[blueprint_index]
				_write_doorway_template(final_cells, final_size, blueprint_position, template_index, axis)
				doorways.append(RapidRoomDoorway.new(
					blueprint_position * 3 + Vector2i.ONE,
					axis as RapidRoomDoorway.Axis
				))
	_erode_floor_facing_wall_tiles(state, final_cells, final_size, rng)
	return {
		&"cells": final_cells,
		&"doorways": doorways,
	}


static func _write_doorway_template(
	cells: PackedInt32Array,
	final_size: int,
	blueprint_position: Vector2i,
	template_index: int,
	axis: int
) -> void:
	var template: Array = DOORWAY_TEMPLATES[template_index]
	var origin := blueprint_position * 3
	for local_y: int in range(3):
		for local_x: int in range(3):
			var source_x := local_x
			var source_y := local_y
			if axis == AXIS_HORIZONTAL:
				source_x = local_y
				source_y = 2 - local_x
			var value := RapidRoomMapData.FLOOR if template[source_y][source_x] == "." else RapidRoomMapData.WALL
			cells[(origin.y + local_y) * final_size + origin.x + local_x] = value


static func _fill_final_block(
	cells: PackedInt32Array, final_size: int, blueprint_position: Vector2i, value: int
) -> void:
	var origin := blueprint_position * 3
	for local_y: int in range(3):
		for local_x: int in range(3):
			cells[(origin.y + local_y) * final_size + origin.x + local_x] = value


static func _erode_floor_facing_wall_tiles(
	state: BuildState,
	cells: PackedInt32Array,
	final_size: int,
	rng: RandomNumberGenerator
) -> void:
	var snapshot := cells.duplicate()
	var replacements := PackedInt32Array()
	for blueprint_y: int in range(state.blueprint_size):
		for blueprint_x: int in range(state.blueprint_size):
			var blueprint_index := blueprint_y * state.blueprint_size + blueprint_x
			if state.kinds[blueprint_index] != KIND_WALL:
				continue
			var origin := Vector2i(blueprint_x * 3, blueprint_y * 3)
			for local_y: int in range(3):
				for local_x: int in range(3):
					if local_x == 1 and local_y == 1:
						continue
					var position := origin + Vector2i(local_x, local_y)
					var final_index := _index(position, final_size)
					if snapshot[final_index] != RapidRoomMapData.WALL:
						continue
					var touches_floor := false
					for direction: Vector2i in DIRECTIONS:
						var neighbor := position + direction
						if _in_square(neighbor, final_size) and snapshot[_index(neighbor, final_size)] == RapidRoomMapData.FLOOR:
							touches_floor = true
							break
					if touches_floor and rng.randf() < WALL_EROSION_CHANCE:
						replacements.append(final_index)
	for replacement_index: int in replacements:
		cells[replacement_index] = RapidRoomMapData.FLOOR


static func _same_room_floor(state: BuildState, position: Vector2i, room_id: int) -> bool:
	if not _in_square(position, state.blueprint_size):
		return false
	var index := _index(position, state.blueprint_size)
	return state.kinds[index] == KIND_FLOOR and state.room_ids[index] == room_id


static func _index(position: Vector2i, width: int) -> int:
	return position.y * width + position.x


static func _in_square(position: Vector2i, size: int) -> bool:
	return position.x >= 0 and position.y >= 0 and position.x < size and position.y < size
