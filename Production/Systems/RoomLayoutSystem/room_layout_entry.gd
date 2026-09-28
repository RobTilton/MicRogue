class_name RoomLayoutEntry
extends RefCounted

var room_type: StringName
var minimum_panels: int
var maximum_panels: int
var tags: Array[StringName]


func _init(
	entry_room_type: StringName,
	entry_minimum_panels: int,
	entry_maximum_panels: int,
	entry_tags: Array[StringName]
) -> void:
	room_type = entry_room_type
	minimum_panels = entry_minimum_panels
	maximum_panels = entry_maximum_panels
	tags = entry_tags.duplicate()


func accepts(panel_count: int) -> bool:
	return panel_count >= minimum_panels and panel_count <= maximum_panels
