class_name UniversalPass
extends RefCounted

const ORIGIN: String = "Production/Systems/LayoutInterpretationSystem/ClaimAndZoning/universal_pass.gd"


static func run(
	map_data: MapData,
	universal_catalog: UniversalAreaCatalog,
	random: RandomNumberGenerator = null
) -> UniversalPassResult:
	var effective_random: RandomNumberGenerator = random if random != null else RandomNumberGenerator.new()
	if random == null:
		effective_random.randomize()
	var geometry: GeometryAnalysisResult = LayoutGeometryAnalyzer.analyze(map_data)
	var state := AreaClaimState.new(geometry)
	var entrance: AreaClaim = ZoneClaimEngine.try_claim(
		universal_catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA),
		state,
		AreaClaimRequest.new(&"entrance"),
		effective_random
	)
	if entrance == null:
		push_error("%s: failed to claim Entrance Area." % ORIGIN)
		return null
	var entrance_distances: Dictionary = geometry.distance_map_from_many(entrance.cells)
	var maximum_entrance_distance: int = _maximum_distance(entrance_distances)
	var boss_origins: Array[Vector2i] = geometry.floor_coordinates.duplicate()
	boss_origins.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var distance_a: int = int(entrance_distances[a])
		var distance_b: int = int(entrance_distances[b])
		if distance_a == distance_b:
			return a.y < b.y or (a.y == b.y and a.x < b.x)
		return distance_a > distance_b
	)
	var boss: AreaClaim = ZoneClaimEngine.try_claim(
		_seed_only_profile(universal_catalog.get_profile(LayoutInterpretationSemantics.AreaRole.BOSS_AREA)),
		state,
		AreaClaimRequest.new(&"boss", boss_origins),
		effective_random
	)
	if boss == null:
		push_error("%s: failed to claim Boss Area; universal result discarded." % ORIGIN)
		return null
	return UniversalPassResult.new(
		geometry,
		state,
		entrance,
		boss,
		entrance_distances,
		maximum_entrance_distance
	)


static func _maximum_distance(distances: Dictionary) -> int:
	var maximum: int = 0
	for distance: Variant in distances.values():
		maximum = max(maximum, int(distance))
	return maximum


static func _seed_only_profile(profile: LayoutAreaProfile) -> LayoutAreaProfile:
	return LayoutAreaProfile.new(
		profile.area_role,
		profile.minimum_footprints,
		LayoutAreaSemantics.GrowthMode.NONE,
		0,
		Vector2i.ZERO,
		false,
		false,
		profile.minimum_wall_adjacent_sides,
		profile.preferred_wall_adjacent_sides,
		profile.preferences,
		profile.tags
	)
