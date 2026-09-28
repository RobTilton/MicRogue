class_name RapidRoomDoorway
extends RefCounted

enum Axis {
	HORIZONTAL,
	VERTICAL,
}

var position: Vector2i
var footprint_center: Vector2i
var axis: Axis


func _init(
	requested_position: Vector2i,
	requested_footprint_center: Vector2i,
	requested_axis: Axis
) -> void:
	position = requested_position
	footprint_center = requested_footprint_center
	axis = requested_axis


func duplicate_detached() -> RapidRoomDoorway:
	return RapidRoomDoorway.new(position, footprint_center, axis)
