class_name GeometryAnalysisResult
extends RefCounted

const CARDINAL_DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

var width: int
var height: int
var cells: PackedInt32Array
var floor_coordinates: Array[Vector2i]

var _floor_lookup: Dictionary = {}


func _init(
	map_width: int,
	map_height: int,
	map_cells: PackedInt32Array,
	map_floor_coordinates: Array[Vector2i]
) -> void:
	width = map_width
	height = map_height
	cells = map_cells.duplicate()
	floor_coordinates = map_floor_coordinates.duplicate()
	for coordinate: Vector2i in floor_coordinates:
		_floor_lookup[coordinate] = true


func is_floor(coordinate: Vector2i) -> bool:
	return _floor_lookup.has(coordinate)


func cardinal_neighbors(coordinate: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for direction: Vector2i in CARDINAL_DIRECTIONS:
		var candidate: Vector2i = coordinate + direction
		if _floor_lookup.has(candidate):
			neighbors.append(candidate)
	return neighbors


func distance_map_from_many(origins: Array[Vector2i]) -> Dictionary:
	var distances: Dictionary = {}
	var queue: Array[Vector2i] = []
	for origin: Vector2i in origins:
		if not _floor_lookup.has(origin) or distances.has(origin):
			continue
		distances[origin] = 0
		queue.append(origin)
	var read_index: int = 0
	while read_index < queue.size():
		var current: Vector2i = queue[read_index]
		read_index += 1
		var next_distance: int = int(distances[current]) + 1
		for direction: Vector2i in CARDINAL_DIRECTIONS:
			var neighbor: Vector2i = current + direction
			if not _floor_lookup.has(neighbor) or distances.has(neighbor):
				continue
			distances[neighbor] = next_distance
			queue.append(neighbor)
	return distances


func distance_map_from(origin: Vector2i) -> Dictionary:
	return distance_map_from_many([origin])


func duplicate_result() -> GeometryAnalysisResult:
	return GeometryAnalysisResult.new(width, height, cells, floor_coordinates)
