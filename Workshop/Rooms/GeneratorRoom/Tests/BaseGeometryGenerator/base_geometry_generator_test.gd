extends SceneTree

const CATALOG: GenerationCatalog = preload(
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "GenerationParameterResolver/starter_generation_catalog.tres"
)

var _checks: int = 0
var _failures: PackedStringArray = []


func _initialize() -> void:
	_test_taxation_intervals()
	_test_supported_catalog_combinations()
	_test_cave_refusal()
	_test_deterministic_injected_rng()
	_test_invalid_inputs()

	if _failures.is_empty():
		print("base_geometry_generator_test.gd: PASS (", _checks, " checks)")
		quit(0)
		return

	for failure in _failures:
		push_error(
			"res://Workshop/Rooms/GeneratorRoom/Tests/"
			+ "BaseGeometryGenerator/base_geometry_generator_test.gd: "
			+ failure
		)
	print("base_geometry_generator_test.gd: FAIL (", _failures.size(), " failures)")
	quit(1)


func _test_taxation_intervals() -> void:
	var parameters := _resolve_parameters(
		GenerationSemantics.Archetype.DUNGEON,
		GenerationSemantics.Scale.MEDIUM,
		GenerationSemantics.GeometryModifier.STANDARD
	)
	_expect(parameters.tax_interval == 20, "Medium Standard tax interval must be 20.")
	_expect(BaseGeometryGenerator.taxed_max_radius_for_room(parameters, 0) == 12, "Room 1 taxed too early.")
	_expect(BaseGeometryGenerator.taxed_max_radius_for_room(parameters, 19) == 12, "Room 20 taxed too early.")
	_expect(BaseGeometryGenerator.taxed_max_radius_for_room(parameters, 20) == 11, "Room 21 did not tax once.")
	_expect(BaseGeometryGenerator.taxed_max_radius_for_room(parameters, 39) == 11, "Room 40 tax mismatch.")
	_expect(BaseGeometryGenerator.taxed_max_radius_for_room(parameters, 40) == 10, "Room 41 did not tax twice.")
	_expect(BaseGeometryGenerator.taxed_max_radius_for_room(parameters, 999) == 4, "Taxation crossed minimum radius.")


func _test_supported_catalog_combinations() -> void:
	var success_count: int = 0
	for archetype in [
		GenerationSemantics.Archetype.DUNGEON,
		GenerationSemantics.Archetype.TOWER,
	]:
		for scale in GenerationSemantics.required_scales():
			for modifier in GenerationSemantics.required_modifiers():
				var parameters := _resolve_parameters(archetype, scale, modifier)
				var result := BaseGeometryGenerator.generate_with_rng(
					parameters,
					_seeded_rng(1000 + success_count)
				)
				_expect(result.is_success, "Supported combination failed: %s" % result.error_message)
				if not result.is_success:
					continue
				success_count += 1
				_expect(result.field.size == parameters.output_size, "Output size mismatch.")
				_expect(result.field.cells.size() == result.field.size.x * result.field.size.y, "Cell count mismatch.")
				_expect_only_geometry_values(result.field)
				if archetype == GenerationSemantics.Archetype.DUNGEON:
					_expect_square_boundary(result.field)
				else:
					_expect_circle_boundary(result.field, parameters.cut_window_radius)
	_expect(success_count == 18, "Expected 18 supported Dungeon/Tower combinations.")


func _test_cave_refusal() -> void:
	var refusal_count: int = 0
	for scale in GenerationSemantics.required_scales():
		for modifier in GenerationSemantics.required_modifiers():
			var parameters := _resolve_parameters(
				GenerationSemantics.Archetype.CAVE,
				scale,
				modifier
			)
			var result := BaseGeometryGenerator.generate_with_rng(
				parameters,
				_seeded_rng(22)
			)
			_expect(not result.is_success, "Cave unexpectedly generated.")
			_expect(result.error_message.contains("pinned and unsupported"), "Cave refusal was unclear.")
			_expect(result.error_message.begins_with(BaseGeometryGenerator.ERROR_ORIGIN), "Cave refusal omitted source origin.")
			if not result.is_success:
				refusal_count += 1
	_expect(refusal_count == 9, "Expected nine refused Cave combinations.")


