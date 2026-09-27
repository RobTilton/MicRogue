class_name RapidRoomMapData
extends RefCounted

const FLOOR: int = 1
const WALL: int = 2

var width: int
var height: int
var cells: PackedInt32Array
var doorways: Array[RapidRoomDoorway]
var generation_usec: int
var room_count: int
var sealed_outward_requests: int
var eroded_wall_tiles: int


func _init(
	map_width: int,
	map_height: int,
	map_cells: PackedInt32Array,
	map_doorways: Array[RapidRoomDoorway],
	elapsed_usec: int,
	generated_room_count: int,
	sealed_requests: int,
	eroded_tiles: int
) -> void:
	width = map_width
	height = map_height
	cells = map_cells.duplicate()
	doorways = []
	for doorway: RapidRoomDoorway in map_doorways:
		doorways.append(doorway.duplicate_detached())
	generation_usec = elapsed_usec
	room_count = generated_room_count
	sealed_outward_requests = sealed_requests
	eroded_wall_tiles = eroded_tiles


func cell_legend() -> Dictionary[StringName, int]:
	return {
		&"floor": FLOOR,
		&"wall": WALL,
	}


func get_cell(position: Vector2i) -> int:
	return cells[position.y * width + position.x]


func to_ascii() -> String:
	var lines := PackedStringArray()
	for y: int in range(height):
		var line := ""
		for x: int in range(width):
			line += "." if cells[y * width + x] == FLOOR else "#"
		lines.append(line)
	return "\n".join(lines)
