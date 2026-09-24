extends SceneTree

const CATALOG: GenerationCatalog = preload(
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "GenerationParameterResolver/starter_generation_catalog.tres"
)

var _checks: int = 0
var _failures: PackedStringArray = []


func _initialize() -> void:
	_test_single_and_multiple_rooms()
	_test_diagonal_separation()
	_test_optional_shared_frontiers()
	_test_empty_floor()
	_test_null_refusal()
	_test_non_mutation_and_determinism()
	_test_all_generated_catalog_combinations()

	if _failures.is_empty():
		print("room_discovery_fill_test.gd: PASS (", _checks, " checks)")
		quit(0)
		return

	for failure in _failures:
		push_error(
			"res://Workshop/Rooms/GeneratorRoom/Tests/"
			+ "RoomDiscoveryFill/room_discovery_fill_test.gd: "
			+ failure
		)
	print("room_discovery_fill_test.gd: FAIL (", _failures.size(), " failures)")
	quit(1)


func _test_single_and_multiple_rooms() -> void:
	var single := RoomDiscoveryFill.discover(
		_field_from_rows(["#####", "#...#", "#####"]),
		false
	)
	_expect(single.is_success, "Single-room discovery failed.")
	_expect(single.rooms.size() == 1, "Single floor area did not produce one room.")
	_expect(single.rooms[0].id == 0, "First room ID was not zero.")
	_expect(single.rooms[0].floor_cells.size() == 3, "Single room floor count mismatch.")

	var multiple := RoomDiscoveryFill.discover(
		_field_from_rows(["#########", "#..##...#", "#..##...#", "#########"]),
		false
	)
	_expect(multiple.rooms.size() == 2, "Two floor areas did not produce two rooms.")
	_expect(multiple.rooms[0].floor_cells.size() == 4, "First room size mismatch.")
	_expect(multiple.rooms[1].floor_cells.size() == 6, "Second room size mismatch.")
	_expect(multiple.rooms[0].floor_cells[0] == Vector2i(1, 1), "Row-major room discovery changed.")
	_expect(multiple.rooms[1].floor_cells[0] == Vector2i(5, 1), "Second room discovery origin changed.")


func _test_diagonal_separation() -> void:
	var result := RoomDiscoveryFill.discover(
		_field_from_rows(["#####", "#.###", "##.##", "#####"]),
		false
	)
	_expect(result.rooms.size() == 2, "Diagonal floor cells were incorrectly connected.")


func _test_optional_shared_frontiers() -> void:
	var field := _field_from_rows(["#######", "#..#..#", "#..#..#", "#######"])
	var without_frontiers := RoomDiscoveryFill.discover(field, false)
	_expect(not without_frontiers.frontier_walls_included, "Frontier result flag ignored false.")
	for room in without_frontiers.rooms:
		_expect(room.frontier_walls.is_empty(), "Frontiers were calculated when disabled.")

	var with_frontiers := RoomDiscoveryFill.discover(field, true)
	_expect(with_frontiers.frontier_walls_included, "Frontier result flag ignored true.")
	_expect(with_frontiers.rooms.size() == 2, "Frontier fixture room count mismatch.")
	for shared_wall: Vector2i in [Vector2i(3, 1), Vector2i(3, 2)]:
		_expect(with_frontiers.rooms[0].frontier_walls.has(shared_wall), "First room missed a shared wall.")
		_expect(with_frontiers.rooms[1].frontier_walls.has(shared_wall), "Second room missed a shared wall.")
	for room in with_frontiers.rooms:
		_expect(_all_unique(room.frontier_walls), "Room frontier contained duplicate walls.")
		for wall in room.frontier_walls:
			_expect(field.get_cell(wall) == GeometryField.WALL, "Room frontier contained a non-wall cell.")


func _test_empty_floor() -> void:
	var result := RoomDiscoveryFill.discover(
		_field_from_rows(["#####", "#000#", "#####"]),
		true
	)
	_expect(result.is_success, "Empty-floor field was rejected.")
	_expect(result.rooms.is_empty(), "Empty-floor field returned rooms.")


