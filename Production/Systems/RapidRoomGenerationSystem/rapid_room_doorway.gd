class_name RapidRoomDoorway
extends RefCounted

enum Axis {
	HORIZONTAL,
	VERTICAL,
}

var position: Vector2i
var axis: Axis


func _init(
	requested_position: Vector2i,
	requested_axis: Axis
) -> void:
	position = requested_position
	axis = requested_axis


func duplicate_detached() -> RapidRoomDoorway:
	return RapidRoomDoorway.new(position, axis)
