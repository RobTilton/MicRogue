extends SceneTree

const CATALOG: GenerationCatalog = preload(
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "GenerationParameterResolver/starter_generation_catalog.tres"
)

var _checks: int = 0
var _failures: PackedStringArray = []


func _initialize() -> void:
	_test_pattern_catalog()
	_test_minimal_shared_wall_punch()
	_test_maximum_connection_priority()
	_test_each_pattern_can_apply()
	_test_iterative_room_merging()
	_test_unresolved_and_preservation()
	_test_contract_refusals()
	_test_generated_catalog_combinations()

	if _failures.is_empty():
		print("connection_correction_test.gd: PASS (", _checks, " checks)")
		quit(0)
		return
	for failure in _failures:
		push_error(
			"res://Workshop/Rooms/GeneratorRoom/Tests/"
			+ "ConnectionCorrection/connection_correction_test.gd: "
			+ failure
		)
	print("connection_correction_test.gd: FAIL (", _failures.size(), " failures)")
	quit(1)


func _test_pattern_catalog() -> void:
	var patterns := ConnectionCorrection.standard_patterns()
	_expect(patterns.size() == 9, "Standard catalog did not contain nine orientations.")
	var expected_ids: Array[StringName] = [
		&"single", &"line_horizontal", &"line_vertical",
		&"elbow_right_down", &"elbow_right_up", &"elbow_left_down", &"elbow_left_up",
		&"plus", &"square_3x3",
	]
	for index in range(patterns.size()):
		_expect(patterns[index].id == expected_ids[index], "Pattern catalog order changed.")
		_expect(_all_unique(patterns[index].offsets), "Pattern contained duplicate offsets.")


func _test_minimal_shared_wall_punch() -> void:
	var field := _field_from_rows(["#######", "#..#..#", "#..#..#", "#######"])
	var source_cells := field.cells.duplicate()
	var result := _correct(field, ConnectionCorrection.standard_patterns())
	_expect(result.is_success, "Shared-wall correction failed.")
	_expect(result.rooms.size() == 1, "Shared-wall rooms did not merge.")
	_expect(result.punches.size() == 1, "Shared-wall fixture did not use one punch.")
	_expect(result.punches[0].pattern_id == &"single", "Minimal shared wall did not select single punch.")
	_expect(result.mutated_cell_count == 1, "Single punch mutated the wrong cell count.")
	_expect(field.cells == source_cells, "Correction mutated its input field.")


func _test_maximum_connection_priority() -> void:
	var field := _field_from_rows([
		"#####",
		"##.##",
		"#.###",
		"##.##",
		"#####",
	])
	var result := _correct(field, [HolePunchPattern.new(&"single", [Vector2i.ZERO])])
	_expect(result.is_success, "Three-room correction failed.")
	_expect(result.punches.size() == 1, "Three-room fixture did not use one punch.")
	_expect(result.punches[0].connected_room_count == 3, "Correction did not maximize rooms connected.")
	_expect(result.rooms.size() == 1, "Three rooms did not merge through one punch.")


func _test_each_pattern_can_apply() -> void:
	var patterns := ConnectionCorrection.standard_patterns()
	for pattern in patterns:
		var field: GeometryField
		if pattern.id == &"line_horizontal":
			field = _field_from_rows(["########", "#..##..#", "########"])
		elif pattern.id == &"line_vertical":
			field = _field_from_rows(["#####", "##.##", "##.##", "#####", "##.##", "##.##", "#####"])
		else:
			field = _field_from_rows(["#####", "##.##", "#.###", "#####", "#####"])
		var result := _correct(field, [pattern])
		_expect(result.is_success, "Pattern correction failed: %s" % pattern.id)
		_expect(not result.punches.is_empty(), "Pattern was never applicable: %s" % pattern.id)
		if not result.punches.is_empty():
			_expect(result.punches[0].pattern_id == pattern.id, "Wrong pattern usage recorded.")


func _test_iterative_room_merging() -> void:
	var field := _field_from_rows(["##########", "#..#..#..#", "#..#..#..#", "##########"])
	var result := _correct(field, ConnectionCorrection.standard_patterns())
	_expect(result.is_success, "Iterative correction failed.")
	_expect(result.punches.size() == 2, "Three-room chain did not use two iterative punches.")
	_expect(result.rooms.size() == 1, "Iterative correction did not return fresh merged rooms.")
	for punch in result.punches:
		_expect(punch.room_count_after < punch.room_count_before, "Punch did not reduce room count.")
	for room in result.rooms:
		_expect(not room.frontier_walls.is_empty(), "Corrected room discarded maintained frontier data.")


func _test_unresolved_and_preservation() -> void:
	var field := _field_from_rows(["########", "#..00..#", "#..00..#", "########"])
	var original := field.cells.duplicate()
	var result := _correct(field, ConnectionCorrection.standard_patterns())
	_expect(result.is_success, "Unresolved fixture failed.")
	_expect(result.rooms.size() == 2, "Void-separated rooms should remain unresolved.")
	_expect(result.punches.is_empty(), "Correction punched through void.")
	_expect(result.field.cells.count(GeometryField.VOID) == original.count(GeometryField.VOID), "Correction mutated void.")
	_expect_outer_edge_matches(field, result.field)