func _test_deterministic_injected_rng() -> void:
	var parameters := _resolve_parameters(
		GenerationSemantics.Archetype.DUNGEON,
		GenerationSemantics.Scale.SMALL,
		GenerationSemantics.GeometryModifier.CONFINED
	)
	var first := BaseGeometryGenerator.generate_with_rng(parameters, _seeded_rng(4434))
	var second := BaseGeometryGenerator.generate_with_rng(parameters, _seeded_rng(4434))
	_expect(first.is_success and second.is_success, "Determinism setup failed.")
	if first.is_success and second.is_success:
		_expect(first.field.size == second.field.size, "Deterministic sizes differed.")
		_expect(first.field.cells == second.field.cells, "Identical injected RNG seeds differed.")


func _test_invalid_inputs() -> void:
	var valid_parameters := _resolve_parameters(
		GenerationSemantics.Archetype.DUNGEON,
		GenerationSemantics.Scale.MEDIUM,
		GenerationSemantics.GeometryModifier.STANDARD
	)
	_expect_failure_contains(
		BaseGeometryGenerator.generate_with_rng(null, _seeded_rng(1)),
		"parameters are required"
	)
	_expect_failure_contains(
		BaseGeometryGenerator.generate_with_rng(valid_parameters, null),
		"generator is required"
	)

	var bad_tax := _copy_parameters(valid_parameters)
	bad_tax.tax_interval = 0
	_expect_failure_contains(
		BaseGeometryGenerator.generate_with_rng(bad_tax, _seeded_rng(1)),
		"Tax interval must be positive"
	)

	var bad_window := _copy_parameters(valid_parameters)
	bad_window.cut_window_radius = 100
	bad_window.output_size = Vector2i(201, 201)
	_expect_failure_contains(
		BaseGeometryGenerator.generate_with_rng(bad_window, _seeded_rng(1)),
		"required margin do not fit"
	)


func _expect_square_boundary(field: GeometryField) -> void:
	for x in range(field.size.x):
		_expect(field.get_cell(Vector2i(x, 0)) == GeometryField.WALL, "Square top edge is not wall.")
		_expect(field.get_cell(Vector2i(x, field.size.y - 1)) == GeometryField.WALL, "Square bottom edge is not wall.")
	for y in range(field.size.y):
		_expect(field.get_cell(Vector2i(0, y)) == GeometryField.WALL, "Square left edge is not wall.")
		_expect(field.get_cell(Vector2i(field.size.x - 1, y)) == GeometryField.WALL, "Square right edge is not wall.")


func _expect_circle_boundary(field: GeometryField, radius: int) -> void:
	var center := Vector2i(radius, radius)
	var floor_count: int = 0
	for y in range(field.size.y):
		for x in range(field.size.x):
			var position := Vector2i(x, y)
			var offset := position - center
			var value := field.get_cell(position)
			if offset.length_squared() > radius * radius:
				_expect(value == GeometryField.VOID, "Circle exterior was not void.")
			elif value == GeometryField.FLOOR:
				floor_count += 1
				for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var neighbor: Vector2i = offset + direction
					_expect(neighbor.length_squared() <= radius * radius, "Circle floor touched exterior.")
	_expect(floor_count > 0, "Circular output contained no floor.")


func _expect_only_geometry_values(field: GeometryField) -> void:
	for value in field.cells:
		_expect(value in [GeometryField.VOID, GeometryField.FLOOR, GeometryField.WALL], "Invalid geometry value.")


func _resolve_parameters(
	archetype: GenerationSemantics.Archetype,
	scale: GenerationSemantics.Scale,
	modifier: GenerationSemantics.GeometryModifier
) -> ResolvedGenerationParameters:
	var resolution := GenerationParameterResolver.resolve(
		CATALOG,
		LayoutRequest.new(archetype, scale, modifier)
	)
	_expect(resolution.is_success, "Resolver setup failed: %s" % resolution.error_message)
	return resolution.parameters


func _copy_parameters(source: ResolvedGenerationParameters) -> ResolvedGenerationParameters:
	return ResolvedGenerationParameters.new(
		source.raw_field_size,
		source.cut_window_radius,
		source.room_count,
		source.geometry_strategy,
		source.boundary_strategy,
		source.min_radius,
		source.max_radius,
		source.tax_interval,
		source.room_count_is_provisional
	)


func _seeded_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _expect_failure_contains(
	result: BaseGeometryResolution,
	expected_text: String
) -> void:
	_expect(not result.is_success, "Expected failure containing: %s" % expected_text)
	_expect(result.error_message.contains(expected_text), "Failure mismatch: %s" % result.error_message)
	_expect(result.error_message.begins_with(BaseGeometryGenerator.ERROR_ORIGIN), "Failure omitted source origin.")


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
