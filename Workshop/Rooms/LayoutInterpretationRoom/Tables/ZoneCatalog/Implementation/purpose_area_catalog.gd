class_name PurposeAreaCatalog
extends RefCounted

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/ZoneCatalog/Implementation/purpose_area_catalog.gd"

var _profiles: Dictionary = {}


static func create() -> PurposeAreaCatalog:
	var catalog := PurposeAreaCatalog.new()
	var profiles: Array[LayoutAreaProfile] = catalog._build_profiles()
	if not catalog._validate_complete_catalog(profiles):
		return null
	for profile: LayoutAreaProfile in profiles:
		catalog._profiles[profile.area_role] = profile
	if not catalog._validate_geometry_clones():
		return null
	return catalog


func has_profile(area_role: LayoutInterpretationSemantics.AreaRole) -> bool:
	return _profiles.has(area_role)


func get_profile(
	area_role: LayoutInterpretationSemantics.AreaRole
) -> LayoutAreaProfile:
	if not _profiles.has(area_role):
		push_error("%s: unsupported purpose/fallback Area role %d." % [ORIGIN, area_role])
		return null
	var profile: LayoutAreaProfile = _profiles[area_role]
	return profile.duplicate_profile()


func validate_purpose_catalog(purpose_catalog: InitialPurposeCatalog) -> bool:
	if purpose_catalog == null:
		return _refuse("purpose catalog is null.")
	for purpose: LayoutInterpretationSemantics.Purpose in LayoutInterpretationSemantics.required_purposes():
		var definition: LayoutPurposeDefinition = purpose_catalog.get_definition(purpose)
		if definition == null:
			return _refuse("purpose %d has no definition." % purpose)
		for requirement: LayoutAreaRequirement in definition.requirements:
			if not _profiles.has(requirement.area_role):
				return _refuse("purpose %d references missing Area role %d." % [purpose, requirement.area_role])
	return true


func _build_profiles() -> Array[LayoutAreaProfile]:
	return [
		_guard_post(),
		_cell(),
		_shrine(),
		_burial_chamber(),
		_library(),
		_scrying_chamber(),
		_alchemy_lab(),
		_armory(),
		_barracks(),
		_nesting_resting(),
		_food_storage(),
		_depot(),
		_equipment_storage(),
		_generic(),
	]


func _guard_post() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA,
		[Vector2i(3, 3)], 20, Vector2i(5, 5), false, false,
		[LayoutAreaSemantics.Preference.CENTRAL_PATH],
		[LayoutAreaSemantics.Tag.ENEMY, LayoutAreaSemantics.Tag.LIGHT, LayoutAreaSemantics.Tag.LOCKABLE],
		Vector2i.ZERO, LayoutInterpretationSemantics.AreaRole.INVALID, 2
	)


func _cell() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.CELL_AREA,
		[Vector2i(2, 2)], 0, Vector2i(12, 12), false, false,
		[LayoutAreaSemantics.Preference.LONG_WALLS], [], Vector2i(2, 2)
	)


func _shrine() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.SHRINE_AREA,
		[Vector2i(3, 3)], 30, Vector2i(8, 8), false, false,
		[LayoutAreaSemantics.Preference.OPEN_AREA, LayoutAreaSemantics.Preference.MINIMIZE_WALL_CONTACT],
		[LayoutAreaSemantics.Tag.LIGHT, LayoutAreaSemantics.Tag.DIVINITY]
	)


func _burial_chamber() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.BURIAL_CHAMBER_AREA,
		[Vector2i(2, 2)], 0, Vector2i(12, 12), false, false,
		[LayoutAreaSemantics.Preference.LONG_WALLS], [LayoutAreaSemantics.Tag.SWARM],
		Vector2i(2, 2), LayoutInterpretationSemantics.AreaRole.CELL_AREA
	)


func _library() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.LIBRARY_AREA,
		[Vector2i(2, 4), Vector2i(4, 2)], 24, Vector2i(4, 8), true, false,
		[LayoutAreaSemantics.Preference.LONG_SHAPE, LayoutAreaSemantics.Preference.WALL_ADJACENCY],
		[LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.ARCANE]
	)


