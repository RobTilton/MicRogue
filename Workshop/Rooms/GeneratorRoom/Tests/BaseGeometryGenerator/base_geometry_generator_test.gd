extends SceneTree

const CATALOG: GenerationCatalog = preload(
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "GenerationParameterResolver/starter_generation_catalog.tres"
)
const CaveBoundaryPlanType = preload(
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "BaseGeometryGenerator/cave_boundary_plan.gd"
)

var _checks: int = 0
var _failures: PackedStringArray = []


func _initialize() -> void:
	_test_taxation_intervals()
	_test_supported_catalog_combinations()
	_test_cave_catalog_combinations()
	_test_cave_boundary_plans()
	_test_cave_random_start_variation()
	_test_cave_partial_chain_fallback()
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


func _test_cave_catalog_combinations() -> void:
	var success_count: int = 0
	for scale in GenerationSemantics.required_scales():
		for modifier in GenerationSemantics.required_modifiers():
			var parameters := _resolve_parameters(
				GenerationSemantics.Archetype.CAVE,
				scale,
				modifier
			)
			var result := BaseGeometryGenerator.generate_with_rng(
				parameters,
				_seeded_rng(2200 + success_count)
			)
			_expect(result.is_success, "Cave combination failed: %s" % result.error_message)
			if not result.is_success:
				continue
			success_count += 1
			_expect(result.field.size.x > 0 and result.field.size.y > 0, "Cave output was empty.")
			_expect(result.field.cells.size() == result.field.size.x * result.field.size.y, "Cave cell count mismatch.")
			_expect_only_floor_and_wall(result.field)
			_expect_square_boundary(result.field)
			_expect_floor_exists(result.field, "Cave output contained no floor.")
	_expect(success_count == 9, "Expected nine supported Cave combinations.")


func _test_cave_boundary_plans() -> void:
	var expected_counts: Array[int] = [4, 5, 6]
	var expected_radii: Array[int] = [5, 7, 10]
	for scale_index in range(GenerationSemantics.required_scales().size()):
		var scale: GenerationSemantics.Scale = GenerationSemantics.required_scales()[scale_index]
		var parameters := _resolve_parameters(
			GenerationSemantics.Archetype.CAVE,
			scale,
			GenerationSemantics.GeometryModifier.STANDARD
		)
		for seed_value in range(32):
			var plan: RefCounted = BaseGeometryGenerator.plan_cave_boundary(
				parameters,
				_seeded_rng(3000 + scale_index * 100 + seed_value)
			)
			_expect(plan.completed, "Cave plan unexpectedly returned a partial chain.")
			_expect(plan.centers.size() == expected_counts[scale_index], "Cave circle count mismatch.")
			_expect(plan.requested_circle_count == expected_counts[scale_index], "Requested Cave circle count mismatch.")
			_expect(plan.circle_radius == expected_radii[scale_index], "Cave circle radius mismatch.")
			_expect(plan.primary_axis_is_horizontal, "Cave did not follow the raw field's longer axis.")
			_expect(plan.noise_offsets.size() == plan.centers.size(), "Cave noise metadata mismatch.")
			var field_center := Vector2(parameters.raw_field_size - Vector2i.ONE) * 0.5
			var start_to_center: Vector2 = field_center - Vector2(plan.centers[0])
			var end_from_center: Vector2 = Vector2(plan.centers[-1]) - field_center
			_expect(start_to_center.dot(end_from_center) >= 0.0, "Cave chain did not pass through the field center.")
			_expect(
				plan.minimum_overlap_cells == ceili(float(plan.circle_radius * 2 + 1) * 0.20),
				"Cave overlap rounding mismatch."
			)
			for center_index in range(plan.centers.size()):
				var center: Vector2i = plan.centers[center_index]
				var safe_margin: int = plan.circle_radius + 1
				_expect(center.x >= safe_margin, "Cave circle crossed the left safety margin.")
				_expect(center.y >= safe_margin, "Cave circle crossed the top safety margin.")
				_expect(center.x <= parameters.raw_field_size.x - safe_margin - 1, "Cave circle crossed the right safety margin.")
				_expect(center.y <= parameters.raw_field_size.y - safe_margin - 1, "Cave circle crossed the bottom safety margin.")
				_expect(absi(plan.noise_offsets[center_index]) <= 3, "Cave noise exceeded its global bound.")
				if center_index == 0:
					continue
				_expect(
					absi(plan.noise_offsets[center_index] - plan.noise_offsets[center_index - 1]) <= 1,
					"Cave noise was not a bounded walk."
				)
				var maximum_distance: int = plan.circle_radius * 2 + 1 - plan.minimum_overlap_cells
				_expect(
					plan.centers[center_index - 1].distance_squared_to(center)
					<= maximum_distance * maximum_distance,
					"Adjacent Cave circles did not preserve minimum overlap."
				)


