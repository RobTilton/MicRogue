extends SceneTree

const ORIGIN: String = "Workshop/ToolShed/Completed_Tool_Builds/RapidGenerationInspection/test_rapid_doorway_placement.gd"
var checks: int = 0
var failures: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for size: int in [4, 5, 10, 20]:
		for seed: int in range(250):
			_validate_map(RapidRoomGenerator.make_seeded_map(size, seed))
	await _validate_visualization()
	if failures == 0:
		print("%s: PASS (%d checks across 1000 maps)" % [ORIGIN, checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)" % [ORIGIN, failures, checks])
	quit(1)


func _validate_map(data: RapidRoomMapData) -> void:
	var side: int = int(round(sqrt(float(data.cells.size()))))
	var positions: Dictionary = {}
	for doorway: RapidRoomDoorway in data.doorways:
		var direction: Vector2i = Vector2i.RIGHT if doorway.door_item_axis == RapidRoomDoorway.Axis.HORIZONTAL else Vector2i.DOWN
		_expect(abs(doorway.position.x - doorway.footprint_center.x) <= 1 and abs(doorway.position.y - doorway.footprint_center.y) <= 1, "placement is inside its footprint")
		_expect(_is_floor(data, side, doorway.position - direction) and _is_floor(data, side, doorway.position) and _is_floor(data, side, doorway.position + direction), "placement has straight traversal floor")
		_expect(not positions.has(doorway.position), "placement is unique")
		positions[doorway.position] = true
		var detached: RapidRoomDoorway = doorway.duplicate_detached()
		_expect(detached.position == doorway.position and detached.footprint_center == doorway.footprint_center and detached.axis == doorway.axis and detached.door_item_axis == doorway.door_item_axis, "detached record preserves placement and local door orientation")


func _validate_visualization() -> void:
	var packed: PackedScene = load("res://Workshop/ToolShed/Completed_Tool_Builds/RapidGenerationInspection/VisualizationTool.tscn")
	_expect(packed != null, "visualization scene loads")
	if packed == null:
		return
	var visualization: Node3D = packed.instantiate()
	visualization.set("size", 10)
	root.add_child(visualization)
	await process_frame
	var data: RapidRoomMapData = RapidRoomGenerator.make_seeded_map(10, 42)
	_expect(RoomLayoutTagger.tag_rooms_seeded(data, RoomLayoutSemantics.Archetype.CAVE, 42), "visualization input tags")
	_expect(visualization.call("render_map_data", data), "visualization renders")
	var grid_map: GridMap = visualization.get_node("GridMap")
	_expect(grid_map.get_used_cells_by_item(3).size() == data.doorways.size(), "one saved door item is placed per doorway")
	var vertical_orientation: int = grid_map.get_orthogonal_index_from_basis(Basis(Vector3.UP, PI * 0.5))
	for doorway: RapidRoomDoorway in data.doorways:
		var coordinate := Vector3i(doorway.position.x, 0, doorway.position.y)
		var expected_orientation: int = 0 if doorway.door_item_axis == RapidRoomDoorway.Axis.HORIZONTAL else vertical_orientation
		_expect(grid_map.get_cell_item(coordinate) == 3, "door uses mesh-library item 3")
		_expect(grid_map.get_cell_item_orientation(coordinate) == expected_orientation, "door orientation matches traversal")
	visualization.queue_free()
	await process_frame


func _is_floor(data: RapidRoomMapData, side: int, coordinate: Vector2i) -> bool:
	return coordinate.x >= 0 and coordinate.y >= 0 and coordinate.x < side and coordinate.y < side and data.cells[coordinate.y * side + coordinate.x] == RapidRoomMapData.FLOOR


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		return
	failures += 1
	push_error("%s: %s" % [ORIGIN, message])
