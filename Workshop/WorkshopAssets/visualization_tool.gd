extends Node3D

@onready var grid_map: GridMap = $GridMap

@export var floor_mesh_id: int = 0
@export var wall_mesh_id: int = 1

func _ready() -> void:
	var map_data: MapData = GeneratorCaller.make_map(
		MapParameters.new(
			GenerationSemantics.Archetype.DUNGEON,
			GenerationSemantics.Scale.LARGE,
			GenerationSemantics.GeometryModifier.STANDARD
		)
	)

	if map_data == null:
		push_error("VisualizationTool: Map generation failed.")
		return

	render_map(map_data)


func render_map(map_data: MapData) -> void:
	grid_map.clear()

	for y: int in range(map_data.height):
		for x: int in range(map_data.width):
			var index: int = y * map_data.width + x
			var cell: int = map_data.cells[index]

			match cell:
				1: # FLOOR
					grid_map.set_cell_item(Vector3i(x, 0, y), floor_mesh_id)

				2: # WALL
					grid_map.set_cell_item(Vector3i(x, 0, y), wall_mesh_id)

				0: # ABYSS
					pass
