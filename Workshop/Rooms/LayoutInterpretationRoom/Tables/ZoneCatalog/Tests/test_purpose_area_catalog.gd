extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/ZoneCatalog/Tests/test_purpose_area_catalog.gd"

var _checks: int = 0
var _failures: int = 0


func _init() -> void:
	var catalog: PurposeAreaCatalog = PurposeAreaCatalog.create()
	_check(catalog != null, "catalog creation succeeds")
	if catalog != null:
		_test_complete_roles(catalog)
		_test_profile_contracts(catalog)
		_test_geometry_clones(catalog)
		_test_cross_catalog(catalog)
		_test_detached_lookup(catalog)
		_test_unsupported_lookup(catalog)
	if _failures == 0:
		print("%s: PASS (%d checks)." % [ORIGIN, _checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)." % [ORIGIN, _failures, _checks])
	quit(1)


func _test_complete_roles(catalog: PurposeAreaCatalog) -> void:
	var expected_roles: Array[LayoutInterpretationSemantics.AreaRole] = []
	for role: LayoutInterpretationSemantics.AreaRole in LayoutInterpretationSemantics.required_area_roles():
		if role not in LayoutInterpretationSemantics.universal_area_roles():
			expected_roles.append(role)
	for role: LayoutInterpretationSemantics.AreaRole in expected_roles:
		_check(catalog.has_profile(role), "catalog contains Area role %d" % role)
	_check(not catalog.has_profile(LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA), "catalog excludes Entrance")
	_check(not catalog.has_profile(LayoutInterpretationSemantics.AreaRole.BOSS_AREA), "catalog excludes Boss")


func _test_profile_contracts(catalog: PurposeAreaCatalog) -> void:
	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA, [Vector2i(3, 3)], 20, Vector2i(5, 5), false, [LayoutAreaSemantics.Preference.CENTRAL_PATH], [LayoutAreaSemantics.Tag.ENEMY, LayoutAreaSemantics.Tag.LIGHT, LayoutAreaSemantics.Tag.LOCKABLE])
	var guard: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA)
	_check(guard.preferred_companion_max_path_distance == 2, "Guard Post companion distance matches")
	_check(not guard.companion_proximity_can_block, "Guard Post companion preference cannot block")

	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.CELL_AREA, [Vector2i(2, 2)], 0, Vector2i(12, 12), false, [LayoutAreaSemantics.Preference.LONG_WALLS], [])
	var cell: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.CELL_AREA)
	_check(cell.chain_unit_size == Vector2i(2, 2), "Cell chain unit matches")

	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.SHRINE_AREA, [Vector2i(3, 3)], 30, Vector2i(8, 8), false, [LayoutAreaSemantics.Preference.OPEN_AREA, LayoutAreaSemantics.Preference.MINIMIZE_WALL_CONTACT], [LayoutAreaSemantics.Tag.LIGHT, LayoutAreaSemantics.Tag.DIVINITY])
	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.BURIAL_CHAMBER_AREA, [Vector2i(2, 2)], 0, Vector2i(12, 12), false, [LayoutAreaSemantics.Preference.LONG_WALLS], [LayoutAreaSemantics.Tag.SWARM])
	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.LIBRARY_AREA, [Vector2i(2, 4), Vector2i(4, 2)], 24, Vector2i(4, 8), true, [LayoutAreaSemantics.Preference.LONG_SHAPE, LayoutAreaSemantics.Preference.WALL_ADJACENCY], [LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.ARCANE])
	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.SCRYING_CHAMBER_AREA, [Vector2i(3, 3)], 16, Vector2i(5, 5), false, [LayoutAreaSemantics.Preference.MIDDLE_PROGRESSION], [LayoutAreaSemantics.Tag.LIGHT, LayoutAreaSemantics.Tag.ARCANE])
	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.ALCHEMY_LAB_AREA, [Vector2i(3, 5), Vector2i(5, 3)], 40, Vector2i(8, 8), false, [LayoutAreaSemantics.Preference.SPRAWLING], [LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.SWARM, LayoutAreaSemantics.Tag.ARCANE])
	_check(catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ALCHEMY_LAB_AREA).permits_narrow_connections, "Alchemy Lab may span connected pockets")

	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.ARMORY_AREA, [Vector2i(3, 3)], 36, Vector2i(8, 8), false, [LayoutAreaSemantics.Preference.BALANCED_RECTANGLE], [LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.TRAPPED, LayoutAreaSemantics.Tag.ENEMY])
	var armory: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ARMORY_AREA)
	_check(armory.preferred_companion_max_path_distance == 2, "Armory companion distance matches")
	_check(not armory.companion_proximity_can_block, "Armory companion preference cannot block")

	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.BARRACKS_AREA, [Vector2i(3, 5), Vector2i(5, 3)], 30, Vector2i(6, 10), true, [LayoutAreaSemantics.Preference.SPRAWLING], [LayoutAreaSemantics.Tag.SWARM, LayoutAreaSemantics.Tag.ENEMY, LayoutAreaSemantics.Tag.LIGHT, LayoutAreaSemantics.Tag.LOCKABLE])
	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.NESTING_RESTING_AREA, [Vector2i(3, 3)], 20, Vector2i(5, 5), false, [LayoutAreaSemantics.Preference.COMPACT, LayoutAreaSemantics.Preference.MIDDLE_PROGRESSION], [LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.SWARM, LayoutAreaSemantics.Tag.NO_LIGHT, LayoutAreaSemantics.Tag.TRAPPED])
	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.FOOD_STORAGE_AREA, [Vector2i(3, 3)], 50, Vector2i(10, 10), false, [], [LayoutAreaSemantics.Tag.SWARM, LayoutAreaSemantics.Tag.NO_LIGHT, LayoutAreaSemantics.Tag.CROSS_FAMILY_ABERRATION])
	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.DEPOT_AREA, [Vector2i(3, 3)], 40, Vector2i(15, 15), false, [LayoutAreaSemantics.Preference.SPRAWLING], [LayoutAreaSemantics.Tag.CROSS_FAMILY_ELEMENTAL])
	_check(catalog.get_profile(LayoutInterpretationSemantics.AreaRole.DEPOT_AREA).permits_narrow_connections, "Depot may sprawl through narrow connections")
	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.EQUIPMENT_STORAGE_AREA, [Vector2i(3, 3)], 36, Vector2i(8, 8), false, [LayoutAreaSemantics.Preference.BALANCED_RECTANGLE], [LayoutAreaSemantics.Tag.LOOTABLE])
	_check_profile(catalog, LayoutInterpretationSemantics.AreaRole.GENERIC_AREA, [Vector2i(2, 2)], 30, Vector2i.ZERO, false, [], [LayoutAreaSemantics.Tag.ENEMY, LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.SWARM, LayoutAreaSemantics.Tag.TRAPPED])
	_check(catalog.get_profile(LayoutInterpretationSemantics.AreaRole.GENERIC_AREA).permits_narrow_connections, "Generic Area may traverse narrow chains")


