extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/ClaimAndZoning/Tests/test_purpose_coverage_pass.gd"

var _checks: int = 0
var _failures: int = 0


func _init() -> void:
	var purpose_catalog: InitialPurposeCatalog = InitialPurposeCatalog.create()
	var universal_catalog: UniversalAreaCatalog = UniversalAreaCatalog.create()
	var area_catalog: PurposeAreaCatalog = PurposeAreaCatalog.create()
	_check(purpose_catalog != null, "Purpose Catalog exists")
	_check(universal_catalog != null, "Universal Area Catalog exists")
	_check(area_catalog != null, "Purpose Area Catalog exists")
	if purpose_catalog != null and universal_catalog != null and area_catalog != null:
		_test_all_purposes(purpose_catalog, universal_catalog, area_catalog)
		_test_required_failure_is_atomic(purpose_catalog, universal_catalog, area_catalog)
	if _failures == 0:
		print("%s: PASS (%d checks)." % [ORIGIN, _checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)." % [ORIGIN, _failures, _checks])
	quit(1)


func _test_all_purposes(
	purpose_catalog: InitialPurposeCatalog,
	universal_catalog: UniversalAreaCatalog,
	area_catalog: PurposeAreaCatalog
) -> void:
	for purpose: LayoutInterpretationSemantics.Purpose in LayoutInterpretationSemantics.required_purposes():
		var map_data: MapData = _open_map(45, 45)
		var original_cells: PackedInt32Array = map_data.cells.duplicate()
		var random := RandomNumberGenerator.new()
		random.seed = 9000 + purpose
		var result: PurposeCoverageResult = PurposeCoveragePass.run(
			map_data,
			purpose,
			purpose_catalog,
			universal_catalog,
			area_catalog,
			random
		)
		_check(result != null, "purpose %d completes" % purpose)
		if result == null:
			continue
		_check(result.purpose == purpose, "purpose %d identity is preserved" % purpose)
		_check(_count_role(result, LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA) == 1, "purpose %d has one Entrance" % purpose)
		_check(_count_role(result, LayoutInterpretationSemantics.AreaRole.BOSS_AREA) == 1, "purpose %d has one Boss" % purpose)
		_check(_count_role(result, LayoutInterpretationSemantics.AreaRole.GENERIC_AREA) > 0, "purpose %d has Generic Areas" % purpose)
		_check(_generic_claims_respect_cap(result), "purpose %d Generic Areas respect 30-tile cap" % purpose)
		_check(not _has_unclaimed_two_by_two(result), "purpose %d leaves no claimable 2x2 remainder" % purpose)
		_check(result.coverage_ratio > 0.0 and result.coverage_ratio <= 1.0, "purpose %d coverage ratio is valid" % purpose)
		_check(map_data.cells == original_cells, "purpose %d does not mutate MapData" % purpose)
		_check(_claims_are_exclusive(result), "purpose %d claims remain exclusive" % purpose)
		_check(_required_counts_match(result, purpose_catalog.get_definition(purpose)), "purpose %d required counts match selected ranges" % purpose)
		_check(_required_relationships_resolve(result), "purpose %d required relationship metadata resolves" % purpose)
		_check(_progression_claims_follow_distance_bands(result), "purpose %d progression claims follow Entrance-distance bands" % purpose)
		if purpose == LayoutInterpretationSemantics.Purpose.MINE_SHAFT:
			_check(_progression_targets(result, &"equipment_storage") == PackedInt32Array([35, 70]), "Mine equipment progression metadata matches")


func _test_required_failure_is_atomic(
	purpose_catalog: InitialPurposeCatalog,
	universal_catalog: UniversalAreaCatalog,
	area_catalog: PurposeAreaCatalog
) -> void:
	var map_data: MapData = _open_map(13, 13)
	var original_cells: PackedInt32Array = map_data.cells.duplicate()
	var result: PurposeCoverageResult = PurposeCoveragePass.run(
		map_data,
		LayoutInterpretationSemantics.Purpose.GUARD_TOWER,
		purpose_catalog,
		universal_catalog,
		area_catalog,
		RandomNumberGenerator.new()
	)
	_check(result == null, "unsatisfied Guard Tower returns no partial result")
	_check(map_data.cells == original_cells, "failed purpose pass does not mutate MapData")


func _count_role(
	result: PurposeCoverageResult,
	area_role: LayoutInterpretationSemantics.AreaRole
) -> int:
	var count: int = 0
	for claim: AreaClaim in result.claim_state.get_claims():
		if claim.area_role == area_role:
			count += 1
	return count


func _generic_claims_respect_cap(result: PurposeCoverageResult) -> bool:
	for claim: AreaClaim in result.claim_state.get_claims():
		if claim.area_role == LayoutInterpretationSemantics.AreaRole.GENERIC_AREA and claim.cells.size() > 30:
			return false
	return true


func _has_unclaimed_two_by_two(result: PurposeCoverageResult) -> bool:
	var leftovers: Dictionary = {}
	for coordinate: Vector2i in result.unzoned_floor:
		leftovers[coordinate] = true
	for coordinate: Vector2i in result.unzoned_floor:
		if leftovers.has(coordinate + Vector2i.RIGHT) and leftovers.has(coordinate + Vector2i.DOWN) and leftovers.has(coordinate + Vector2i.ONE):
			return true
	return false


func _claims_are_exclusive(result: PurposeCoverageResult) -> bool:
	var seen: Dictionary = {}
	for claim: AreaClaim in result.claim_state.get_claims():
		for coordinate: Vector2i in claim.cells:
			if seen.has(coordinate):
				return false
			seen[coordinate] = claim.id
	return seen.size() == result.claim_state.claimed_tile_count()


func _required_counts_match(
	result: PurposeCoverageResult,
	definition: LayoutPurposeDefinition
) -> bool:
	for requirement: LayoutAreaRequirement in definition.requirements:
		var count: int = 0
		for claim: AreaClaim in result.claim_state.get_claims():
			if claim.requirement_id == requirement.id:
				count += 1
		if count < requirement.minimum_count or count > requirement.maximum_count:
			return false
	return true


func _required_relationships_resolve(result: PurposeCoverageResult) -> bool:
	for claim: AreaClaim in result.claim_state.get_claims():
		if claim.relationship_strength != LayoutInterpretationSemantics.RelationshipStrength.REQUIRED:
			continue
		if claim.target_claim_ids.is_empty():
			return false
		for target_id: int in claim.target_claim_ids:
			if result.claim_state.get_claim(target_id) == null:
				return false
	return true


func _progression_targets(
	result: PurposeCoverageResult,
	requirement_id: StringName
) -> PackedInt32Array:
	var targets := PackedInt32Array()
	for claim: AreaClaim in result.claim_state.get_claims():
		if claim.requirement_id == requirement_id:
			targets.append(claim.progression_target_percent)
	return targets


func _progression_claims_follow_distance_bands(result: PurposeCoverageResult) -> bool:
	var distances: Dictionary = result.geometry.distance_map_from_many(result.entrance_claim.cells)
	var maximum_distance: int = 0
	for distance: Variant in distances.values():
		maximum_distance = max(maximum_distance, int(distance))
	var tolerance: int = maxi(4, ceili(float(maximum_distance) * 0.15))
	for claim: AreaClaim in result.claim_state.get_claims():
		if claim.progression_target_percent < 0:
			continue
		var target: int = roundi(float(maximum_distance) * float(claim.progression_target_percent) / 100.0)
		if absi(int(distances[claim.origin]) - target) > tolerance:
			return false
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
