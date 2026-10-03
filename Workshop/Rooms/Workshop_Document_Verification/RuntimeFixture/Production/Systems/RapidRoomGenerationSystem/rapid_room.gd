class_name RapidRoom
extends RefCounted

var id: int
var panel_count: int
var floor_coordinates: Array[Vector2i]
var room_type: StringName
var tags: Array[StringName]


func _init(
	room_id: int,
	room_panel_count: int,
	owned_floor_coordinates: Array[Vector2i] = [],
	assigned_room_type: StringName = &"",
	assigned_tags: Array[StringName] = []
) -> void:
	id = room_id
	panel_count = room_panel_count
	floor_coordinates = owned_floor_coordinates.duplicate()
	room_type = assigned_room_type
	tags = assigned_tags.duplicate()


func assign_layout(assigned_room_type: StringName, assigned_tags: Array[StringName]) -> void:
	room_type = assigned_room_type
	tags = assigned_tags.duplicate()


func duplicate_detached() -> RapidRoom:
	return RapidRoom.new(id, panel_count, floor_coordinates, room_type, tags)
