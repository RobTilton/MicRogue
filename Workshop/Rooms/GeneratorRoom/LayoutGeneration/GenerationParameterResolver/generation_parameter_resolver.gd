class_name GenerationParameterResolver
extends RefCounted

const ERROR_ORIGIN := (
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "GenerationParameterResolver/generation_parameter_resolver.gd"
)
const MINIMUM_RADIUS: int = 3


static func resolve(
	catalog: GenerationCatalog,
	request: LayoutRequest
) -> GenerationResolution:
	var catalog_error := _validate_catalog(catalog)
	if not catalog_error.is_empty():
		return GenerationResolution.failure(catalog_error)

	var request_error := _validate_request(request)
	if not request_error.is_empty():
		return GenerationResolution.failure(request_error)

	var archetype := _find_archetype(catalog, request.archetype)
	if archetype == null:
		return _failure("Unsupported archetype: %s." % request.archetype)

	var scale := _find_scale(catalog, request.scale)
	if scale == null:
		return _failure("Unsupported scale: %s." % request.scale)

	var modifier := _find_modifier(catalog, request.modifier)
	if modifier == null:
		return _failure("Unsupported geometry modifier: %s." % request.modifier)

	var scale_max_adjustment := _apply_radius_buffer(
		scale.max_radius_adjustment,
		archetype.radius_change_buffer
	)
	var modifier_radius_adjustment := _apply_radius_buffer(
		modifier.radius_adjustment,
		archetype.radius_change_buffer
	)

	var resolved_min_radius: int = max(
		MINIMUM_RADIUS,
		archetype.base_min_radius
	)
	var resolved_max_radius: int = max(
		resolved_min_radius,
		archetype.base_max_radius
		+ scale_max_adjustment
		+ modifier_radius_adjustment
	)
	var resolved_tax_interval: int = max(
		1,
		roundi(
			scale.room_count
			* archetype.base_tax_interval_ratio
			* scale.tax_interval_multiplier
			* modifier.tax_interval_multiplier
		)
	)

	return GenerationResolution.success(
		ResolvedGenerationParameters.new(
			scale.raw_field_size,
			scale.cut_window_radius,
			scale.room_count,
			archetype.geometry_strategy,
			archetype.boundary_strategy,
			resolved_min_radius,
			resolved_max_radius,
			resolved_tax_interval,
			scale.room_count_is_provisional
		)
	)


static func _validate_catalog(catalog: GenerationCatalog) -> String:
	if catalog == null:
		return _error("Catalog is required.")

	var error := _validate_archetypes(catalog.archetypes)
	if not error.is_empty():
		return error

	error = _validate_scales(catalog.scales)
	if not error.is_empty():
		return error

	return _validate_modifiers(catalog.modifiers)


static func _validate_request(request: LayoutRequest) -> String:
	if request == null:
		return _error("Layout request is required.")
	if request.archetype == GenerationSemantics.Archetype.INVALID:
		return _error("Layout request archetype is required.")
	if request.scale == GenerationSemantics.Scale.INVALID:
		return _error("Layout request scale is required.")
	if request.modifier == GenerationSemantics.GeometryModifier.INVALID:
		return _error("Layout request geometry modifier is required; STANDARD must be explicit.")
	return ""


static func _validate_archetypes(
	profiles: Array[GenerationArchetypeProfile]
) -> String:
	var seen := {}
	for profile in profiles:
		if profile == null:
			return _error("Archetype catalog contains a null profile.")
		if seen.has(profile.archetype):
			return _error("Duplicate archetype profile: %s." % profile.archetype)
		seen[profile.archetype] = true
		if profile.archetype == GenerationSemantics.Archetype.INVALID:
			return _error("Archetype profile has an invalid identifier.")
		if profile.geometry_strategy == GenerationSemantics.GeometryStrategy.INVALID:
			return _error("Archetype %s has no geometry strategy." % profile.archetype)
		if profile.boundary_strategy == GenerationSemantics.BoundaryStrategy.INVALID:
			return _error("Archetype %s has no boundary strategy." % profile.archetype)
		if profile.base_min_radius < MINIMUM_RADIUS:
			return _error("Archetype %s minimum radius is below %s." % [profile.archetype, MINIMUM_RADIUS])
		if profile.base_max_radius < profile.base_min_radius:
			return _error("Archetype %s maximum radius is below its minimum." % profile.archetype)
		if profile.radius_change_buffer < 0:
			return _error("Archetype %s radius-change buffer is negative." % profile.archetype)
		if profile.base_tax_interval_ratio <= 0.0:
			return _error("Archetype %s tax-interval ratio must be positive." % profile.archetype)

	for required in GenerationSemantics.required_archetypes():
		if not seen.has(required):
			return _error("Missing required archetype profile: %s." % required)
	return ""


