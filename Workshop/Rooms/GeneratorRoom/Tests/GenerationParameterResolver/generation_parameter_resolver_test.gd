extends SceneTree

const CATALOG: GenerationCatalog = preload(
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "GenerationParameterResolver/starter_generation_catalog.tres"
)

var _checks: int = 0
var _failures: PackedStringArray = []


func _initialize() -> void:
	_test_all_starter_combinations()
	_test_representative_results()
	_test_result_is_detached_from_catalog()
	_test_required_request_values()
	_test_duplicate_and_missing_profiles()
	_test_invalid_profile_values()

	if _failures.is_empty():
		print(
			"generation_parameter_resolver_test.gd: PASS (",
			_checks,
			" checks)"
		)
		quit(0)
		return

	for failure in _failures:
		push_error(
			"res://Workshop/Rooms/GeneratorRoom/Tests/"
			+ "GenerationParameterResolver/generation_parameter_resolver_test.gd: "
			+ failure
		)
	print(
		"generation_parameter_resolver_test.gd: FAIL (",
		_failures.size(),
		" failures across ",
		_checks,
		" checks)"
	)
	quit(1)


func _test_all_starter_combinations() -> void:
	var resolved_count: int = 0
	for archetype in GenerationSemantics.required_archetypes():
		for scale in GenerationSemantics.required_scales():
			for modifier in GenerationSemantics.required_modifiers():
				var resolution := GenerationParameterResolver.resolve(
					CATALOG,
					LayoutRequest.new(archetype, scale, modifier)
				)
				_expect(
					resolution.is_success,
					"Starter combination failed: %s/%s/%s: %s" % [
						archetype,
						scale,
						modifier,
						resolution.error_message,
					]
				)
				if resolution.is_success:
					resolved_count += 1
	_expect(resolved_count == 27, "Expected 27 resolved starter combinations.")


func _test_representative_results() -> void:
	var dungeon_medium_standard := _resolve(
		GenerationSemantics.Archetype.DUNGEON,
		GenerationSemantics.Scale.MEDIUM,
		GenerationSemantics.GeometryModifier.STANDARD
	)
	_expect_result(
		dungeon_medium_standard,
		Vector2i(91, 63),
		Vector2i(31, 31),
		100,
		4,
		12,
		20,
		false,
		GenerationSemantics.GeometryStrategy.RECTANGULAR_ROOMS,
		GenerationSemantics.BoundaryStrategy.SQUARE,
		"Dungeon/Medium/Standard"
	)

	var cave_small_confined := _resolve(
		GenerationSemantics.Archetype.CAVE,
		GenerationSemantics.Scale.SMALL,
		GenerationSemantics.GeometryModifier.CONFINED
	)
	_expect_result(
		cave_small_confined,
		Vector2i(41, 31),
		Vector2i(21, 21),
		44,
		4,
		10,
		7,
		true,
		GenerationSemantics.GeometryStrategy.RECTANGULAR_ROOMS,
		GenerationSemantics.BoundaryStrategy.COMPOUND_CIRCLES,
		"Cave/Small/Confined"
	)

	var cave_large_exposed := _resolve(
		GenerationSemantics.Archetype.CAVE,
		GenerationSemantics.Scale.LARGE,
		GenerationSemantics.GeometryModifier.EXPOSED
	)
	_expect_result(
		cave_large_exposed,
		Vector2i(141, 95),
		Vector2i(41, 41),
		176,
		4,
		14,
		43,
		true,
		GenerationSemantics.GeometryStrategy.RECTANGULAR_ROOMS,
		GenerationSemantics.BoundaryStrategy.COMPOUND_CIRCLES,
		"Cave/Large/Exposed"
	)

	var tower_medium_exposed := _resolve(
		GenerationSemantics.Archetype.TOWER,
		GenerationSemantics.Scale.MEDIUM,
		GenerationSemantics.GeometryModifier.EXPOSED
	)
	_expect_result(
		tower_medium_exposed,
		Vector2i(91, 63),
		Vector2i(31, 31),
		100,
		4,
		14,
		22,
		false,
		GenerationSemantics.GeometryStrategy.RECTANGULAR_ROOMS,
		GenerationSemantics.BoundaryStrategy.CIRCLE,
		"Tower/Medium/Exposed"
	)


func _test_result_is_detached_from_catalog() -> void:
	var local_catalog: GenerationCatalog = CATALOG.duplicate(true)
	var resolution := GenerationParameterResolver.resolve(
		local_catalog,
		LayoutRequest.new(
			GenerationSemantics.Archetype.DUNGEON,
			GenerationSemantics.Scale.SMALL,
			GenerationSemantics.GeometryModifier.STANDARD
		)
	)
	_expect(resolution.is_success, "Snapshot setup resolution failed.")
	if not resolution.is_success:
		return

	local_catalog.scales[0].raw_field_size = Vector2i(999, 999)
	_expect(
		resolution.parameters.raw_field_size == Vector2i(41, 31),
		"Resolved result changed after catalog mutation."
	)
	local_catalog.scales[0].raw_field_size = Vector2i(41, 31)


func _test_required_request_values() -> void:
	_expect_failure_contains(
		GenerationParameterResolver.resolve(CATALOG, null),
		"Layout request is required"
	)
	_expect_failure_contains(
		GenerationParameterResolver.resolve(CATALOG, LayoutRequest.new()),
		"archetype is required"
	)
	_expect_failure_contains(
		GenerationParameterResolver.resolve(
			CATALOG,
			LayoutRequest.new(
				GenerationSemantics.Archetype.DUNGEON,
				GenerationSemantics.Scale.MEDIUM
			)
		),
		"STANDARD must be explicit"
	)
	_expect_failure_contains(
		GenerationParameterResolver.resolve(
			CATALOG,
			LayoutRequest.new(
				999,
				GenerationSemantics.Scale.MEDIUM,
				GenerationSemantics.GeometryModifier.STANDARD
			)
		),
		"Unsupported archetype"
	)


