extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/PackageAndSurface/Tests/test_guard_tower_medium_large_stress.gd"
const RUNS_PER_SCALE: int = 1_000

var _checks: int = 0
var _interpretation_times: Array[int] = []


func _init() -> void:
	if not _run_scale(GenerationSemantics.Scale.MEDIUM, 2, 1):
		quit(1)
		return
	if not _run_scale(GenerationSemantics.Scale.LARGE, 2, 2):
		quit(1)
		return
	print("%s: interpretation timing min=%dus max=%dus average=%dus" % [ORIGIN, _minimum(_interpretation_times), _maximum(_interpretation_times), _average(_interpretation_times)])
	print("%s: PASS (%d checks across 2,000 of 2,000 zero-retry randomized runs)." % [ORIGIN, _checks])
	quit(0)


func _run_scale(
	scale: GenerationSemantics.Scale,
	expected_armories: int,
	expected_barracks: int
) -> bool:
	var label: String = "MEDIUM_GUARD_TOWER" if scale == GenerationSemantics.Scale.MEDIUM else "LARGE_GUARD_TOWER"
	for run_index: int in range(RUNS_PER_SCALE):
		var map_data: MapData = GeneratorCaller.make_map(MapParameters.new(
			GenerationSemantics.Archetype.TOWER,
			scale,
			GenerationSemantics.GeometryModifier.STANDARD
		))
		if not _require(map_data != null, "%s run %d generated MapData" % [label, run_index + 1]):
			return false
		var original_cells: PackedInt32Array = map_data.cells.duplicate()
		var started: int = Time.get_ticks_usec()
		var data: InterpretationData = LayoutInterpreter.interpret(
			map_data,
			LayoutInterpretationSemantics.Purpose.GUARD_TOWER,
			scale
		)
		_interpretation_times.append(Time.get_ticks_usec() - started)
		if not _require(data != null, "%s run %d returned a complete package" % [label, run_index + 1]):
			return false
		if not _require(data.map_data == map_data and map_data.cells == original_cells, "%s run %d preserved exact physical map" % [label, run_index + 1]):
			return false
		if not _require(_count_role(data, LayoutInterpretationSemantics.AreaRole.ARMORY_AREA) == expected_armories, "%s run %d has %d Armories" % [label, run_index + 1, expected_armories]):
			return false
		if not _require(_count_role(data, LayoutInterpretationSemantics.AreaRole.BARRACKS_AREA) == expected_barracks, "%s run %d has %d Barracks" % [label, run_index + 1, expected_barracks]):
			return false
		if not _require(_count_role(data, LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA) == 1, "%s run %d has one Guard Post" % [label, run_index + 1]):
			return false
		if not _require(_ownership_agrees(data), "%s run %d ownership agrees" % [label, run_index + 1]):
			return false
	print("%s: %s passed %d of %d runs." % [ORIGIN, label, RUNS_PER_SCALE, RUNS_PER_SCALE])
	return true


func _count_role(data: InterpretationData, area_role: LayoutInterpretationSemantics.AreaRole) -> int:
	var count: int = 0
	for zone_id: int in data.get_zone_ids():
		if data.get_zone(zone_id).area_role == area_role:
			count += 1
	return count


func _ownership_agrees(data: InterpretationData) -> bool:
	var seen: Dictionary = {}
	for zone_id: int in data.get_zone_ids():
		for coordinate: Vector2i in data.get_zone(zone_id).get_coordinates():
			if seen.has(coordinate) or data.get_zone_id_at(coordinate) != zone_id:
				return false
			seen[coordinate] = zone_id
	return true


func _require(condition: bool, message: String) -> bool:
	_checks += 1
	if condition:
		return true
	push_error("%s: stress gate failed: %s." % [ORIGIN, message])
	return false


func _minimum(values: Array[int]) -> int:
	var result: int = values.front()
	for value: int in values:
		result = min(result, value)
	return result


func _maximum(values: Array[int]) -> int:
	var result: int = values.front()
	for value: int in values:
		result = max(result, value)
	return result


func _average(values: Array[int]) -> int:
	var total: int = 0
	for value: int in values:
		total += value
	return total / values.size()
