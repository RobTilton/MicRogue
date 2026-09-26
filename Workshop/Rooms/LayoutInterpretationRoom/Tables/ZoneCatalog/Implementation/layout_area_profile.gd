class_name LayoutAreaProfile
extends RefCounted

var area_role: LayoutInterpretationSemantics.AreaRole
var minimum_footprints: Array[Vector2i]
var growth_mode: LayoutAreaSemantics.GrowthMode
var maximum_claimed_tiles: int
var maximum_bounding_size: Vector2i
var bounding_window_may_rotate: bool
var permits_narrow_connections: bool
var minimum_wall_adjacent_sides: int
var preferred_wall_adjacent_sides: int
var preferences: Array[LayoutAreaSemantics.Preference]
var tags: Array[LayoutAreaSemantics.Tag]
var chain_unit_size: Vector2i
var geometry_clone_source_role: LayoutInterpretationSemantics.AreaRole
var preferred_companion_max_path_distance: int
var companion_proximity_can_block: bool


func _init(
	profile_area_role: LayoutInterpretationSemantics.AreaRole,
	profile_minimum_footprints: Array[Vector2i],
	profile_growth_mode: LayoutAreaSemantics.GrowthMode,
	profile_maximum_claimed_tiles: int,
	profile_maximum_bounding_size: Vector2i,
	profile_bounding_window_may_rotate: bool,
	profile_permits_narrow_connections: bool,
	profile_minimum_wall_adjacent_sides: int,
	profile_preferred_wall_adjacent_sides: int,
	profile_preferences: Array[LayoutAreaSemantics.Preference],
	profile_tags: Array[LayoutAreaSemantics.Tag],
	profile_chain_unit_size: Vector2i = Vector2i.ZERO,
	profile_geometry_clone_source_role: LayoutInterpretationSemantics.AreaRole = LayoutInterpretationSemantics.AreaRole.INVALID,
	profile_preferred_companion_max_path_distance: int = -1,
	profile_companion_proximity_can_block: bool = false
) -> void:
	area_role = profile_area_role
	minimum_footprints = profile_minimum_footprints.duplicate()
	growth_mode = profile_growth_mode
	maximum_claimed_tiles = profile_maximum_claimed_tiles
	maximum_bounding_size = profile_maximum_bounding_size
	bounding_window_may_rotate = profile_bounding_window_may_rotate
	permits_narrow_connections = profile_permits_narrow_connections
	minimum_wall_adjacent_sides = profile_minimum_wall_adjacent_sides
	preferred_wall_adjacent_sides = profile_preferred_wall_adjacent_sides
	preferences = profile_preferences.duplicate()
	tags = profile_tags.duplicate()
	chain_unit_size = profile_chain_unit_size
	geometry_clone_source_role = profile_geometry_clone_source_role
	preferred_companion_max_path_distance = profile_preferred_companion_max_path_distance
	companion_proximity_can_block = profile_companion_proximity_can_block


func duplicate_profile() -> LayoutAreaProfile:
	return LayoutAreaProfile.new(
		area_role,
		minimum_footprints,
		growth_mode,
		maximum_claimed_tiles,
		maximum_bounding_size,
		bounding_window_may_rotate,
		permits_narrow_connections,
		minimum_wall_adjacent_sides,
		preferred_wall_adjacent_sides,
		preferences,
		tags,
		chain_unit_size,
		geometry_clone_source_role,
		preferred_companion_max_path_distance,
		companion_proximity_can_block
	)
