class_name RoomDiscoveryFill
extends RefCounted

const ERROR_ORIGIN := "MapGenerationSystem/RoomDiscoveryFill"
const CARDINAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.DOWN,
]


static func discover(
	field: GeometryField,
	include_frontier_walls: bool
) -> RoomDiscoveryResult:
	if field == null:
		return RoomDiscoveryResult.failure(
			"%s: GeometryField is required." % ERROR_ORIGIN
		)

	var visited := PackedByteArray()
	visited.resize(field.cells.size())
	visited.fill(0)
	var rooms: Array[DiscoveredRoom] = []

	for y in range(field.size.y):
		for x in range(field.size.x):
			var position := Vector2i(x, y)
			var index: int = field.cell_index(position)
			if field.cells[index] != GeometryField.FLOOR or visited[index] == 1:
				continue
			rooms.append(
				_discover_room(
					field,
					position,
					rooms.size(),
					visited,
					include_frontier_walls
				)
			)

	return RoomDiscoveryResult.success(rooms, include_frontier_walls)


static func _discover_room(
	field: GeometryField,
	start: Vector2i,
	room_id: int,
	visited: PackedByteArray,
	include_frontier_walls: bool
) -> DiscoveredRoom:
	var pending: Array[Vector2i] = [start]
	var read_index: int = 0
	var floor_cells: Array[Vector2i] = []
	var frontier_set := {}
	visited[field.cell_index(start)] = 1

	while read_index < pending.size():
		var current: Vector2i = pending[read_index]
		read_index += 1
		floor_cells.append(current)

		for direction in CARDINAL_DIRECTIONS:
			var neighbor: Vector2i = current + direction
			if not _is_inside(neighbor, field.size):
				continue
			var neighbor_index: int = field.cell_index(neighbor)
			var neighbor_value: int = field.cells[neighbor_index]
			if neighbor_value == GeometryField.FLOOR:
				if visited[neighbor_index] == 0:
					visited[neighbor_index] = 1
					pending.append(neighbor)
			elif include_frontier_walls and neighbor_value == GeometryField.WALL:
				frontier_set[neighbor] = true

	var frontier_walls: Array[Vector2i] = []
	if include_frontier_walls:
		for wall: Vector2i in frontier_set:
			frontier_walls.append(wall)
		frontier_walls.sort_custom(_position_precedes)

	return DiscoveredRoom.new(room_id, floor_cells, frontier_walls)


static func _is_inside(position: Vector2i, size: Vector2i) -> bool:
	return position.x >= 0 and position.y >= 0 and position.x < size.x and position.y < size.y


static func _position_precedes(first: Vector2i, second: Vector2i) -> bool:
	return first.y < second.y or (first.y == second.y and first.x < second.x)
