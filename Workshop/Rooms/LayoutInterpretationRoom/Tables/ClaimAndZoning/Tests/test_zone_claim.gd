extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/ClaimAndZoning/Tests/test_zone_claim.gd"

var _checks: int = 0
var _failures: int = 0


func _init() -> void:
	var universal_catalog: UniversalAreaCatalog = UniversalAreaCatalog.create()
	var purpose_catalog: PurposeAreaCatalog = PurposeAreaCatalog.create()
	_check(universal_catalog != null, "Universal Area Catalog exists")
	_check(purpose_catalog != null, "Purpose Area Catalog exists")
	if universal_catalog != null and purpose_catalog != null:
		_test_exact_non_growing_claim(universal_catalog)
		_test_growth_caps_and_bounds(universal_catalog, purpose_catalog)
		_test_exclusive_ownership_and_atomic_failure(purpose_catalog)
		_test_generic_narrow_growth(purpose_catalog)
		_test_detached_claim_outputs(purpose_catalog)
	if _failures == 0:
		print("%s: PASS (%d checks)." % [ORIGIN, _checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)." % [ORIGIN, _failures, _checks])
	quit(1)


func _test_exact_non_growing_claim(universal_catalog: UniversalAreaCatalog) -> void:
	var map_data: MapData = _open_map(15, 15)
	var original_cells: PackedInt32Array = map_data.cells.duplicate()
	var state: AreaClaimState = _state_for(map_data)
	_check(state != null, "Entrance fixture has valid claim state")
	if state == null:
		return
	var random := RandomNumberGenerator.new()
	random.seed = 11
	var claim: AreaClaim = ZoneClaimEngine.try_claim(
		universal_catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA),
		state,
		AreaClaimRequest.new(&"entrance", [Vector2i(2, 2)]),
		random
	)
	_check(claim != null, "Entrance claim succeeds at valid cleared origin")
	if claim == null:
		return
	_check(claim.cells.size() == 8 or claim.cells.size() == 9, "Entrance remains one exact minimum footprint")
	_check(claim.area_role == LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA, "Entrance role is preserved")
	_check(claim.requirement_id == &"entrance", "Entrance requirement identity is preserved")
	_check(claim.tags == [LayoutAreaSemantics.Tag.ENTRANCE, LayoutAreaSemantics.Tag.NO_ENEMY, LayoutAreaSemantics.Tag.LIGHT], "Entrance tags are preserved")
	_check(state.claimed_tile_count() == claim.cells.size(), "claim state records exact Entrance membership")
	_check(map_data.cells == original_cells, "Entrance claim does not mutate MapData")


func _test_growth_caps_and_bounds(
	universal_catalog: UniversalAreaCatalog,
	purpose_catalog: PurposeAreaCatalog
) -> void:
	var state: AreaClaimState = _state_for(_open_map(25, 25))
	_check(state != null, "growth fixture has valid claim state")
	if state == null:
		return
	var random := RandomNumberGenerator.new()
	random.seed = 22
	var boss: AreaClaim = ZoneClaimEngine.try_claim(
		universal_catalog.get_profile(LayoutInterpretationSemantics.AreaRole.BOSS_AREA),
		state,
		AreaClaimRequest.new(&"boss", [Vector2i(18, 18)]),
		random
	)
	_check(boss != null, "Boss flood claim succeeds")
	if boss != null:
		_check(boss.cells.size() == 50, "Boss flood stops at 50 tiles")
		_check(boss.bounds.size.x <= 8 and boss.bounds.size.y <= 8, "Boss flood stays inside 8x8")

	var library: AreaClaim = ZoneClaimEngine.try_claim(
		purpose_catalog.get_profile(LayoutInterpretationSemantics.AreaRole.LIBRARY_AREA),
		state,
		AreaClaimRequest.new(&"library", [Vector2i(6, 6)]),
		random
	)
	_check(library != null, "Library claim succeeds")
	if library != null:
		_check(library.cells.size() <= 24, "Library respects tile cap")
		_check((library.bounds.size.x <= 4 and library.bounds.size.y <= 8) or (library.bounds.size.x <= 8 and library.bounds.size.y <= 4), "Library respects rotating 4x8 window")


