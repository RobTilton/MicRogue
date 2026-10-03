class_name DecorationPaintPlan
extends RefCounted
const Context := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/decoration_cell_context.gd")

var width: int
var height: int
var cells: Array[Context]

func _init(side_length: int, planned_cells: Array[Context]) -> void:
	width = side_length; height = side_length; cells = planned_cells.duplicate()
