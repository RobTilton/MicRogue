extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/ClaimAndZoning/Tests/test_geometry_analysis.gd"

var _checks: int = 0
var _failures: int = 0


func _init() -> void:
	_test_floor_evidence()
	_test_distance_field()
	_test_detached_result()
	_test_production_map_cost()
	if _failures == 0:
		print("%s: PASS (%d checks)." % [ORIGIN, _checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)." % [ORIGIN, _failures, _checks])
	quit(1)


func _test_floor_evidence() -> void:
	var map_data: MapData = _map_from_rows([
		"#########",
		"#.......#",
		"#..###..#",
		"#.......#",
		"#########",
	])
	var original_cells: PackedInt32Array = map_data.cells.duplicate()
	var result: GeometryAnalysisResult = LayoutGeometryAnalyzer.analyze(map_data)
	_check(result.floor_coordinates.size() == 18, "all floor coordinates are recorded")
	_check(result.is_floor(Vector2i(1, 1)), "floor lookup recognizes floor")
	_check(not result.is_floor(Vector2i.ZERO), "floor lookup excludes wall")
	_check(map_data.cells == original_cells, "analysis does not mutate MapData")


func _test_distance_field() -> void:
	var result: GeometryAnalysisResult = LayoutGeometryAnalyzer.analyze(_open_map(9, 9))
	var origins: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 1)]
	var distances: Dictionary = result.distance_map_from_many(origins)
	_check(distances.size() == result.floor_coordinates.size(), "one distance flood reaches contracted connected floor")
	_check(int(distances[Vector2i(1, 1)]) == 0, "first source has zero distance")
	_check(int(distances[Vector2i(2, 1)]) == 0, "second source has zero distance")
	_check(int(distances[Vector2i(7, 7)]) == 11, "distance field is cardinal and multi-source")


func _test_detached_result() -> void:
	var result: GeometryAnalysisResult = LayoutGeometryAnalyzer.analyze(_open_map(9, 9))
	var duplicate: GeometryAnalysisResult = result.duplicate_result()
	duplicate.cells[0] = MapData.FLOOR
	duplicate.floor_coordinates.clear()
	_check(result.cells[0] == MapData.WALL, "duplicated cells are detached")
	_check(not result.floor_coordinates.is_empty(), "duplicated floor coordinates are detached")


func _test_production_map_cost() -> void:
	var map_data: MapData = GeneratorCaller.make_map(
		MapParameters.new(
			GenerationSemantics.Archetype.CAVE,
			GenerationSemantics.Scale.LARGE,
			GenerationSemantics.GeometryModifier.CONFINED
		)
	)
	_check(map_data != null, "Production generator returns large Cave MapData")
	if map_data == null:
		return
	var original_cells: PackedInt32Array = map_data.cells.duplicate()
	var started_microseconds: int = Time.get_ticks_usec()
	var result: GeometryAnalysisResult = LayoutGeometryAnalyzer.analyze(map_data)
	var elapsed_microseconds: int = Time.get_ticks_usec() - started_microseconds
	_check(not result.floor_coordinates.is_empty(), "large Production Cave exposes floor evidence")
	_check(map_data.cells == original_cells, "large Production Cave remains unmodified")
	print("%s: large Cave floor analysis completed in %d microseconds across %d floor tiles." % [ORIGIN, elapsed_microseconds, result.floor_coordinates.size()])


func _open_map(width: int, height: int) -> MapData:
	var cells := PackedInt32Array()
	for y: int in range(height):
		for x: int in range(width):
			var boundary: bool = x == 0 or y == 0 or x == width - 1 or y == height - 1
			cells.append(MapData.WALL if boundary else MapData.FLOOR)
	return MapData.new(width, height, cells)


func _map_from_rows(rows: Array[String]) -> MapData:
	var width: int = rows.front().length()
	var cells := PackedInt32Array()
	for row: String in rows:
		for character: String in row:
			cells.append(MapData.FLOOR if character == "." else MapData.WALL)
	return MapData.new(width, rows.size(), cells)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("%s: check failed: %s." % [ORIGIN, message])
