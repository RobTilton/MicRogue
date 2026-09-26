class_name PurposeCoveragePass
extends RefCounted

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/ClaimAndZoning/Implementation/purpose_coverage_pass.gd"


static func run(
	map_data: MapData,
	purpose: LayoutInterpretationSemantics.Purpose,
	purpose_catalog: InitialPurposeCatalog,
	universal_catalog: UniversalAreaCatalog,
	area_catalog: PurposeAreaCatalog,
	random: RandomNumberGenerator = null
) -> PurposeCoverageResult:
	var definition: LayoutPurposeDefinition = purpose_catalog.get_definition(purpose)
	var effective_random: RandomNumberGenerator = random if random != null else RandomNumberGenerator.new()
	if random == null:
		effective_random.randomize()
	var universal: UniversalPassResult = UniversalPass.run(map_data, universal_catalog, effective_random)
	if universal == null:
		return null
	var state: AreaClaimState = universal.claim_state.duplicate_state()
	var claims_by_requirement: Dictionary = {
		&"entrance": PackedInt32Array([universal.entrance_claim.id]),
		&"boss": PackedInt32Array([universal.boss_claim.id]),
	}
	for requirement: LayoutAreaRequirement in definition.requirements:
		var profile: LayoutAreaProfile = area_catalog.get_profile(requirement.area_role)
		var count: int = effective_random.randi_range(requirement.minimum_count, requirement.maximum_count)
		var requirement_claim_ids := PackedInt32Array()
		for instance_index: int in range(count):
			var claim_result: Dictionary = _claim_requirement_instance(
				profile,
				requirement,
				instance_index,
				state,
				claims_by_requirement,
				universal,
				effective_random
			)
			if claim_result.is_empty():
				if requirement_claim_ids.size() >= requirement.minimum_count:
					break
				push_error("%s: required Area '%s' instance %d could not be claimed; purpose result discarded." % [ORIGIN, requirement.id, instance_index])
				return null
			state = claim_result["state"]
			var claim: AreaClaim = claim_result["claim"]
			requirement_claim_ids.append(claim.id)
		claims_by_requirement[requirement.id] = requirement_claim_ids
	_claim_generic_areas(state, area_catalog, effective_random)
	var leftovers: Array[Vector2i] = []
	for coordinate: Vector2i in state.geometry.floor_coordinates:
		if not state.is_claimed(coordinate):
			leftovers.append(coordinate)
	return PurposeCoverageResult.new(
		purpose,
		universal.geometry,
		state,
		universal.entrance_claim,
		universal.boss_claim,
		leftovers
	)


static func _claim_requirement_instance(
	profile: LayoutAreaProfile,
	requirement: LayoutAreaRequirement,
	instance_index: int,
	state: AreaClaimState,
	claims_by_requirement: Dictionary,
	universal: UniversalPassResult,
	random: RandomNumberGenerator
) -> Dictionary:
	var target_claim_ids := PackedInt32Array()
	var candidate_origins: Array[Vector2i] = []
	var progression_target: int = -1
	match requirement.relationship_kind:
		LayoutInterpretationSemantics.RelationshipKind.NONE:
			pass
		LayoutInterpretationSemantics.RelationshipKind.NEAR_AREA:
			var target_claim: AreaClaim = _claim_for_area_role(state, requirement.target_area_role)
			if target_claim == null:
				return {}
			target_claim_ids.append(target_claim.id)
			candidate_origins = _origins_by_distance_to_claims(state.geometry, [target_claim])
		LayoutInterpretationSemantics.RelationshipKind.AROUND_REQUIREMENT, LayoutInterpretationSemantics.RelationshipKind.ADJACENT_REQUIREMENT:
			if not claims_by_requirement.has(requirement.target_requirement_id):
				return {}
			target_claim_ids = claims_by_requirement[requirement.target_requirement_id].duplicate()
			var target_claims: Array[AreaClaim] = []
			for claim_id: int in target_claim_ids:
				var target: AreaClaim = state.get_claim(claim_id)
				if target != null:
					target_claims.append(target)
			candidate_origins = _origins_by_distance_to_claims(state.geometry, target_claims)
		LayoutInterpretationSemantics.RelationshipKind.PROGRESSION_TARGETS:
			progression_target = requirement.progression_targets_percent[min(instance_index, requirement.progression_targets_percent.size() - 1)]
			candidate_origins = _origins_by_progression_target(universal, progression_target)
		_:
			return {}
	var request := AreaClaimRequest.new(
		requirement.id,
		candidate_origins,
		requirement.relationship_kind,
		requirement.relationship_strength,
		target_claim_ids,
		progression_target
	)
	if requirement.relationship_strength == LayoutInterpretationSemantics.RelationshipStrength.REQUIRED and not target_claim_ids.is_empty():
		return _try_required_relationship_claim(profile, request, state, random)
	var claim: AreaClaim = ZoneClaimEngine.try_claim(profile, state, request, random)
	return {"state": state, "claim": claim} if claim != null else {}