static func _validate_scales(profiles: Array[GenerationScaleProfile]) -> String:
	var seen := {}
	for profile in profiles:
		if profile == null:
			return _error("Scale catalog contains a null profile.")
		if seen.has(profile.scale):
			return _error("Duplicate scale profile: %s." % profile.scale)
		seen[profile.scale] = true
		if profile.scale == GenerationSemantics.Scale.INVALID:
			return _error("Scale profile has an invalid identifier.")
		if profile.raw_field_size.x <= 0 or profile.raw_field_size.y <= 0:
			return _error("Scale %s raw field dimensions must be positive." % profile.scale)
		if profile.raw_field_size.x % 2 == 0 or profile.raw_field_size.y % 2 == 0:
			return _error("Scale %s raw field dimensions must be odd." % profile.scale)
		if profile.cut_window_radius < 1:
			return _error("Scale %s cut-window radius must be positive." % profile.scale)
		var output_diameter: int = profile.cut_window_radius * 2 + 1
		if output_diameter > profile.raw_field_size.x or output_diameter > profile.raw_field_size.y:
			return _error("Scale %s cut window does not fit its raw field." % profile.scale)
		if profile.room_count <= 0:
			return _error("Scale %s room count must be positive." % profile.scale)
		if profile.tax_interval_multiplier <= 0.0:
			return _error("Scale %s tax multiplier must be positive." % profile.scale)

	for required in GenerationSemantics.required_scales():
		if not seen.has(required):
			return _error("Missing required scale profile: %s." % required)
	return ""


static func _validate_modifiers(
	profiles: Array[GenerationModifierProfile]
) -> String:
	var seen := {}
	for profile in profiles:
		if profile == null:
			return _error("Modifier catalog contains a null profile.")
		if seen.has(profile.modifier):
			return _error("Duplicate modifier profile: %s." % profile.modifier)
		seen[profile.modifier] = true
		if profile.modifier == GenerationSemantics.GeometryModifier.INVALID:
			return _error("Modifier profile has an invalid identifier.")
		if profile.tax_interval_multiplier <= 0.0:
			return _error("Modifier %s tax multiplier must be positive." % profile.modifier)

	for required in GenerationSemantics.required_modifiers():
		if not seen.has(required):
			return _error("Missing required modifier profile: %s." % required)

	var standard := _find_modifier_by_id(
		profiles,
		GenerationSemantics.GeometryModifier.STANDARD
	)
	if standard.radius_adjustment != 0 or not is_equal_approx(standard.tax_interval_multiplier, 1.0):
		return _error("STANDARD modifier must be an explicit identity profile.")
	return ""


static func _find_archetype(
	catalog: GenerationCatalog,
	id: GenerationSemantics.Archetype
) -> GenerationArchetypeProfile:
	for profile in catalog.archetypes:
		if profile.archetype == id:
			return profile
	return null


static func _find_scale(
	catalog: GenerationCatalog,
	id: GenerationSemantics.Scale
) -> GenerationScaleProfile:
	for profile in catalog.scales:
		if profile.scale == id:
			return profile
	return null


static func _find_modifier(
	catalog: GenerationCatalog,
	id: GenerationSemantics.GeometryModifier
) -> GenerationModifierProfile:
	return _find_modifier_by_id(catalog.modifiers, id)


static func _find_modifier_by_id(
	profiles: Array[GenerationModifierProfile],
	id: GenerationSemantics.GeometryModifier
) -> GenerationModifierProfile:
	for profile in profiles:
		if profile.modifier == id:
			return profile
	return null


static func _apply_radius_buffer(adjustment: int, buffer: int) -> int:
	if adjustment == 0:
		return 0
	return signi(adjustment) * max(absi(adjustment) - buffer, 0)


static func _failure(message: String) -> GenerationResolution:
	return GenerationResolution.failure(_error(message))


static func _error(message: String) -> String:
	return "%s: %s" % [ERROR_ORIGIN, message]