func _test_cave_random_start_variation() -> void:
	var parameters := _resolve_parameters(
		GenerationSemantics.Archetype.CAVE,
		GenerationSemantics.Scale.MEDIUM,
		GenerationSemantics.GeometryModifier.STANDARD
	)
	var saw_negative_side := false
	var saw_positive_side := false
	var starting_rows := {}
	for seed_value in range(64):
		var plan: RefCounted = BaseGeometryGenerator.plan_cave_boundary(parameters, _seeded_rng(4000 + seed_value))
		saw_positive_side = saw_positive_side or plan.starts_from_positive_side
		saw_negative_side = saw_negative_side or not plan.starts_from_positive_side
		starting_rows[plan.centers[0].y] = true
	_expect(saw_negative_side and saw_positive_side, "Cave start side was not randomized.")
	_expect(starting_rows.size() > 1, "Cave starting position along its side was not randomized.")


func _test_cave_partial_chain_fallback() -> void:
	var raw_cells := PackedInt32Array()
	raw_cells.resize(41 * 31)
	raw_cells.fill(GeometryField.FLOOR)
	var raw_field := GeometryField.new(Vector2i(41, 31), raw_cells)
	var partial_centers: Array[Vector2i] = [Vector2i(6, 15), Vector2i(13, 15)]
	var partial_plan: RefCounted = CaveBoundaryPlanType.new(
		partial_centers,
		5,
		4,
		false,
		true,
		PackedInt32Array([0, 0]),
		3
	)
	var result := BaseGeometryGenerator.cut_and_wrap_cave_from_plan(raw_field, partial_plan)
	_expect(not partial_plan.completed, "Partial-chain fixture was unexpectedly complete.")
	_expect(result.is_success, "Valid partial Cave chain was not preserved.")
	if result.is_success:
		_expect(result.field.size == Vector2i(20, 13), "Partial Cave bounds did not include one-cell expansion.")
		_expect_square_boundary(result.field)
		_expect_only_floor_and_wall(result.field)
		_expect_floor_exists(result.field, "Partial Cave output contained no preserved floor.")


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

	var cave_parameters := _resolve_parameters(
		GenerationSemantics.Archetype.CAVE,
		GenerationSemantics.Scale.LARGE,
		GenerationSemantics.GeometryModifier.CONFINED
	)
	var first_cave := BaseGeometryGenerator.generate_with_rng(cave_parameters, _seeded_rng(4434))
	var second_cave := BaseGeometryGenerator.generate_with_rng(cave_parameters, _seeded_rng(4434))
	_expect(first_cave.is_success and second_cave.is_success, "Cave determinism setup failed.")
	if first_cave.is_success and second_cave.is_success:
		_expect(first_cave.field.size == second_cave.field.size, "Deterministic Cave sizes differed.")
		_expect(first_cave.field.cells == second_cave.field.cells, "Identical Cave RNG seeds differed.")


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


func _expect_only_floor_and_wall(field: GeometryField) -> void:
	for value in field.cells:
		_expect(value in [GeometryField.FLOOR, GeometryField.WALL], "Cave output contained void or invalid geometry.")


func _expect_floor_exists(field: GeometryField, message: String) -> void:
	_expect(field.cells.has(GeometryField.FLOOR), message)


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
