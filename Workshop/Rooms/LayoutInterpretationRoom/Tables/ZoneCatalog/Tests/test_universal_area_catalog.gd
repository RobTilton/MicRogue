extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/ZoneCatalog/Tests/test_universal_area_catalog.gd"

var _checks: int = 0
var _failures: int = 0


func _init() -> void:
	var catalog: UniversalAreaCatalog = UniversalAreaCatalog.create()
	_check(catalog != null, "catalog creation succeeds")
	if catalog != null:
		_test_complete_roles(catalog)
		_test_entrance(catalog)
		_test_boss(catalog)
		_test_endpoint_policy(catalog)
		_test_detached_lookup(catalog)
		_test_unsupported_lookup(catalog)
		_test_malformed_profile_refusal(catalog)
	if _failures == 0:
		print("%s: PASS (%d checks)." % [ORIGIN, _checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)." % [ORIGIN, _failures, _checks])
	quit(1)


func _test_complete_roles(catalog: UniversalAreaCatalog) -> void:
	_check(catalog.has_profile(LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA), "catalog contains Entrance")
	_check(catalog.has_profile(LayoutInterpretationSemantics.AreaRole.BOSS_AREA), "catalog contains Boss")
	_check(not catalog.has_profile(LayoutInterpretationSemantics.AreaRole.GENERIC_AREA), "catalog excludes non-universal Areas")


func _test_entrance(catalog: UniversalAreaCatalog) -> void:
	var profile: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA)
	_check(profile != null, "Entrance profile exists")
	if profile == null:
		return
	_check(profile.minimum_footprints == [Vector2i(2, 4), Vector2i(4, 2), Vector2i(3, 3)], "Entrance footprints match")
	_check(profile.growth_mode == LayoutAreaSemantics.GrowthMode.NONE, "Entrance does not grow")
	_check(profile.maximum_claimed_tiles == 0, "Entrance has no growth tile cap")
	_check(profile.maximum_bounding_size == Vector2i.ZERO, "Entrance has no growth window")
	_check(not profile.permits_narrow_connections, "Entrance does not cross narrow connections")
	_check(profile.minimum_wall_adjacent_sides == 1, "Entrance requires one wall-adjacent side")
	_check(profile.preferred_wall_adjacent_sides == 2, "Entrance prefers two wall-adjacent sides")
	_check(profile.preferences == [LayoutAreaSemantics.Preference.WALL_ADJACENCY], "Entrance preferences match")
	_check(profile.tags == [LayoutAreaSemantics.Tag.ENTRANCE, LayoutAreaSemantics.Tag.NO_ENEMY, LayoutAreaSemantics.Tag.LIGHT], "Entrance tags match")


func _test_boss(catalog: UniversalAreaCatalog) -> void:
	var profile: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.BOSS_AREA)
	_check(profile != null, "Boss profile exists")
	if profile == null:
		return
	_check(profile.minimum_footprints == [Vector2i(3, 3)], "Boss footprint matches")
	_check(profile.growth_mode == LayoutAreaSemantics.GrowthMode.FLOOD, "Boss uses flood growth")
	_check(profile.maximum_claimed_tiles == 50, "Boss tile cap matches")
	_check(profile.maximum_bounding_size == Vector2i(8, 8), "Boss bounding window matches")
	_check(profile.permits_narrow_connections, "Boss may cross narrow connections")
	_check(profile.minimum_wall_adjacent_sides == 0, "Boss has no wall minimum")
	_check(profile.preferred_wall_adjacent_sides == 0, "Boss has no wall preference")
	_check(profile.preferences == [LayoutAreaSemantics.Preference.LARGEST_USABLE_CONNECTED_SPACE, LayoutAreaSemantics.Preference.SINGLE_OPEN_AREA], "Boss preferences match")
	_check(profile.tags == [LayoutAreaSemantics.Tag.BOSS, LayoutAreaSemantics.Tag.LIGHT], "Boss tags match")


func _test_endpoint_policy(catalog: UniversalAreaCatalog) -> void:
	var policy: UniversalEndpointPolicy = catalog.get_endpoint_policy()
	_check(policy != null, "endpoint policy exists")
	if policy == null:
		return
	_check(policy.connectivity == LayoutAreaSemantics.Connectivity.CARDINAL_FOUR, "endpoint connectivity is cardinal")
	_check(policy.route_selection == LayoutAreaSemantics.RouteSelection.LONGEST_QUALIFYING_NAVIGABLE_ROUTE, "endpoint route selection matches")
	_check(policy.minimum_endpoint_footprints == [Vector2i(3, 3), Vector2i(4, 2), Vector2i(2, 4)], "endpoint minimum footprints match")
	_check(policy.undersized_endpoint_policy == LayoutAreaSemantics.UndersizedEndpointPolicy.MOVE_INWARD_TO_NEXT_QUALIFYING_AREA, "undersized endpoint moves inward")
	_check(policy.endpoint_assignment == LayoutAreaSemantics.EndpointAssignment.SMALLER_TO_ENTRANCE_LARGER_TO_BOSS, "endpoint assignment matches")
	_check(policy.equal_endpoint_policy == LayoutAreaSemantics.EqualEndpointPolicy.RANDOM_COIN_FLIP, "equal endpoints use coin flip")


func _test_detached_lookup(catalog: UniversalAreaCatalog) -> void:
	var first_profile: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA)
	first_profile.minimum_footprints.append(Vector2i(99, 99))
	first_profile.tags.clear()
	var second_profile: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA)
	_check(second_profile.minimum_footprints == [Vector2i(2, 4), Vector2i(4, 2), Vector2i(3, 3)], "profile footprints are detached")
	_check(second_profile.tags == [LayoutAreaSemantics.Tag.ENTRANCE, LayoutAreaSemantics.Tag.NO_ENEMY, LayoutAreaSemantics.Tag.LIGHT], "profile tags are detached")
	var first_policy: UniversalEndpointPolicy = catalog.get_endpoint_policy()
	first_policy.minimum_endpoint_footprints.clear()
	var second_policy: UniversalEndpointPolicy = catalog.get_endpoint_policy()
	_check(second_policy.minimum_endpoint_footprints == [Vector2i(3, 3), Vector2i(4, 2), Vector2i(2, 4)], "endpoint policy is detached")


func _test_unsupported_lookup(catalog: UniversalAreaCatalog) -> void:
	var unsupported: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.GENERIC_AREA)
	_check(unsupported == null, "unsupported universal lookup returns null")


func _test_malformed_profile_refusal(catalog: UniversalAreaCatalog) -> void:
	var malformed := LayoutAreaProfile.new(
		LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA,
		[Vector2i.ZERO],
		LayoutAreaSemantics.GrowthMode.NONE,
		0,
		Vector2i.ZERO,
		false,
		0,
		0,
		[],
		[]
	)
	_check(not catalog._validate_profile(malformed), "malformed profile is refused")


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("%s: check failed: %s." % [ORIGIN, message])
