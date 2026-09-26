extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/PackageAndSurface/Tests/test_layout_interpreter.gd"

var _checks: int = 0
var _failures: int = 0


func _init() -> void:
	_test_public_composition()
	_test_failure_surface()
	if _failures == 0:
		print("%s: PASS (%d checks)." % [ORIGIN, _checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)." % [ORIGIN, _failures, _checks])
	quit(1)


func _test_public_composition() -> void:
	var map_data: MapData = _open_map(45, 45, true)
	var original_cells: PackedInt32Array = map_data.cells.duplicate()
	var started_microseconds: int = Time.get_ticks_usec()
	var data: InterpretationData = LayoutInterpreter.interpret(
		map_data,
		LayoutInterpretationSemantics.Purpose.MAGE_TOWER
	)
	var elapsed_microseconds: int = Time.get_ticks_usec() - started_microseconds
	_check(data != null, "public interpretation succeeds")
	if data == null:
		return
	_check(data.map_data == map_data, "public result carries exact MapData")
	_check(map_data.cells == original_cells, "public call preserves physical cells")
	_check(data.purpose == LayoutInterpretationSemantics.Purpose.MAGE_TOWER, "public result preserves purpose")
	_check(data.get_zone(data.entrance_zone_id).area_role == LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA, "public result identifies Entrance")
	_check(data.get_zone(data.boss_zone_id).area_role == LayoutInterpretationSemantics.AreaRole.BOSS_AREA, "public result identifies Boss")
	_check(data.get_zone_ids().size() > 5, "public result contains composed purpose and Generic Zones")
	_check(data.get_zone_overlay().size() == map_data.cells.size(), "public result contains complete ownership overlay")
	_check(data.coverage_ratio > 0.0 and data.coverage_ratio <= 1.0, "public result exposes valid coverage")
	print("%s: public 45x45 interpretation completed in %d microseconds." % [ORIGIN, elapsed_microseconds])


func _test_failure_surface() -> void:
	var map_data: MapData = _open_map(9, 9, false)
	var original_cells: PackedInt32Array = map_data.cells.duplicate()
	var data: InterpretationData = LayoutInterpreter.interpret(
		map_data,
		LayoutInterpretationSemantics.Purpose.MAGE_TOWER
	)
	_check(data == null, "unsatisfied interpretation returns null")
	_check(map_data.cells == original_cells, "failed public call preserves physical cells")


func _open_map(width: int, height: int, with_walls: bool) -> MapData:
	var cells := PackedInt32Array()
	for y: int in range(height):
		for x: int in range(width):
			var boundary: bool = x == 0 or y == 0 or x == width - 1 or y == height - 1
			cells.append(MapData.WALL if with_walls and boundary else MapData.FLOOR)
	return MapData.new(width, height, cells)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("%s: check failed: %s." % [ORIGIN, message])
