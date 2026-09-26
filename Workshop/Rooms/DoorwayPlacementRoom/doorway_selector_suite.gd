extends SceneTree

const ORIGIN: String = "Workshop/Rooms/DoorwayPlacementRoom/doorway_selector_suite.gd"
const CENTER := Vector2i(5, 5)

const REFERENCE_WALLS: Array[Array] = [
	[
		Vector2i(-2, -2), Vector2i(2, -2),
		Vector2i(-2, -1), Vector2i(2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0),
	],
	[
		Vector2i(-2, -2), Vector2i(-2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0),
	],
	[
		Vector2i(2, -2), Vector2i(2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-2, 1), Vector2i(-2, 2),
	],
	[
		Vector2i(3, -2), Vector2i(3, -1),
		Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-1, 1), Vector2i(-1, 2),
	],
	[
		Vector2i(1, -2), Vector2i(1, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0),
		Vector2i(-3, 1), Vector2i(-3, 2),
	],
	[
		Vector2i(-3, -2), Vector2i(1, -2),
		Vector2i(-3, -1), Vector2i(1, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0),
	],
	[
		Vector2i(-1, -2), Vector2i(3, -2),
		Vector2i(-1, -1), Vector2i(3, -1),
		Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
	],
	[
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0),
	],
	[
		Vector2i(-2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-2, 1),
	],
]

var _checks: int = 0
var _failures: int = 0


