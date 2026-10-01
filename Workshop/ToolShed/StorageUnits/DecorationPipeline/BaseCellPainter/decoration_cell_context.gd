class_name DecorationCellContext
extends RefCounted

enum Topology { ISOLATED, EDGE, OUTER_CORNER, INNER_CORNER, SURROUNDED, INTERIOR, IRREGULAR }

var coordinate: Vector2i
var physical_cell: int
var role: StringName
var topology: Topology
var cardinal_mask: int
var diagonal_mask: int
var room_id: int
var room_type: StringName
var room_tags: Array[StringName]
var is_door_position: bool
var is_doorway_footprint: bool
var variant_key: int


func _init(values: Dictionary) -> void:
	coordinate = values.coordinate; physical_cell = values.physical_cell; role = values.role
	topology = values.topology; cardinal_mask = values.cardinal_mask; diagonal_mask = values.diagonal_mask
	room_id = values.room_id; room_type = values.room_type; room_tags = []
	for tag: StringName in values.room_tags: room_tags.append(tag)
	is_door_position = values.is_door_position; is_doorway_footprint = values.is_doorway_footprint
	variant_key = values.variant_key
