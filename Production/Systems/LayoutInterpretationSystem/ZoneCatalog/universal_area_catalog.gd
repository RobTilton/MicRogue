class_name UniversalAreaCatalog
extends RefCounted

const ORIGIN: String = "Production/Systems/LayoutInterpretationSystem/ZoneCatalog/universal_area_catalog.gd"

var _profiles: Dictionary = {}


static func create() -> UniversalAreaCatalog:
	var catalog := UniversalAreaCatalog.new()
	var profiles: Array[LayoutAreaProfile] = [catalog._entrance_profile(), catalog._boss_profile()]
	if not catalog._validate_complete_catalog(profiles):
		return null
	for profile: LayoutAreaProfile in profiles:
		catalog._profiles[profile.area_role] = profile
	return catalog


func has_profile(area_role: LayoutInterpretationSemantics.AreaRole) -> bool:
	return _profiles.has(area_role)


func get_profile(
	area_role: LayoutInterpretationSemantics.AreaRole
) -> LayoutAreaProfile:
	if not _profiles.has(area_role):
		push_error("%s: unsupported universal Area role %d." % [ORIGIN, area_role])
		return null
	var profile: LayoutAreaProfile = _profiles[area_role]
	return profile.duplicate_profile()


func _entrance_profile() -> LayoutAreaProfile:
	return LayoutAreaProfile.new(
		LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA,
		[Vector2i(2, 4), Vector2i(4, 2), Vector2i(3, 3)],
		LayoutAreaSemantics.GrowthMode.NONE,
		0,
		Vector2i.ZERO,
		false,
		false,
		1,
		2,
		[LayoutAreaSemantics.Preference.WALL_ADJACENCY],
		[
			LayoutAreaSemantics.Tag.ENTRANCE,
			LayoutAreaSemantics.Tag.NO_ENEMY,
			LayoutAreaSemantics.Tag.LIGHT,
		]
	)


func _boss_profile() -> LayoutAreaProfile:
	return LayoutAreaProfile.new(
		LayoutInterpretationSemantics.AreaRole.BOSS_AREA,
		[Vector2i(3, 3)],
		LayoutAreaSemantics.GrowthMode.FLOOD,
		50,
		Vector2i(8, 8),
		false,
		true,
		0,
		0,
		[
			LayoutAreaSemantics.Preference.LARGEST_USABLE_CONNECTED_SPACE,
			LayoutAreaSemantics.Preference.SINGLE_OPEN_AREA,
		],
		[LayoutAreaSemantics.Tag.BOSS, LayoutAreaSemantics.Tag.LIGHT]
	)


func _validate_complete_catalog(profiles: Array[LayoutAreaProfile]) -> bool:
	if profiles.size() != 2:
		return _refuse("universal catalog has %d profiles; expected 2." % profiles.size())
	var required_roles: Array[LayoutInterpretationSemantics.AreaRole] = LayoutInterpretationSemantics.universal_area_roles()
	var seen_roles: Dictionary = {}
	for profile: LayoutAreaProfile in profiles:
		if profile == null:
			return _refuse("universal catalog contains a null profile.")
		if profile.area_role not in required_roles:
			return _refuse("universal catalog contains unsupported Area role %d." % profile.area_role)
		if seen_roles.has(profile.area_role):
			return _refuse("universal catalog repeats Area role %d." % profile.area_role)
		if not _validate_profile(profile):
			return false
		seen_roles[profile.area_role] = true
	for area_role: LayoutInterpretationSemantics.AreaRole in required_roles:
		if not seen_roles.has(area_role):
			return _refuse("universal catalog is missing Area role %d." % area_role)
	return true


