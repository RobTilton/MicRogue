extends GridMap

const QuarryGenerator = preload(
	"res://Workshop/Rooms/GeneratorRoom/DungeonGeneration/dungeon_generator_frontier.gd"
)
func build_from_quarry(quarry: Dictionary) -> void:
	var width: int = quarry["width"]
	var height: int = quarry["height"]
	var cells: PackedInt32Array = quarry["cells"]

	for y: int in range(height):
		for x: int in range(width):
			var cell: int = cells[y * width + x]

			match cell:
				0:
					continue
				1:
					set_cell_item(Vector3i(x, 0, y), FLOOR_ID)
				2:
					set_cell_item(Vector3i(x, 0, y), WALL_ID)
