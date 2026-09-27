class_name RapidRoomDoorway
extends RefCounted

enum Axis {
	HORIZONTAL,
	VERTICAL,
}

var blueprint_position: Vector2i
var final_origin: Vector2i
var axis: Axis
var template_index: int


func _init(
	requested_blueprint_position: Vector2i,
	requested_final_origin: Vector2i,
	requested_axis: Axis,
	requested_template_index: int
) -> void:
	blueprint_position = requested_blueprint_position
	final_origin = requested_final_origin
	axis = requested_axis
	template_index = requested_template_index


func duplicate_detached() -> RapidRoomDoorway:
	return RapidRoomDoorway.new(blueprint_position, final_origin, axis, template_index)