func _test_duplicate_and_missing_profiles() -> void:
	var duplicate_catalog: GenerationCatalog = CATALOG.duplicate(true)
	duplicate_catalog.scales.append(duplicate_catalog.scales[0].duplicate(true))
	_expect_failure_contains(
		GenerationParameterResolver.resolve(
			duplicate_catalog,
			_standard_request()
		),
		"Duplicate scale profile"
	)

	var missing_catalog: GenerationCatalog = CATALOG.duplicate(true)
	missing_catalog.modifiers.remove_at(0)
	_expect_failure_contains(
		GenerationParameterResolver.resolve(missing_catalog, _standard_request()),
		"Missing required modifier profile"
	)


func _test_invalid_profile_values() -> void:
	var bad_dimensions: GenerationCatalog = CATALOG.duplicate(true)
	bad_dimensions.scales[0].raw_field_size = Vector2i(40, 31)
	_expect_failure_contains(
		GenerationParameterResolver.resolve(bad_dimensions, _standard_request()),
		"raw field dimensions must be odd"
	)
	bad_dimensions.scales[0].raw_field_size = Vector2i(41, 31)

	var bad_room_count: GenerationCatalog = CATALOG.duplicate(true)
	bad_room_count.scales[0].room_count = 0
	_expect_failure_contains(
		GenerationParameterResolver.resolve(bad_room_count, _standard_request()),
		"room count must be positive"
	)
	bad_room_count.scales[0].room_count = 44

	var bad_radius: GenerationCatalog = CATALOG.duplicate(true)
	bad_radius.archetypes[0].base_max_radius = 3
	_expect_failure_contains(
		GenerationParameterResolver.resolve(bad_radius, _standard_request()),
		"maximum radius is below its minimum"
	)
	bad_radius.archetypes[0].base_max_radius = 12

	var bad_ratio: GenerationCatalog = CATALOG.duplicate(true)
	bad_ratio.archetypes[0].base_tax_interval_ratio = 0.0
	_expect_failure_contains(
		GenerationParameterResolver.resolve(bad_ratio, _standard_request()),
		"tax-interval ratio must be positive"
	)
	bad_ratio.archetypes[0].base_tax_interval_ratio = 0.2

	var bad_standard: GenerationCatalog = CATALOG.duplicate(true)
	bad_standard.modifiers[1].radius_adjustment = 1
	_expect_failure_contains(
		GenerationParameterResolver.resolve(bad_standard, _standard_request()),
		"STANDARD modifier must be an explicit identity profile"
	)
	bad_standard.modifiers[1].radius_adjustment = 0


func _resolve(
	archetype: GenerationSemantics.Archetype,
	scale: GenerationSemantics.Scale,
	modifier: GenerationSemantics.GeometryModifier
) -> ResolvedGenerationParameters:
	var resolution := GenerationParameterResolver.resolve(
		CATALOG,
		LayoutRequest.new(archetype, scale, modifier)
	)
	_expect(resolution.is_success, "Representative resolution failed: %s" % resolution.error_message)
	return resolution.parameters


func _expect_result(
	parameters: ResolvedGenerationParameters,
	raw_field_size: Vector2i,
	output_size: Vector2i,
	room_count: int,
	min_radius: int,
	max_radius: int,
	tax_interval: int,
	room_count_is_provisional: bool,
	geometry_strategy: GenerationSemantics.GeometryStrategy,
	boundary_strategy: GenerationSemantics.BoundaryStrategy,
	label: String
) -> void:
	_expect(parameters != null, "%s returned no parameters." % label)
	if parameters == null:
		return
	_expect(parameters.raw_field_size == raw_field_size, "%s raw field mismatch." % label)
	_expect(parameters.output_size == output_size, "%s output size mismatch." % label)
	_expect(parameters.room_count == room_count, "%s room count mismatch." % label)
	_expect(parameters.min_radius == min_radius, "%s minimum radius mismatch." % label)
	_expect(parameters.max_radius == max_radius, "%s maximum radius mismatch." % label)
	_expect(parameters.tax_interval == tax_interval, "%s tax interval mismatch." % label)
	_expect(
		parameters.room_count_is_provisional == room_count_is_provisional,
		"%s provisional-room-count flag mismatch." % label
	)
	_expect(parameters.geometry_strategy == geometry_strategy, "%s strategy mismatch." % label)
	_expect(parameters.boundary_strategy == boundary_strategy, "%s boundary mismatch." % label)


func _standard_request() -> LayoutRequest:
	return LayoutRequest.new(
		GenerationSemantics.Archetype.DUNGEON,
		GenerationSemantics.Scale.MEDIUM,
		GenerationSemantics.GeometryModifier.STANDARD
	)


func _expect_failure_contains(
	resolution: GenerationResolution,
	expected_text: String
) -> void:
	_expect(not resolution.is_success, "Expected resolution failure containing: %s" % expected_text)
	_expect(
		resolution.error_message.contains(expected_text),
		"Failure did not contain '%s': %s" % [expected_text, resolution.error_message]
	)
	_expect(
		resolution.error_message.begins_with(GenerationParameterResolver.ERROR_ORIGIN),
		"Failure did not identify the resolver origin: %s" % resolution.error_message
	)


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
