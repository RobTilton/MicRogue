class_name LayoutAreaProfile
extends RefCounted

var area_role: LayoutInterpretationSemantics.AreaRole
var minimum_footprints: Array[Vector2i]
var growth_mode: LayoutAreaSemantics.GrowthMode
var maximum_claimed_tiles: int
var maximum_bounding_size: Vector2i
var permits_narrow_connections: bool
var minimum_wall_adjacent_sides: int
var preferred_wall_adjacent_sides: int
var preferences: Array[LayoutAreaSemantics.Preference]
var tags: Array[LayoutAreaSemantics.Tag]


func _init(
	profile_area_role: LayoutInterpretationSemantics.AreaRole,
	profile_minimum_footprints: Array[Vector2i],
	profile_growth_mode: LayoutAreaSemantics.GrowthMode,
	profile_maximum_claimed_tiles: int,
	profile_maximum_bounding_size: Vector2i,
	profile_permits_narrow_connections: bool,
	profile_minimum_wall_adjacent_sides: int,
	profile_preferred_wall_adjacent_sides: int,
	profile_preferences: Array[LayoutAreaSemantics.Preference],
	profile_tags: Array[LayoutAreaSemantics.Tag]
) -> void:
	area_role = profile_area_role
	minimum_footprints = profile_minimum_footprints.duplicate()
	growth_mode = profile_growth_mode
	maximum_claimed_tiles = profile_maximum_claimed_tiles
	maximum_bounding_size = profile_maximum_bounding_size
	permits_narrow_connections = profile_permits_narrow_connections
	minimum_wall_adjacent_sides = profile_minimum_wall_adjacent_sides
	preferred_wall_adjacent_sides = profile_preferred_wall_adjacent_sides
	preferences = profile_preferences.duplicate()
	tags = profile_tags.duplicate()


func duplicate_profile() -> LayoutAreaProfile:
	return LayoutAreaProfile.new(
		area_role,
		minimum_footprints,
		growth_mode,
		maximum_claimed_tiles,
		maximum_bounding_size,
		permits_narrow_connections,
		minimum_wall_adjacent_sides,
		preferred_wall_adjacent_sides,
		preferences,
		tags
	)