func _test_contract_refusals() -> void:
	var field := _field_from_rows(["#####", "#...#", "#####"])
	var discovery := RoomDiscoveryFill.discover(field, true)
	_expect(not ConnectionCorrection.correct(null, discovery, ConnectionCorrection.standard_patterns()).is_success, "Null field succeeded.")
	_expect(not ConnectionCorrection.correct(field, null, ConnectionCorrection.standard_patterns()).is_success, "Null discovery succeeded.")
	var no_frontiers := RoomDiscoveryFill.discover(field, false)
	_expect(not ConnectionCorrection.correct(field, no_frontiers, ConnectionCorrection.standard_patterns()).is_success, "Frontier-free discovery succeeded.")
	_expect(not ConnectionCorrection.correct(field, discovery, []).is_success, "Empty pattern catalog succeeded.")


func _test_generated_catalog_combinations() -> void:
	var combination_index: int = 0
	var maximum_elapsed_usec: int = 0
	var maximum_label: String = ""
	var aggregate_usage: Dictionary[StringName, int] = {}
	var maximum_evaluations: int = 0
	for archetype in GenerationSemantics.required_archetypes():
		for scale in GenerationSemantics.required_scales():
			for modifier in GenerationSemantics.required_modifiers():
				var parameter_result := GenerationParameterResolver.resolve(
					CATALOG,
					LayoutRequest.new(archetype, scale, modifier)
				)
				var geometry_result := BaseGeometryGenerator.generate_with_rng(
					parameter_result.parameters,
					_seeded_rng(7000 + combination_index)
				)
				combination_index += 1
				var discovery := RoomDiscoveryFill.discover(geometry_result.field, true)
				var original_rooms: int = discovery.rooms.size()
				var original_cells := geometry_result.field.cells.duplicate()
				var started: int = Time.get_ticks_usec()
				var result := ConnectionCorrection.correct(
					geometry_result.field,
					discovery,
					ConnectionCorrection.standard_patterns()
				)
				var elapsed: int = Time.get_ticks_usec() - started
				if elapsed > maximum_elapsed_usec:
					maximum_elapsed_usec = elapsed
					maximum_label = "%s/%s/%s" % [archetype, scale, modifier]
				maximum_evaluations = maxi(maximum_evaluations, result.candidate_evaluations)
				for pattern_id in result.pattern_usage:
					aggregate_usage[pattern_id] = aggregate_usage.get(pattern_id, 0) + result.pattern_usage[pattern_id]
				_expect(result.is_success, "Generated correction failed.")
				_expect(result.rooms.size() <= original_rooms, "Correction increased room count.")
				_expect(geometry_result.field.cells == original_cells, "Correction mutated generated input.")
				_expect(result.field.cells.count(GeometryField.VOID) == original_cells.count(GeometryField.VOID), "Correction changed generated void count.")
				_expect_outer_edge_matches(geometry_result.field, result.field)
				for punch in result.punches:
					_expect(punch.room_count_after < punch.room_count_before, "Generated punch did not reduce rooms.")
	_expect(combination_index == 27, "Expected 27 corrected catalog combinations.")
	_expect(maximum_elapsed_usec < 250_000, "A generated correction exceeded 250 milliseconds.")
	print("connection_correction_test.gd: maximum generated correction usec = ", maximum_elapsed_usec, " at ", maximum_label)
	print("connection_correction_test.gd: maximum candidate evaluations = ", maximum_evaluations)
	print("connection_correction_test.gd: generated pattern usage = ", aggregate_usage)


func _correct(field: GeometryField, patterns: Array[HolePunchPattern]) -> ConnectionCorrectionResult:
	return ConnectionCorrection.correct(field, RoomDiscoveryFill.discover(field, true), patterns)


func _field_from_rows(rows: Array[String]) -> GeometryField:
	var cells := PackedInt32Array()
	for row in rows:
		for symbol in row:
			match symbol:
				".": cells.append(GeometryField.FLOOR)
				"#": cells.append(GeometryField.WALL)
				_: cells.append(GeometryField.VOID)
	return GeometryField.new(Vector2i(rows[0].length(), rows.size()), cells)


func _expect_outer_edge_matches(before: GeometryField, after: GeometryField) -> void:
	for x in range(before.size.x):
		_expect(before.get_cell(Vector2i(x, 0)) == after.get_cell(Vector2i(x, 0)), "Top edge changed.")
		_expect(before.get_cell(Vector2i(x, before.size.y - 1)) == after.get_cell(Vector2i(x, after.size.y - 1)), "Bottom edge changed.")
	for y in range(before.size.y):
		_expect(before.get_cell(Vector2i(0, y)) == after.get_cell(Vector2i(0, y)), "Left edge changed.")
		_expect(before.get_cell(Vector2i(before.size.x - 1, y)) == after.get_cell(Vector2i(after.size.x - 1, y)), "Right edge changed.")


func _all_unique(values: Array[Vector2i]) -> bool:
	var seen := {}
	for value in values:
		if seen.has(value): return false
		seen[value] = true
	return true


func _seeded_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
