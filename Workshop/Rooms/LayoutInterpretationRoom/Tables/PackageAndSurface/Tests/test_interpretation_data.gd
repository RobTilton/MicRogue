extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/PackageAndSurface/Tests/test_interpretation_data.gd"

var _checks: int = 0
var _failures: int = 0


func _init() -> void:
	var purpose_catalog: InitialPurposeCatalog = InitialPurposeCatalog.create()
	var universal_catalog: UniversalAreaCatalog = UniversalAreaCatalog.create()
	var area_catalog: PurposeAreaCatalog = PurposeAreaCatalog.create()
	var map_data: MapData = _open_map(35, 35)
	var random := RandomNumberGenerator.new()
	random.seed = 4401
	var result: PurposeCoverageResult = PurposeCoveragePass.run(
		map_data,
		LayoutInterpretationSemantics.Purpose.MAGE_TOWER,
		GenerationSemantics.Scale.MEDIUM,
		purpose_catalog,
		universal_catalog,
		area_catalog,
		random
	)
	_check(result != null, "purpose fixture completes")
	if result != null:
		var data: InterpretationData = InterpretationData.create(map_data, result)
		_test_package(data, map_data, result)
		_test_zone_transfer(data)
		_test_unzoned_transfer(data)
		_test_atomic_refusal(data)
	if _failures == 0:
		print("%s: PASS (%d checks)." % [ORIGIN, _checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)." % [ORIGIN, _failures, _checks])
	quit(1)


func _test_package(data: InterpretationData, map_data: MapData, result: PurposeCoverageResult) -> void:
	_check(data.map_data == map_data, "package carries exact MapData object")
	_check(data.purpose == result.purpose, "purpose is preserved")
	_check(data.entrance_zone_id == result.entrance_claim.id, "Entrance Zone ID is preserved")
	_check(data.boss_zone_id == result.boss_claim.id, "Boss Zone ID is preserved")
	_check(data.get_zone_ids().size() == result.claim_state.get_claims().size(), "every claim becomes one Zone record")
	_check(data.get_zone_overlay().size() == map_data.cells.size(), "ownership overlay matches map dimensions")
	_check(is_equal_approx(data.coverage_ratio, result.coverage_ratio), "coverage is preserved")
	_check(data.unzoned_floor == result.unzoned_floor, "unzoned floor is preserved")
	var boss: InterpretationZone = data.get_zone(data.boss_zone_id)
	_check(boss.area_role == result.boss_claim.area_role, "Zone role is preserved")
	_check(boss.tags == result.boss_claim.tags, "Zone tags are preserved")
	_check(boss.get_coordinates() == result.boss_claim.cells, "Zone coordinates are preserved")
	_check(_membership_agrees(data), "overlay and Zone coordinates agree")
	var detached_overlay: PackedInt32Array = data.get_zone_overlay()
	detached_overlay.fill(99)
	_check(data.get_zone_id_at(result.entrance_claim.cells.front()) == data.entrance_zone_id, "returned overlay cannot desynchronize ownership")


func _test_zone_transfer(data: InterpretationData) -> void:
	var source: InterpretationZone = data.get_zone(data.entrance_zone_id)
	var destination: InterpretationZone = data.get_zone(data.boss_zone_id)
	var moved: Array[Vector2i] = source.get_coordinates()
	var destination_count: int = destination.coordinate_count()
	_check(data.reassign_cells(moved, destination.id), "bulk Zone-to-Zone transfer succeeds")
	_check(source.coordinate_count() == 0, "source Zone remains represented and becomes empty")
	_check(source.bounds == Rect2i(), "empty source bounds refresh")
	_check(destination.coordinate_count() == destination_count + moved.size(), "destination receives every transferred coordinate")
	_check(data.get_zone_id_at(moved.front()) == destination.id, "overlay reflects Zone transfer")
	_check(_membership_agrees(data), "membership agrees after Zone transfer")


func _test_unzoned_transfer(data: InterpretationData) -> void:
	_check(not data.unzoned_floor.is_empty(), "fixture exposes unzoned floor")
	if data.unzoned_floor.is_empty():
		return
	var coordinate: Vector2i = data.unzoned_floor.front()
	var before_coverage: float = data.coverage_ratio
	_check(data.reassign_cells([coordinate], data.boss_zone_id), "unzoned floor can be assigned")
	_check(data.get_zone_id_at(coordinate) == data.boss_zone_id, "assigned floor receives destination ownership")
	_check(coordinate not in data.unzoned_floor, "assigned floor leaves unzoned collection")
	_check(data.coverage_ratio > before_coverage, "coverage increases when unzoned floor is assigned")
	_check(data.reassign_cells([coordinate], 0), "owned floor can return to unzoned")
	_check(data.get_zone_id_at(coordinate) == 0, "unzoned transfer clears overlay ownership")
	_check(coordinate in data.unzoned_floor, "released floor enters unzoned collection")
	_check(is_equal_approx(data.coverage_ratio, before_coverage), "coverage restores after release")


func _test_atomic_refusal(data: InterpretationData) -> void:
	var overlay_before: PackedInt32Array = data.get_zone_overlay()
	var boss_before: Array[Vector2i] = data.get_zone(data.boss_zone_id).get_coordinates()
	_check(not data.reassign_cells([boss_before.front(), Vector2i(-1, -1)], data.entrance_zone_id), "invalid bulk transfer is refused")
	_check(data.get_zone_overlay() == overlay_before, "refused transfer leaves overlay unchanged")
	_check(data.get_zone(data.boss_zone_id).get_coordinates() == boss_before, "refused transfer leaves Zone coordinates unchanged")
	_check(not data.reassign_cells([boss_before.front()], 99999), "missing destination is refused")
	_check(data.get_zone_overlay() == overlay_before, "missing-destination refusal is atomic")


func _membership_agrees(data: InterpretationData) -> bool:
	var seen: Dictionary = {}
	for zone_id: int in data.get_zone_ids():
		var zone: InterpretationZone = data.get_zone(zone_id)
		for coordinate: Vector2i in zone.get_coordinates():
			if seen.has(coordinate) or data.get_zone_id_at(coordinate) != zone_id:
				return false
			seen[coordinate] = true
	return true


func _open_map(width: int, height: int) -> MapData:
	var cells := PackedInt32Array()
	for y: int in range(height):
		for x: int in range(width):
			var boundary: bool = x == 0 or y == 0 or x == width - 1 or y == height - 1
			cells.append(MapData.WALL if boundary else MapData.FLOOR)
	return MapData.new(width, height, cells)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("%s: check failed: %s." % [ORIGIN, message])