func _init() -> void:
	_test_all_reference_shapes()
	_test_vertical_rotation()
	_test_new_shape_transforms()
	_test_wildcard_geometry()
	_test_gate_rejects_abyss_pair()
	_test_catalog_rejects_short_wall_pair()
	_test_spacing()
	_test_input_is_unchanged()
	if _failures == 0:
		print("%s: PASS (%d checks)." % [ORIGIN, _checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)." % [ORIGIN, _failures, _checks])
	quit(1)


func _test_all_reference_shapes() -> void:
	for pattern_index: int in range(REFERENCE_WALLS.size()):
		var map_data: MapData = _map_with_horizontal_pattern(
			11,
			11,
			CENTER,
			REFERENCE_WALLS[pattern_index]
		)
		var selected: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(map_data)
		_check(selected.size() == 1, "reference pattern %d selects one door" % pattern_index)
		if selected.size() == 1:
			_check(selected[0].coordinate == CENTER, "reference pattern %d keeps its opening" % pattern_index)
			_check(
				selected[0].wall_orientation == DoorwayPlacement.WallOrientation.HORIZONTAL,
				"reference pattern %d reports horizontal wall" % pattern_index
			)


func _test_vertical_rotation() -> void:
	var cells: PackedInt32Array = _filled_cells(11, 11, MapData.ABYSS)
	_set_cell(cells, 11, CENTER + Vector2i.LEFT, MapData.FLOOR)
	_set_cell(cells, 11, CENTER, MapData.FLOOR)
	_set_cell(cells, 11, CENTER + Vector2i.RIGHT, MapData.FLOOR)
	for horizontal_offset: Vector2i in REFERENCE_WALLS[7]:
		var rotated := Vector2i(-horizontal_offset.y, horizontal_offset.x)
		_set_cell(cells, 11, CENTER + rotated, MapData.WALL)
	var selected: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(MapData.new(11, 11, cells))
	_check(selected.size() == 1, "rotated pattern selects one door")
	if selected.size() == 1:
		_check(selected[0].coordinate == CENTER, "rotated pattern keeps its opening")
		_check(
			selected[0].wall_orientation == DoorwayPlacement.WallOrientation.VERTICAL,
			"rotated pattern reports vertical wall"
		)


func _test_new_shape_transforms() -> void:
	var canonical: Array = REFERENCE_WALLS[8]
	for mirror_index: int in range(2):
		var transformed: Array[Vector2i] = []
		for canonical_offset: Vector2i in canonical:
			var offset: Vector2i = canonical_offset
			if mirror_index == 1:
				offset.x = -offset.x
			transformed.append(offset)
		for rotation_index: int in range(4):
			var map_data: MapData = _map_with_transformed_pattern(11, 11, CENTER, transformed)
			var selected: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(map_data)
			_check(
				selected.size() == 1 and selected[0].coordinate == CENTER,
				"new pattern mirror %d rotation %d is selected" % [mirror_index, rotation_index]
			)
			for offset_index: int in range(transformed.size()):
				var offset: Vector2i = transformed[offset_index]
				transformed[offset_index] = Vector2i(-offset.y, offset.x)


func _test_wildcard_geometry() -> void:
	var map_data: MapData = _map_with_horizontal_pattern(11, 11, CENTER, REFERENCE_WALLS[7])
	map_data.cells[_index(11, CENTER + Vector2i(-3, -3))] = MapData.WALL
	map_data.cells[_index(11, CENTER + Vector2i(3, 3))] = MapData.FLOOR
	var selected: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(map_data)
	_check(selected.size() == 1 and selected[0].coordinate == CENTER, "unlisted snapshot geometry is wildcard")


func _test_gate_rejects_abyss_pair() -> void:
	var cells: PackedInt32Array = _filled_cells(11, 11, MapData.ABYSS)
	_set_cell(cells, 11, CENTER, MapData.FLOOR)
	_set_cell(cells, 11, CENTER + Vector2i.LEFT, MapData.WALL)
	_set_cell(cells, 11, CENTER + Vector2i.RIGHT, MapData.WALL)
	var selected: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(MapData.new(11, 11, cells))
	_check(selected.is_empty(), "floor/abyss opposing pairs do not pass the gate")


func _test_catalog_rejects_short_wall_pair() -> void:
	var cells: PackedInt32Array = _filled_cells(11, 11, MapData.ABYSS)
	_set_horizontal_passage(cells, 11, CENTER)
	_set_cell(cells, 11, CENTER + Vector2i.LEFT, MapData.WALL)
	_set_cell(cells, 11, CENTER + Vector2i.RIGHT, MapData.WALL)
	var selected: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(MapData.new(11, 11, cells))
	_check(selected.is_empty(), "gate match without approved greater geometry is rejected")


func _test_spacing() -> void:
	var exact_cells: PackedInt32Array = _filled_cells(14, 11, MapData.ABYSS)
	_set_vertical_reference(exact_cells, 14, Vector2i(4, 5))
	_set_vertical_reference(exact_cells, 14, Vector2i(7, 5))
	var exact_selected: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(
		MapData.new(14, 11, exact_cells)
	)
	_check(exact_selected.size() == 2, "doors at Manhattan distance three are accepted")

	var close_cells: PackedInt32Array = _filled_cells(13, 11, MapData.ABYSS)
	_set_vertical_reference(close_cells, 13, Vector2i(4, 5))
	_set_vertical_reference(close_cells, 13, Vector2i(6, 5))
	var close_selected: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(
		MapData.new(13, 11, close_cells)
	)
	_check(close_selected.size() == 1, "door within three tiles of last accepted door is rejected")
	if close_selected.size() == 1:
		_check(close_selected[0].coordinate == Vector2i(4, 5), "spacing preserves row-major greedy winner")


func _test_input_is_unchanged() -> void:
	var map_data: MapData = _map_with_horizontal_pattern(11, 11, CENTER, REFERENCE_WALLS[7])
	var before: PackedInt32Array = map_data.cells.duplicate()
	DoorwayPlacer.place_doors(map_data)
	_check(map_data.cells == before, "selection does not mutate MapData cells")


func _map_with_horizontal_pattern(
	width: int,
	height: int,
	center: Vector2i,
	required_walls: Array
) -> MapData:
	var cells: PackedInt32Array = _filled_cells(width, height, MapData.ABYSS)
	_set_horizontal_passage(cells, width, center)
	for offset: Vector2i in required_walls:
		_set_cell(cells, width, center + offset, MapData.WALL)
	return MapData.new(width, height, cells)


func _map_with_transformed_pattern(
	width: int,
	height: int,
	center: Vector2i,
	required_walls: Array[Vector2i]
) -> MapData:
	var cells: PackedInt32Array = _filled_cells(width, height, MapData.ABYSS)
	var has_horizontal_wall_pair: bool = (
		required_walls.has(Vector2i.LEFT) and required_walls.has(Vector2i.RIGHT)
	)
	if has_horizontal_wall_pair:
		_set_horizontal_passage(cells, width, center)
	else:
		_set_cell(cells, width, center + Vector2i.LEFT, MapData.FLOOR)
		_set_cell(cells, width, center, MapData.FLOOR)
		_set_cell(cells, width, center + Vector2i.RIGHT, MapData.FLOOR)
	for offset: Vector2i in required_walls:
		_set_cell(cells, width, center + offset, MapData.WALL)
	return MapData.new(width, height, cells)


func _set_horizontal_passage(cells: PackedInt32Array, width: int, center: Vector2i) -> void:
	_set_cell(cells, width, center + Vector2i.UP, MapData.FLOOR)
	_set_cell(cells, width, center, MapData.FLOOR)
	_set_cell(cells, width, center + Vector2i.DOWN, MapData.FLOOR)


func _set_vertical_reference(cells: PackedInt32Array, width: int, center: Vector2i) -> void:
	_set_cell(cells, width, center + Vector2i.LEFT, MapData.FLOOR)
	_set_cell(cells, width, center, MapData.FLOOR)
	_set_cell(cells, width, center + Vector2i.RIGHT, MapData.FLOOR)
	for horizontal_offset: Vector2i in REFERENCE_WALLS[7]:
		var rotated := Vector2i(-horizontal_offset.y, horizontal_offset.x)
		_set_cell(cells, width, center + rotated, MapData.WALL)


func _filled_cells(width: int, height: int, value: int) -> PackedInt32Array:
	var cells := PackedInt32Array()
	cells.resize(width * height)
	cells.fill(value)
	return cells


func _set_cell(cells: PackedInt32Array, width: int, coordinate: Vector2i, value: int) -> void:
	cells[_index(width, coordinate)] = value


func _index(width: int, coordinate: Vector2i) -> int:
	return coordinate.y * width + coordinate.x


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("%s: check failed: %s" % [ORIGIN, description])