func _scrying_chamber() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.SCRYING_CHAMBER_AREA,
		[Vector2i(3, 3)], 16, Vector2i(5, 5), false, false,
		[LayoutAreaSemantics.Preference.MIDDLE_PROGRESSION],
		[LayoutAreaSemantics.Tag.LIGHT, LayoutAreaSemantics.Tag.ARCANE]
	)


func _alchemy_lab() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.ALCHEMY_LAB_AREA,
		[Vector2i(3, 5), Vector2i(5, 3)], 40, Vector2i(8, 8), false, true,
		[LayoutAreaSemantics.Preference.SPRAWLING],
		[LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.SWARM, LayoutAreaSemantics.Tag.ARCANE]
	)


func _armory() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.ARMORY_AREA,
		[Vector2i(5, 5)], 36, Vector2i(8, 8), false, false,
		[LayoutAreaSemantics.Preference.BALANCED_RECTANGLE],
		[LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.TRAPPED, LayoutAreaSemantics.Tag.ENEMY],
		Vector2i.ZERO, LayoutInterpretationSemantics.AreaRole.INVALID, 2
	)


func _barracks() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.BARRACKS_AREA,
		[Vector2i(3, 5), Vector2i(5, 3)], 30, Vector2i(6, 10), true, false,
		[LayoutAreaSemantics.Preference.SPRAWLING],
		[LayoutAreaSemantics.Tag.SWARM, LayoutAreaSemantics.Tag.ENEMY, LayoutAreaSemantics.Tag.LIGHT, LayoutAreaSemantics.Tag.LOCKABLE]
	)


func _nesting_resting() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.NESTING_RESTING_AREA,
		[Vector2i(3, 3)], 20, Vector2i(5, 5), false, false,
		[LayoutAreaSemantics.Preference.COMPACT, LayoutAreaSemantics.Preference.MIDDLE_PROGRESSION],
		[LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.SWARM, LayoutAreaSemantics.Tag.NO_LIGHT, LayoutAreaSemantics.Tag.TRAPPED]
	)


func _food_storage() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.FOOD_STORAGE_AREA,
		[Vector2i(3, 3)], 50, Vector2i(10, 10), false, false,
		[],
		[LayoutAreaSemantics.Tag.SWARM, LayoutAreaSemantics.Tag.NO_LIGHT, LayoutAreaSemantics.Tag.CROSS_FAMILY_ABERRATION]
	)


func _depot() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.DEPOT_AREA,
		[Vector2i(5, 5)], 40, Vector2i(12, 12), false, false,
		[LayoutAreaSemantics.Preference.COMPACT, LayoutAreaSemantics.Preference.MINIMIZE_WALL_CONTACT],
		[LayoutAreaSemantics.Tag.CROSS_FAMILY_ELEMENTAL]
	)


func _equipment_storage() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.EQUIPMENT_STORAGE_AREA,
		[Vector2i(5, 5)], 36, Vector2i(8, 8), false, false,
		[LayoutAreaSemantics.Preference.BALANCED_RECTANGLE],
		[LayoutAreaSemantics.Tag.LOOTABLE], Vector2i.ZERO,
		LayoutInterpretationSemantics.AreaRole.ARMORY_AREA
	)


func _generic() -> LayoutAreaProfile:
	return _profile(
		LayoutInterpretationSemantics.AreaRole.GENERIC_AREA,
		[Vector2i(2, 2)], 30, Vector2i.ZERO, false, true, [],
		[LayoutAreaSemantics.Tag.ENEMY, LayoutAreaSemantics.Tag.LOOTABLE, LayoutAreaSemantics.Tag.SWARM, LayoutAreaSemantics.Tag.TRAPPED]
	)


