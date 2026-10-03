class_name RapidRoomMapData
extends RefCounted

const FLOOR: int = 1
const WALL: int = 2

var cells: PackedInt32Array
var rooms: Array[RapidRoom]
var room_count: int
var doorways: Array[RapidRoomDoorway]


func _init(
	map_cells: PackedInt32Array,
	map_rooms: Array[RapidRoom],
	map_doorways: Array[RapidRoomDoorway]
) -> void:
	cells = map_cells.duplicate()
	rooms = []
	for room: RapidRoom in map_rooms:
		rooms.append(room.duplicate_detached())
	room_count = rooms.size()
	doorways = []
	for doorway: RapidRoomDoorway in map_doorways:
		doorways.append(doorway.duplicate_detached())