func _test_null_refusal() -> void:
	var result := RoomDiscoveryFill.discover(null, false)
	_expect(not result.is_success, "Null field unexpectedly succeeded.")
	_expect(result.error_message.contains("GeometryField is required"), "Null refusal was unclear.")
	_expect(result.error_message.begins_with(RoomDiscoveryFill.ERROR_ORIGIN), "Null refusal omitted source origin.")


func _test_non_mutation_and_determinism() -> void:
	var field := _field_from_rows(["#######", "#..#..#", "#..#..#", "#######"])
	var original_cells: PackedInt32Array = field.cells.duplicate()
	var first := RoomDiscoveryFill.discover(field, true)
	var second := RoomDiscoveryFill.discover(field, true)
	_expect(field.cells == original_cells, "Discovery mutated its source field.")
	_expect(_results_match(first, second), "Repeated discovery was not deterministic.")


func _test_all_generated_catalog_combinations() -> void:
	var combination_index: int = 0
	for archetype in GenerationSemantics.required_archetypes():
		for scale in GenerationSemantics.required_scales():
			for modifier in GenerationSemantics.required_modifiers():
				var parameter_result := GenerationParameterResolver.resolve(
					CATALOG,
					LayoutRequest.new(archetype, scale, modifier)
				)
				_expect(parameter_result.is_success, "Catalog combination did not resolve.")
				if not parameter_result.is_success:
					continue
				var geometry_result := BaseGeometryGenerator.generate_with_rng(
					parameter_result.parameters,
					_seeded_rng(5000 + combination_index)
				)
				combination_index += 1
				_expect(geometry_result.is_success, "Catalog geometry generation failed.")
				if not geometry_result.is_success:
					continue
				var discovery := RoomDiscoveryFill.discover(geometry_result.field, true)
				_expect(discovery.is_success, "Generated-field discovery failed.")
				_expect_complete_partition(geometry_result.field, discovery.rooms)
	_expect(combination_index == 27, "Expected all 27 catalog combinations.")


func _expect_complete_partition(field: GeometryField, rooms: Array[DiscoveredRoom]) -> void:
	var ownership := {}
	for room in rooms:
		_expect(room.id >= 0 and room.id < rooms.size(), "Room ID was out of range.")
		_expect(_all_unique(room.floor_cells), "Room contained duplicate floor coordinates.")
		_expect(_all_unique(room.frontier_walls), "Room contained duplicate frontier walls.")
		for cell in room.floor_cells:
			_expect(field.get_cell(cell) == GeometryField.FLOOR, "Room contained a non-floor coordinate.")
			_expect(not ownership.has(cell), "Floor coordinate belonged to multiple rooms.")
			ownership[cell] = room.id
		for wall in room.frontier_walls:
			_expect(field.get_cell(wall) == GeometryField.WALL, "Frontier contained a non-wall coordinate.")
	var floor_count: int = field.cells.count(GeometryField.FLOOR)
	_expect(ownership.size() == floor_count, "Discovery did not cover every floor coordinate.")


func _field_from_rows(rows: Array[String]) -> GeometryField:
	var size := Vector2i(rows[0].length(), rows.size())
	var cells := PackedInt32Array()
	for row in rows:
		for symbol in row:
			match symbol:
				".":
					cells.append(GeometryField.FLOOR)
				"#":
					cells.append(GeometryField.WALL)
				_:
					cells.append(GeometryField.VOID)
	return GeometryField.new(size, cells)


func _all_unique(coordinates: Array[Vector2i]) -> bool:
	var seen := {}
	for coordinate in coordinates:
		if seen.has(coordinate):
			return false
		seen[coordinate] = true
	return true


func _results_match(first: RoomDiscoveryResult, second: RoomDiscoveryResult) -> bool:
	if first.frontier_walls_included != second.frontier_walls_included:
		return false
	if first.rooms.size() != second.rooms.size():
		return false
	for index in range(first.rooms.size()):
		if first.rooms[index].id != second.rooms[index].id:
			return false
		if first.rooms[index].floor_cells != second.rooms[index].floor_cells:
			return false
		if first.rooms[index].frontier_walls != second.rooms[index].frontier_walls:
			return false
	return true


func _seeded_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
