class_name AppliedHolePunch
extends RefCounted

var pattern_id: StringName
var center: Vector2i
var connected_room_count: int
var mutated_cell_count: int
var room_count_before: int
var room_count_after: int


func _init(
	resolved_pattern_id: StringName,
	resolved_center: Vector2i,
	resolved_connected_room_count: int,
	resolved_mutated_cell_count: int,
	resolved_room_count_before: int,
	resolved_room_count_after: int
) -> void:
	pattern_id = resolved_pattern_id
	center = resolved_center
	connected_room_count = resolved_connected_room_count
	mutated_cell_count = resolved_mutated_cell_count
	room_count_before = resolved_room_count_before
	room_count_after = resolved_room_count_after