func _test_exclusive_ownership_and_atomic_failure(purpose_catalog: PurposeAreaCatalog) -> void:
	var universal_catalog: UniversalAreaCatalog = UniversalAreaCatalog.create()
	var state: AreaClaimState = _state_for(_open_map(17, 17))
	_check(state != null, "ownership fixture has valid claim state")
	if state == null:
		return
	var random := RandomNumberGenerator.new()
	random.seed = 33
	var shrine: AreaClaim = ZoneClaimEngine.try_claim(
		purpose_catalog.get_profile(LayoutInterpretationSemantics.AreaRole.SHRINE_AREA),
		state,
		AreaClaimRequest.new(&"shrine", [Vector2i(5, 5)]),
		random
	)
	_check(shrine != null, "first exclusive claim succeeds")
	if shrine == null:
		return
	var before_failure: int = state.claimed_tile_count()
	var overlap: AreaClaim = state.apply_complete_claim(
		LayoutInterpretationSemantics.AreaRole.DEPOT_AREA,
		&"overlap",
		shrine.origin,
		shrine.cells,
		[]
	)
	_check(overlap == null, "overlapping direct claim is refused")
	_check(state.claimed_tile_count() == before_failure, "overlap refusal leaves state unchanged")

	var impossible: AreaClaim = ZoneClaimEngine.try_claim(
		purpose_catalog.get_profile(LayoutInterpretationSemantics.AreaRole.DEPOT_AREA),
		state,
		AreaClaimRequest.new(&"impossible", [Vector2i(1, 1)]),
		random
	)
	_check(impossible == null, "invalid fixed origin returns no claim")
	_check(state.claimed_tile_count() == before_failure, "failed engine claim leaves state unchanged")


func _test_generic_narrow_growth(purpose_catalog: PurposeAreaCatalog) -> void:
	var universal_catalog: UniversalAreaCatalog = UniversalAreaCatalog.create()
	var map_data: MapData = _map_from_rows([
		"#################",
		"#....#######....#",
		"#....#######....#",
		"#...............#",
		"#....#######....#",
		"#################",
	])
	var state: AreaClaimState = _state_for(map_data)
	_check(state != null, "narrow-growth fixture has valid claim state")
	if state == null:
		return
	var random := RandomNumberGenerator.new()
	random.seed = 44
	var generic: AreaClaim = ZoneClaimEngine.try_claim(
		purpose_catalog.get_profile(LayoutInterpretationSemantics.AreaRole.GENERIC_AREA),
		state,
		AreaClaimRequest.new(&"generic", [Vector2i(2, 2)]),
		random
	)
	_check(generic != null, "Generic claim succeeds")
	if generic == null:
		return
	_check(generic.cells.size() == 30, "Generic claim stops at 30 tiles")
	var reaches_right_side: bool = false
	for coordinate: Vector2i in generic.cells:
		if coordinate.x >= 12:
			reaches_right_side = true
			break
	_check(reaches_right_side, "Generic claim may traverse one-tile chain")


func _test_detached_claim_outputs(purpose_catalog: PurposeAreaCatalog) -> void:
	var universal_catalog: UniversalAreaCatalog = UniversalAreaCatalog.create()
	var state: AreaClaimState = _state_for(_open_map(15, 15))
	_check(state != null, "detached-output fixture has valid claim state")
	if state == null:
		return
	var claim: AreaClaim = ZoneClaimEngine.try_claim(
		purpose_catalog.get_profile(LayoutInterpretationSemantics.AreaRole.CELL_AREA),
		state,
		AreaClaimRequest.new(&"cells", [Vector2i(4, 4)]),
		RandomNumberGenerator.new()
	)
	_check(claim != null, "Cell Area claim succeeds")
	if claim == null:
		return
	var stored_size: int = claim.cells.size()
	claim.cells.clear()
	claim.tags.append(LayoutAreaSemantics.Tag.BOSS)
	var stored: AreaClaim = state.get_claim(claim.id)
	_check(stored.cells.size() == stored_size, "returned claim cells are detached")
	_check(LayoutAreaSemantics.Tag.BOSS not in stored.tags, "returned claim tags are detached")
	var all_claims: Array[AreaClaim] = state.get_claims()
	all_claims.clear()
	_check(state.get_claims().size() == 1, "claim collection is detached")


func _state_for(map_data: MapData) -> AreaClaimState:
	return AreaClaimState.new(LayoutGeometryAnalyzer.analyze(map_data))


func _open_map(width: int, height: int) -> MapData:
	var cells := PackedInt32Array()
	for y: int in range(height):
		for x: int in range(width):
			var boundary: bool = x == 0 or y == 0 or x == width - 1 or y == height - 1
			cells.append(MapData.WALL if boundary else MapData.FLOOR)
	return MapData.new(width, height, cells)


func _map_from_rows(rows: Array[String]) -> MapData:
	var width: int = rows.front().length()
	var cells := PackedInt32Array()
	for row: String in rows:
		for character: String in row:
			cells.append(MapData.FLOOR if character == "." else MapData.WALL)
	return MapData.new(width, rows.size(), cells)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("%s: check failed: %s." % [ORIGIN, message])
