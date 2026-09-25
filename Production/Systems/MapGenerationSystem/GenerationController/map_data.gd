class_name MapData
extends RefCounted

const ABYSS: int = GeometryField.VOID
const FLOOR: int = GeometryField.FLOOR
const WALL: int = GeometryField.WALL

var width: int
var height: int
var cells: PackedInt32Array


func _init(
	map_width: int,
	map_height: int,
	map_cells: PackedInt32Array
) -> void:
	width = map_width
	height = map_height
	cells = map_cells.duplicate()


func cell_legend() -> Dictionary[StringName, int]:
	return {
		&"abyss": ABYSS,
		&"floor": FLOOR,
		&"wall": WALL,
	}


func get_cell(position: Vector2i) -> int:
	return cells[position.y * width + position.x]