func _test_geometry_clones(catalog: PurposeAreaCatalog) -> void:
	var burial: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.BURIAL_CHAMBER_AREA)
	var cell: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.CELL_AREA)
	_check(burial.geometry_clone_source_role == LayoutInterpretationSemantics.AreaRole.CELL_AREA, "Burial Chamber records Cell geometry source")
	_check(catalog._geometry_matches(burial, cell), "Burial Chamber geometry matches Cell")
	_check(burial.tags != cell.tags, "Burial Chamber tags are independent")

	var equipment: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.EQUIPMENT_STORAGE_AREA)
	var armory: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ARMORY_AREA)
	_check(equipment.geometry_clone_source_role == LayoutInterpretationSemantics.AreaRole.ARMORY_AREA, "Equipment Storage records Armory geometry source")
	_check(catalog._geometry_matches(equipment, armory), "Equipment Storage geometry matches Armory")
	_check(equipment.tags == [LayoutAreaSemantics.Tag.LOOTABLE], "Equipment Storage does not inherit Armory tags")
	_check(equipment.preferred_companion_max_path_distance == -1, "Equipment Storage does not inherit Armory companion preference")


func _test_cross_catalog(catalog: PurposeAreaCatalog) -> void:
	var purpose_catalog: InitialPurposeCatalog = InitialPurposeCatalog.create()
	_check(purpose_catalog != null, "Purpose Catalog exists for cross-validation")
	_check(catalog.validate_purpose_catalog(purpose_catalog), "every purpose requirement resolves to an Area profile")


func _test_detached_lookup(catalog: PurposeAreaCatalog) -> void:
	var first: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ARMORY_AREA)
	first.minimum_footprints.clear()
	first.tags.clear()
	var second: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ARMORY_AREA)
	_check(second.minimum_footprints == [Vector2i(3, 3)], "Area profile footprints are detached")
	_check(second.tags == [LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.TRAPPED, LayoutAreaSemantics.Tag.ENEMY], "Area profile tags are detached")


func _test_unsupported_lookup(catalog: PurposeAreaCatalog) -> void:
	var unsupported: LayoutAreaProfile = catalog.get_profile(LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA)
	_check(unsupported == null, "unsupported purpose/fallback lookup returns null")


func _check_profile(
	catalog: PurposeAreaCatalog,
	area_role: LayoutInterpretationSemantics.AreaRole,
	expected_footprints: Array[Vector2i],
	expected_maximum_tiles: int,
	expected_bounding_size: Vector2i,
	expected_bounding_rotation: bool,
	expected_preferences: Array[LayoutAreaSemantics.Preference],
	expected_tags: Array[LayoutAreaSemantics.Tag]
) -> void:
	var profile: LayoutAreaProfile = catalog.get_profile(area_role)
	_check(profile != null, "Area role %d profile exists" % area_role)
	if profile == null:
		return
	_check(profile.minimum_footprints == expected_footprints, "Area role %d footprints match" % area_role)
	_check(profile.growth_mode == LayoutAreaSemantics.GrowthMode.FLOOD, "Area role %d uses flood growth" % area_role)
	_check(profile.maximum_claimed_tiles == expected_maximum_tiles, "Area role %d tile cap matches" % area_role)
	_check(profile.maximum_bounding_size == expected_bounding_size, "Area role %d bounding size matches" % area_role)
	_check(profile.bounding_window_may_rotate == expected_bounding_rotation, "Area role %d bounding rotation matches" % area_role)
	_check(profile.preferences == expected_preferences, "Area role %d preferences match" % area_role)
	_check(profile.tags == expected_tags, "Area role %d tags match" % area_role)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("%s: check failed: %s." % [ORIGIN, message])
