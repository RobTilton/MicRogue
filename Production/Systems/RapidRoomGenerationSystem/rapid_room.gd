class_name RapidRoom
extends RefCounted

var id: int
var panel_count: int


func _init(room_id: int, room_panel_count: int) -> void:
	id = room_id
	panel_count = room_panel_count


func duplicate_detached() -> RapidRoom:
	return RapidRoom.new(id, panel_count)
