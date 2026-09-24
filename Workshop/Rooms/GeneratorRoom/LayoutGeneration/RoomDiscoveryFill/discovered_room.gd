class_name DiscoveredRoom
extends RefCounted

var id: int
var floor_cells: Array[Vector2i]
var frontier_walls: Array[Vector2i]


func _init(
	room_id: int,
	room_floor_cells: Array[Vector2i],
	room_frontier_walls: Array[Vector2i]
) -> void:
	id = room_id
	floor_cells = room_floor_cells
	frontier_walls = room_frontier_walls
