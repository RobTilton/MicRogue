class_name DungeonRenderer
extends GridMap

const VOID: int = 0
const FLOOR: int = 1
const WALL: int = 2

const FLOOR_MESH_ID: int = 0
const WALL_MESH_ID: int = 1


func render_dungeon(dungeon: Dictionary) -> void:
	clear()

	var width: int = dungeon["width"]
	var height: int = dungeon["height"]
	var cells: PackedInt32Array = dungeon["cells"]

	for y: int in range(height):
		for x: int in range(width):
			var index: int = y * width + x
			var cell: int = cells[index]

			match cell:
				VOID:
					continue

				FLOOR:
					set_cell_item(
						Vector3i(x, 0, y),
						FLOOR_MESH_ID
					)

				WALL:
					set_cell_item(
						Vector3i(x, 0, y),
						WALL_MESH_ID
					)
