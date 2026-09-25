class_name GeometryField
extends RefCounted

const VOID: int = 0
const FLOOR: int = 1
const WALL: int = 2

var size: Vector2i
var cells: PackedInt32Array


func _init(field_size: Vector2i, field_cells: PackedInt32Array) -> void:
	size = field_size
	cells = field_cells


func cell_index(position: Vector2i) -> int:
	return position.y * size.x + position.x


func get_cell(position: Vector2i) -> int:
	return cells[cell_index(position)]


func set_cell(position: Vector2i, value: int) -> void:
	cells[cell_index(position)] = value