func _validate_profile(profile: LayoutAreaProfile) -> bool:
	if profile.area_role not in LayoutInterpretationSemantics.required_area_roles():
		return _refuse("profile uses unsupported Area role %d." % profile.area_role)
	if profile.minimum_footprints.is_empty():
		return _refuse("Area role %d has no minimum footprint." % profile.area_role)
	var seen_footprints: Dictionary = {}
	for footprint: Vector2i in profile.minimum_footprints:
		if footprint.x <= 0 or footprint.y <= 0:
			return _refuse("Area role %d has a non-positive minimum footprint." % profile.area_role)
		if seen_footprints.has(footprint):
			return _refuse("Area role %d repeats minimum footprint %s." % [profile.area_role, footprint])
		seen_footprints[footprint] = true
	if profile.minimum_wall_adjacent_sides < 0 or profile.minimum_wall_adjacent_sides > 4:
		return _refuse("Area role %d has invalid minimum wall adjacency." % profile.area_role)
	if profile.preferred_wall_adjacent_sides < profile.minimum_wall_adjacent_sides or profile.preferred_wall_adjacent_sides > 4:
		return _refuse("Area role %d has invalid preferred wall adjacency." % profile.area_role)
	match profile.growth_mode:
		LayoutAreaSemantics.GrowthMode.NONE:
			if profile.maximum_claimed_tiles != 0 or profile.maximum_bounding_size != Vector2i.ZERO or profile.bounding_window_may_rotate or profile.permits_narrow_connections:
				return _refuse("non-growing Area role %d contains growth data." % profile.area_role)
		LayoutAreaSemantics.GrowthMode.FLOOD:
			var has_tile_cap: bool = profile.maximum_claimed_tiles > 0
			var has_bounding_window: bool = profile.maximum_bounding_size.x > 0 and profile.maximum_bounding_size.y > 0
			if not has_tile_cap and not has_bounding_window:
				return _refuse("flood-growing Area role %d has neither a tile cap nor a bounding window." % profile.area_role)
			if profile.maximum_claimed_tiles < 0:
				return _refuse("flood-growing Area role %d has a negative tile cap." % profile.area_role)
			if profile.maximum_bounding_size != Vector2i.ZERO and not has_bounding_window:
				return _refuse("flood-growing Area role %d has a partial bounding window." % profile.area_role)
		_:
			return _refuse("Area role %d has unsupported growth mode %d." % [profile.area_role, profile.growth_mode])
	if not _validate_unique_supported_values(profile.preferences, LayoutAreaSemantics.supported_preferences(), "preference", profile.area_role):
		return false
	if not _validate_unique_supported_values(profile.tags, LayoutAreaSemantics.supported_tags(), "tag", profile.area_role):
		return false
	if profile.chain_unit_size != Vector2i.ZERO:
		if profile.chain_unit_size.x <= 0 or profile.chain_unit_size.y <= 0:
			return _refuse("Area role %d has an invalid chain unit size." % profile.area_role)
		if profile.minimum_footprints != [profile.chain_unit_size]:
			return _refuse("Area role %d chain unit does not match its minimum footprint." % profile.area_role)
	if profile.geometry_clone_source_role != LayoutInterpretationSemantics.AreaRole.INVALID:
		if profile.geometry_clone_source_role not in LayoutInterpretationSemantics.required_area_roles():
			return _refuse("Area role %d has an unsupported geometry clone source." % profile.area_role)
		if profile.geometry_clone_source_role == profile.area_role:
			return _refuse("Area role %d clones its own geometry." % profile.area_role)
	if profile.preferred_companion_max_path_distance < -1:
		return _refuse("Area role %d has an invalid companion distance." % profile.area_role)
	if profile.preferred_companion_max_path_distance == -1 and profile.companion_proximity_can_block:
		return _refuse("Area role %d has blocking companion behavior without a companion distance." % profile.area_role)
	return true


func _validate_unique_supported_values(
	values: Array,
	supported_values: Array,
	value_label: String,
	area_role: LayoutInterpretationSemantics.AreaRole
) -> bool:
	var seen_values: Dictionary = {}
	for value: Variant in values:
		if value not in supported_values:
			return _refuse("Area role %d uses unsupported %s %d." % [area_role, value_label, value])
		if seen_values.has(value):
			return _refuse("Area role %d repeats %s %d." % [area_role, value_label, value])
		seen_values[value] = true
	return true


func _refuse(message: String) -> bool:
	push_error("%s: %s" % [ORIGIN, message])
	return false