func _profile(
	area_role: LayoutInterpretationSemantics.AreaRole,
	minimum_footprints: Array[Vector2i],
	maximum_claimed_tiles: int,
	maximum_bounding_size: Vector2i,
	bounding_window_may_rotate: bool,
	permits_narrow_connections: bool,
	preferences: Array[LayoutAreaSemantics.Preference],
	tags: Array[LayoutAreaSemantics.Tag],
	chain_unit_size: Vector2i = Vector2i.ZERO,
	geometry_clone_source_role: LayoutInterpretationSemantics.AreaRole = LayoutInterpretationSemantics.AreaRole.INVALID,
	preferred_companion_max_path_distance: int = -1
) -> LayoutAreaProfile:
	return LayoutAreaProfile.new(
		area_role,
		minimum_footprints,
		LayoutAreaSemantics.GrowthMode.FLOOD,
		maximum_claimed_tiles,
		maximum_bounding_size,
		bounding_window_may_rotate,
		permits_narrow_connections,
		0,
		0,
		preferences,
		tags,
		chain_unit_size,
		geometry_clone_source_role,
		preferred_companion_max_path_distance,
		false
	)


func _validate_complete_catalog(profiles: Array[LayoutAreaProfile]) -> bool:
	var required_roles: Array[LayoutInterpretationSemantics.AreaRole] = []
	for area_role: LayoutInterpretationSemantics.AreaRole in LayoutInterpretationSemantics.required_area_roles():
		if area_role not in LayoutInterpretationSemantics.universal_area_roles():
			required_roles.append(area_role)
	if profiles.size() != required_roles.size():
		return _refuse("purpose/fallback catalog has %d profiles; expected %d." % [profiles.size(), required_roles.size()])
	var validator := UniversalAreaCatalog.new()
	var seen_roles: Dictionary = {}
	for profile: LayoutAreaProfile in profiles:
		if profile == null:
			return _refuse("purpose/fallback catalog contains a null profile.")
		if profile.area_role not in required_roles:
			return _refuse("purpose/fallback catalog contains unsupported Area role %d." % profile.area_role)
		if seen_roles.has(profile.area_role):
			return _refuse("purpose/fallback catalog repeats Area role %d." % profile.area_role)
		if not validator._validate_profile(profile):
			return false
		seen_roles[profile.area_role] = true
	for area_role: LayoutInterpretationSemantics.AreaRole in required_roles:
		if not seen_roles.has(area_role):
			return _refuse("purpose/fallback catalog is missing Area role %d." % area_role)
	return true


func _validate_geometry_clones() -> bool:
	for area_role: Variant in _profiles:
		var profile: LayoutAreaProfile = _profiles[area_role]
		if profile.geometry_clone_source_role == LayoutInterpretationSemantics.AreaRole.INVALID:
			continue
		if not _profiles.has(profile.geometry_clone_source_role):
			return _refuse("Area role %d clones missing Area role %d." % [profile.area_role, profile.geometry_clone_source_role])
		var source: LayoutAreaProfile = _profiles[profile.geometry_clone_source_role]
		if not _geometry_matches(profile, source):
			return _refuse("Area role %d does not match cloned geometry from Area role %d." % [profile.area_role, source.area_role])
	return true


func _geometry_matches(profile: LayoutAreaProfile, source: LayoutAreaProfile) -> bool:
	return (
		profile.minimum_footprints == source.minimum_footprints
		and profile.growth_mode == source.growth_mode
		and profile.maximum_claimed_tiles == source.maximum_claimed_tiles
		and profile.maximum_bounding_size == source.maximum_bounding_size
		and profile.bounding_window_may_rotate == source.bounding_window_may_rotate
		and profile.permits_narrow_connections == source.permits_narrow_connections
		and profile.minimum_wall_adjacent_sides == source.minimum_wall_adjacent_sides
		and profile.preferred_wall_adjacent_sides == source.preferred_wall_adjacent_sides
		and profile.preferences == source.preferences
		and profile.chain_unit_size == source.chain_unit_size
	)


func _refuse(message: String) -> bool:
	push_error("%s: %s" % [ORIGIN, message])
	return false
