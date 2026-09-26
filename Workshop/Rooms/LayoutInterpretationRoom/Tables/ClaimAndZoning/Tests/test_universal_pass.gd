extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/ClaimAndZoning/Tests/test_universal_pass.gd"

var _checks: int = 0
var _failures: int = 0


func _init() -> void:
	var catalog: UniversalAreaCatalog = UniversalAreaCatalog.create()
	_check(catalog != null, "Universal Area Catalog exists")
	if catalog != null:
		_test_entrance_first_and_distant_boss(catalog)
		_test_seeded_entrance_selection(catalog)
		_test_all_or_nothing_failure(catalog)
		_test_production_map_composition(catalog)
	if _failures == 0:
		print("%s: PASS (%d checks)." % [ORIGIN, _checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)." % [ORIGIN, _failures, _checks])
	quit(1)


func _test_entrance_first_and_distant_boss(catalog: UniversalAreaCatalog) -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 101
	var result: UniversalPassResult = UniversalPass.run(_open_map(25, 25, true), catalog, random)
	_check(result != null, "universal pass succeeds")
	if result == null:
		return
	_check(result.entrance_claim.area_role == LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA, "Entrance role matches")
	_check(result.boss_claim.area_role == LayoutInterpretationSemantics.AreaRole.BOSS_AREA, "Boss role matches")
	_check(result.claim_state.get_claims().size() == 2, "universal state contains exactly two claims")
	_check(result.entrance_claim.cells.size() == 8 or result.entrance_claim.cells.size() == 9, "Entrance remains minimum footprint")
	_check(result.boss_claim.cells.size() <= 50, "Boss respects tile cap")
	_check(_claims_do_not_overlap(result.entrance_claim, result.boss_claim), "Entrance and Boss do not overlap")
	_check(result.entrance_distances.size() == result.geometry.floor_coordinates.size(), "single Entrance flood covers contracted floor")
	_check(_claim_max_distance(result.boss_claim, result.entrance_distances) >= result.maximum_entrance_distance - 2, "Boss begins at the farthest usable distance band")


func _test_seeded_entrance_selection(catalog: UniversalAreaCatalog) -> void:
	var first_random := RandomNumberGenerator.new()
	first_random.seed = 1
	var second_random := RandomNumberGenerator.new()
	second_random.seed = 2
	var first: UniversalPassResult = UniversalPass.run(_open_map(17, 17, true), catalog, first_random)
	var second: UniversalPassResult = UniversalPass.run(_open_map(17, 17, true), catalog, second_random)
	_check(first != null and second != null, "seeded universal passes succeed")
	if first == null or second == null:
		return
	_check(first.entrance_claim.origin != second.entrance_claim.origin, "seeded ties can choose different valid Entrances")


func _test_all_or_nothing_failure(catalog: UniversalAreaCatalog) -> void:
	var result: UniversalPassResult = UniversalPass.run(_open_map(9, 9, false), catalog, RandomNumberGenerator.new())
	_check(result == null, "map without wall-adjacent Entrance returns no universal result")


func _test_production_map_composition(catalog: UniversalAreaCatalog) -> void:
	var map_data: MapData = GeneratorCaller.make_map(
		MapParameters.new(
			GenerationSemantics.Archetype.DUNGEON,
			GenerationSemantics.Scale.MEDIUM,
			GenerationSemantics.GeometryModifier.STANDARD
		)
	)
	_check(map_data != null, "Production generator returns medium Dungeon")
	if map_data == null:
		return
	var original_cells: PackedInt32Array = map_data.cells.duplicate()
	var result: UniversalPassResult = UniversalPass.run(map_data, catalog, RandomNumberGenerator.new())
	_check(result != null, "Production Dungeon receives universal Areas")
	if result == null:
		return
	_check(result.claim_state.get_claims().size() == 2, "Production universal result contains two claims")
	_check(map_data.cells == original_cells, "Production MapData remains unchanged")


func _claim_max_distance(claim: AreaClaim, distances: Dictionary) -> int:
	var maximum: int = 0
	for coordinate: Vector2i in claim.cells:
		maximum = max(maximum, int(distances[coordinate]))
	return maximum


func _claims_do_not_overlap(first: AreaClaim, second: AreaClaim) -> bool:
	var first_lookup: Dictionary = {}
	for coordinate: Vector2i in first.cells:
		first_lookup[coordinate] = true
	for coordinate: Vector2i in second.cells:
		if first_lookup.has(coordinate):
			return false
	return true


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
