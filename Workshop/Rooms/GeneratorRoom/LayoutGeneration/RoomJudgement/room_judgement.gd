class_name RoomJudgement
extends RefCounted

const ERROR_ORIGIN := "res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/RoomJudgement/room_judgement.gd"
const PLUS: Array[Vector2i] = [Vector2i.ZERO, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const DIRECTIONS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const MAX_WALL_DISTANCE: int = 5
const UNREACHABLE: int = 1_000_000


static func judge(field: GeometryField, rooms: Array[DiscoveredRoom]) -> RoomJudgementResult:
	if field == null:
		return _failure("GeometryField is required.")
	if rooms.is_empty():
		return _failure("At least one substantial room is required.")
	var result := RoomJudgementResult.new()
	result.field = GeometryField.new(field.size, field.cells.duplicate())
	var main := _copy_room(_largest_room(rooms))
	var candidates: Array[DiscoveredRoom] = []
	for room in rooms:
		if room.id != main.id:
			candidates.append(room)
	candidates.sort_custom(func(a: DiscoveredRoom, b: DiscoveredRoom) -> bool: return a.floor_cells.size() > b.floor_cells.size() if a.floor_cells.size() != b.floor_cells.size() else a.id < b.id)
	for room in candidates:
		var choice := _find_choice(result.field, main, room)
		if choice.is_empty():
			for cell in room.floor_cells:
				result.field.set_cell(cell, GeometryField.WALL)
			result.sundered_room_count += 1
			continue
		var punched_cells: Array[Vector2i] = choice["cells"]
		for cell in punched_cells:
			result.field.set_cell(cell, GeometryField.FLOOR)
		main = _merge(main, room, punched_cells, result.field)
		result.saved_room_count += 1
		result.punch_count += choice["punch_count"]
	result.rooms = [main]
	return result


static func _find_choice(field: GeometryField, main: DiscoveredRoom, room: DiscoveredRoom) -> Dictionary:
	var best: Dictionary = {}
	for first in main.frontier_walls:
		_consider(field, main, room, [first], 1, best)
		for second in room.frontier_walls:
			var center_distance := absi(first.x - second.x) + absi(first.y - second.y)
			if center_distance <= 3:
				_consider(field, main, room, [first, second], 2, best)
	return best


static func _consider(field: GeometryField, main: DiscoveredRoom, room: DiscoveredRoom, centers: Array[Vector2i], punch_count: int, best: Dictionary) -> void:
	var cell_set: Dictionary[Vector2i, bool] = {}
	for center in centers:
		for offset in PLUS:
			var cell := center + offset
			if not _safe_interior(field, cell) or field.get_cell(cell) == GeometryField.VOID:
				return
			cell_set[cell] = true
	var cells: Array[Vector2i] = []
	for cell in cell_set:
		cells.append(cell)
	if not _connected(cells):
		return
	var wall_distance := _minimum_wall_distance(cells, main.floor_cells, room.floor_cells, field)
	if wall_distance < 1 or wall_distance > MAX_WALL_DISTANCE:
		return
	var mutations: int = 0
	for cell in cells:
		if field.get_cell(cell) == GeometryField.WALL:
			mutations += 1
	if _better(punch_count, wall_distance, mutations, centers, best):
		best["cells"] = cells
		best["punch_count"] = punch_count
		best["wall_distance"] = wall_distance
		best["mutations"] = mutations
		best["key"] = _center_key(centers)


static func _minimum_wall_distance(punch_cells: Array[Vector2i], main_floors: Array[Vector2i], room_floors: Array[Vector2i], field: GeometryField) -> int:
	var punch_set := _cell_set(punch_cells)
	var main_set := _cell_set(main_floors)
	var room_set := _cell_set(room_floors)
	var distance: Dictionary[Vector2i, int] = {}
	var pending: Array[Vector2i] = []
	for cell in punch_cells:
		if _touches(cell, main_set):
			distance[cell] = _wall_cost(field, cell)
			pending.append(cell)
	while not pending.is_empty():
		var index := _minimum_index(pending, distance)
		var current: Vector2i = pending[index]
		pending.remove_at(index)
		if _touches(current, room_set):
			return distance[current]
		for direction in DIRECTIONS:
			var next := current + direction
			if not punch_set.has(next):
				continue
			var proposed: int = distance[current] + _wall_cost(field, next)
			if proposed < distance.get(next, UNREACHABLE):
				distance[next] = proposed
				if not pending.has(next):
					pending.append(next)
	return UNREACHABLE


static func _better(punches: int, distance: int, mutations: int, centers: Array[Vector2i], best: Dictionary) -> bool:
	if best.is_empty():
		return true
	if punches != best["punch_count"]:
		return punches < best["punch_count"]
	if distance != best["wall_distance"]:
		return distance < best["wall_distance"]
	if mutations != best["mutations"]:
		return mutations < best["mutations"]
	return _center_key(centers) < best["key"]


static func _merge(main: DiscoveredRoom, room: DiscoveredRoom, punched: Array[Vector2i], field: GeometryField) -> DiscoveredRoom:
	var floors := _cell_set(main.floor_cells)
	for cell in room.floor_cells:
		floors[cell] = true
	for cell in punched:
		floors[cell] = true
	var frontiers: Dictionary[Vector2i, bool] = {}
	for wall in main.frontier_walls:
		if field.get_cell(wall) == GeometryField.WALL:
			frontiers[wall] = true
	for wall in room.frontier_walls:
		if field.get_cell(wall) == GeometryField.WALL:
			frontiers[wall] = true
	for cell in punched:
		frontiers.erase(cell)
		for direction in DIRECTIONS:
			var neighbor := cell + direction
			if _inside(field, neighbor) and field.get_cell(neighbor) == GeometryField.WALL:
				frontiers[neighbor] = true
	var floor_array: Array[Vector2i] = []
	for cell in floors:
		floor_array.append(cell)
	var frontier_array: Array[Vector2i] = []
	for wall in frontiers:
		frontier_array.append(wall)
	return DiscoveredRoom.new(main.id, floor_array, frontier_array)


static func _largest_room(rooms: Array[DiscoveredRoom]) -> DiscoveredRoom:
	var largest := rooms[0]
	for room in rooms:
		if room.floor_cells.size() > largest.floor_cells.size() or (room.floor_cells.size() == largest.floor_cells.size() and room.id < largest.id):
			largest = room
	return largest


static func _copy_room(room: DiscoveredRoom) -> DiscoveredRoom:
	return DiscoveredRoom.new(room.id, room.floor_cells.duplicate(), room.frontier_walls.duplicate())


static func _cell_set(cells: Array[Vector2i]) -> Dictionary[Vector2i, bool]:
	var result: Dictionary[Vector2i, bool] = {}
	for cell in cells:
		result[cell] = true
	return result


static func _touches(cell: Vector2i, floor_set: Dictionary[Vector2i, bool]) -> bool:
	if floor_set.has(cell):
		return true
	for direction in DIRECTIONS:
		if floor_set.has(cell + direction):
			return true
	return false


static func _connected(cells: Array[Vector2i]) -> bool:
	if cells.is_empty():
		return false
	var cell_set := _cell_set(cells)
	var seen: Dictionary[Vector2i, bool] = {cells[0]: true}
	var pending: Array[Vector2i] = [cells[0]]
	while not pending.is_empty():
		var current: Vector2i = pending.pop_back()
		for direction in DIRECTIONS:
			var next := current + direction
			if cell_set.has(next) and not seen.has(next):
				seen[next] = true
				pending.append(next)
	return seen.size() == cells.size()


static func _minimum_index(pending: Array[Vector2i], distance: Dictionary[Vector2i, int]) -> int:
	var best := 0
	for index in range(1, pending.size()):
		if distance[pending[index]] < distance[pending[best]]:
			best = index
	return best


static func _center_key(centers: Array[Vector2i]) -> String:
	var parts := PackedStringArray()
	for center in centers:
		parts.append("%08d:%08d" % [center.y, center.x])
	return "|".join(parts)


static func _wall_cost(field: GeometryField, cell: Vector2i) -> int:
	return 1 if field.get_cell(cell) == GeometryField.WALL else 0


static func _safe_interior(field: GeometryField, cell: Vector2i) -> bool:
	return cell.x > 0 and cell.y > 0 and cell.x < field.size.x - 1 and cell.y < field.size.y - 1


static func _inside(field: GeometryField, cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < field.size.x and cell.y < field.size.y


static func _failure(message: String) -> RoomJudgementResult:
	var result := RoomJudgementResult.new()
	result.error_message = "%s: %s" % [ERROR_ORIGIN, message]
	return result
