class_name StarterGenerationCatalog
extends RefCounted


static func create() -> GenerationCatalog:
	var catalog := GenerationCatalog.new()
	catalog.archetypes = [
		_archetype(GenerationSemantics.Archetype.DUNGEON, GenerationSemantics.BoundaryStrategy.SQUARE, 0),
		_archetype(GenerationSemantics.Archetype.TOWER, GenerationSemantics.BoundaryStrategy.CIRCLE, 0),
		_archetype(GenerationSemantics.Archetype.CAVE, GenerationSemantics.BoundaryStrategy.COMPOUND_CIRCLES, 1),
	]
	catalog.scales = [
		# _scale(GenerationSemantics.Scale.SMALL, Vector2i(41, 31), 10, 44, -2, 0.9, true), # Pinned for future rework; not currently requestable.
		_scale(GenerationSemantics.Scale.MEDIUM, Vector2i(91, 63), 15, 100, 0, 1.0, false),
		_scale(GenerationSemantics.Scale.LARGE, Vector2i(141, 95), 20, 176, 2, 1.1, true),
	]
	catalog.modifiers = [
		_modifier(GenerationSemantics.GeometryModifier.EXPOSED, 2, 1.1),
		_modifier(GenerationSemantics.GeometryModifier.STANDARD, 0, 1.0),
		_modifier(GenerationSemantics.GeometryModifier.CONFINED, -2, 0.9),
	]
	return catalog


static func _archetype(
	id: GenerationSemantics.Archetype,
	boundary: GenerationSemantics.BoundaryStrategy,
	buffer: int
) -> GenerationArchetypeProfile:
	var profile := GenerationArchetypeProfile.new()
	profile.archetype = id
	profile.geometry_strategy = GenerationSemantics.GeometryStrategy.RECTANGULAR_ROOMS
	profile.boundary_strategy = boundary
	profile.base_min_radius = 4
	profile.base_max_radius = 12
	profile.radius_change_buffer = buffer
	profile.base_tax_interval_ratio = 0.2
	return profile


static func _scale(
	id: GenerationSemantics.Scale,
	raw_size: Vector2i,
	cut_radius: int,
	rooms: int,
	max_adjustment: int,
	tax_multiplier: float,
	provisional: bool
) -> GenerationScaleProfile:
	var profile := GenerationScaleProfile.new()
	profile.scale = id
	profile.raw_field_size = raw_size
	profile.cut_window_radius = cut_radius
	profile.room_count = rooms
	profile.max_radius_adjustment = max_adjustment
	profile.tax_interval_multiplier = tax_multiplier
	profile.room_count_is_provisional = provisional
	return profile


static func _modifier(
	id: GenerationSemantics.GeometryModifier,
	radius_adjustment: int,
	tax_multiplier: float
) -> GenerationModifierProfile:
	var profile := GenerationModifierProfile.new()
	profile.modifier = id
	profile.radius_adjustment = radius_adjustment
	profile.tax_interval_multiplier = tax_multiplier
	return profile