static func _try_required_relationship_claim(
	profile: LayoutAreaProfile,
	request: AreaClaimRequest,
	state: AreaClaimState,
	random: RandomNumberGenerator
) -> Dictionary:
	for origin: Vector2i in request.candidate_origins:
		var trial: AreaClaimState = state.duplicate_state()
		var single_request := AreaClaimRequest.new(
			request.requirement_id,
			[origin],
			request.relationship_kind,
			request.relationship_strength,
			request.target_claim_ids,
			request.progression_target_percent
		)
		var claim: AreaClaim = ZoneClaimEngine.try_claim(profile, trial, single_request, random)
		if claim == null:
			continue
		var target_claims: Array[AreaClaim] = []
		for target_id: int in request.target_claim_ids:
			var target: AreaClaim = trial.get_claim(target_id)
			if target != null:
				target_claims.append(target)
		var maximum_distance: int = 1 if request.relationship_kind == LayoutInterpretationSemantics.RelationshipKind.ADJACENT_REQUIREMENT else 2
		if _minimum_claim_distance(claim, target_claims) <= maximum_distance:
			return {"state": trial, "claim": claim}
	return {}


static func _claim_generic_areas(
	state: AreaClaimState,
	area_catalog: PurposeAreaCatalog,
	random: RandomNumberGenerator
) -> void:
	var profile: LayoutAreaProfile = area_catalog.get_profile(LayoutInterpretationSemantics.AreaRole.GENERIC_AREA)
	var maximum_attempts: int = state.geometry.floor_coordinates.size() / 4 + 1
	for index: int in range(maximum_attempts):
		var claim: AreaClaim = ZoneClaimEngine.try_claim(
			profile,
			state,
			AreaClaimRequest.new(&"generic_%d" % index),
			random
		)
		if claim == null:
			return


static func _claim_for_area_role(
	state: AreaClaimState,
	area_role: LayoutInterpretationSemantics.AreaRole
) -> AreaClaim:
	for claim: AreaClaim in state.get_claims():
		if claim.area_role == area_role:
			return claim
	return null


static func _origins_by_distance_to_claims(
	geometry: GeometryAnalysisResult,
	target_claims: Array[AreaClaim]
) -> Array[Vector2i]:
	var distances: Dictionary = _multi_source_distances(geometry, target_claims)
	var origins: Array[Vector2i] = geometry.floor_coordinates.duplicate()
	origins.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var distance_a: int = int(distances[a])
		var distance_b: int = int(distances[b])
		if distance_a == distance_b:
			return a.y < b.y or (a.y == b.y and a.x < b.x)
		return distance_a < distance_b
	)
	return origins


static func _origins_by_progression_target(
	universal: UniversalPassResult,
	target_percent: int
) -> Array[Vector2i]:
	var target_distance: int = roundi(float(universal.maximum_entrance_distance) * float(target_percent) / 100.0)
	var origins: Array[Vector2i] = universal.geometry.floor_coordinates.duplicate()
	origins.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var distance_a: int = int(universal.entrance_distances[a])
		var distance_b: int = int(universal.entrance_distances[b])
		var error_a: int = absi(distance_a - target_distance)
		var error_b: int = absi(distance_b - target_distance)
		if error_a == error_b:
			if distance_a != distance_b:
				return distance_a < distance_b
			return a.y < b.y or (a.y == b.y and a.x < b.x)
		return error_a < error_b
	)
	return origins


static func _multi_source_distances(
	geometry: GeometryAnalysisResult,
	target_claims: Array[AreaClaim]
) -> Dictionary:
	var distances: Dictionary = {}
	var queue: Array[Vector2i] = []
	for claim: AreaClaim in target_claims:
		for coordinate: Vector2i in claim.cells:
			if distances.has(coordinate):
				continue
			distances[coordinate] = 0
			queue.append(coordinate)
	var read_index: int = 0
	while read_index < queue.size():
		var current: Vector2i = queue[read_index]
		read_index += 1
		var next_distance: int = int(distances[current]) + 1
		for neighbor: Vector2i in geometry.cardinal_neighbors(current):
			if distances.has(neighbor):
				continue
			distances[neighbor] = next_distance
			queue.append(neighbor)
	return distances


static func _minimum_claim_distance(
	claim: AreaClaim,
	target_claims: Array[AreaClaim]
) -> int:
	var best: int = 2_147_483_647
	for coordinate: Vector2i in claim.cells:
		for target: AreaClaim in target_claims:
			for target_coordinate: Vector2i in target.cells:
				best = min(best, absi(coordinate.x - target_coordinate.x) + absi(coordinate.y - target_coordinate.y))
	return best
