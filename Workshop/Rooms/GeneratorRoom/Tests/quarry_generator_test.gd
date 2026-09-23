extends Node

const QuarryGenerator = preload(
	"res://Workshop/Rooms/GeneratorRoom/DungeonGeneration/dungeon_generator_frontier.gd"
)

@onready var grid_map: GridMap = $GridMap

const FLOOR_TILE_ID: int = 0
const WALL_TILE_ID: int = 1
const DEBUG_TILE_ID: int = 2


func _ready() -> void:
	var quarry := QuarryGenerator.generate_dungeon(
		121,
		81,
		200,
		5,
		15,
		5,
		15,
		4434
	)

	var dungeon := QuarryGenerator.crop_window(
		quarry,
		Vector2i(30, 20),
		Vector2i(60, 40)
	)

	QuarryGenerator.seal_boundary(dungeon)

	var repaired_result := QuarryGenerator.repair_with_cross(dungeon)
	var repaired: Dictionary = repaired_result["field"]

	var final_dungeon := QuarryGenerator.keep_largest_region(repaired)

	print("STAMPS: ", repaired_result["stamps"])
	print("MUTATED: ", repaired_result["mutated_cells"])

	_paint_dungeon(final_dungeon)


func _paint_dungeon(field: Dictionary) -> void:
	var width: int = field["width"]
	var height: int = field["height"]
	var cells: PackedInt32Array = field["cells"]

	grid_map.clear()

	for y: int in range(height):
		for x: int in range(width):
			var index: int = x + y * width
			var cell_value: int = cells[index]

			var grid_position := Vector3i(x, 0, y)

			match cell_value:
				QuarryGenerator.FLOOR:
					grid_map.set_cell_item(
						grid_position,
						FLOOR_TILE_ID
					)

				QuarryGenerator.WALL:
					grid_map.set_cell_item(
						grid_position,
						WALL_TILE_ID
					)
