extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/PackageAndSurface/Tests/test_small_armory_stress.gd"
const SEEDS_PER_PAIRING: int = 10_000
const MINIMUM_STORAGE_TILES: int = 9

var _checks: int = 0
var _interpretation_times: Array[int] = []


func _init() -> void:
	if not _run_pairing(
		"SMALL_GUARD_TOWER",
		GenerationSemantics.Archetype.TOWER,
		LayoutInterpretationSemantics.Purpose.GUARD_TOWER,
		LayoutInterpretationSemantics.AreaRole.ARMORY_AREA,
		1
	):
		quit(1)
		return
	if not _run_pairing(
		"SMALL_MINE_SHAFT",
		GenerationSemantics.Archetype.CAVE,
		LayoutInterpretationSemantics.Purpose.MINE_SHAFT,
		LayoutInterpretationSemantics.AreaRole.EQUIPMENT_STORAGE_AREA,
		1
	):
		quit(1)
		return
	print("%s: interpretation timing min=%dus max=%dus average=%dus" % [ORIGIN, _minimum(_interpretation_times), _maximum(_interpretation_times), _average(_interpretation_times)])
	var total_seeds: int = SEEDS_PER_PAIRING * 2
	print("%s: PASS (%d checks across %d of %d zero-retry randomized seeds)." % [ORIGIN, _checks, total_seeds, total_seeds])
	quit(0)


func _run_pairing(
	label: String,
	archetype: GenerationSemantics.Archetype,
	purpose: LayoutInterpretationSemantics.Purpose,
	storage_role: LayoutInterpretationSemantics.AreaRole,
	expected_storage_count: int
) -> bool:
	for seed_index: int in range(SEEDS_PER_PAIRING):
		var map_data: MapData = GeneratorCaller.make_map(MapParameters.new(
			archetype,
			GenerationSemantics.Scale.SMALL,
			GenerationSemantics.GeometryModifier.STANDARD
		))
		if not _require(map_data != null, "%s seed %d generated MapData" % [label, seed_index + 1]):
			return false
		var original_cells: PackedInt32Array = map_data.cells.duplicate()
		var started: int = Time.get_ticks_usec()
		var data: InterpretationData = LayoutInterpreter.interpret(map_data, purpose, GenerationSemantics.Scale.SMALL)
		var elapsed: int = Time.get_ticks_usec() - started
		if not _require(data != null, "%s seed %d returned a complete package" % [label, seed_index + 1]):
			return false
		_interpretation_times.append(elapsed)
		if not _require(data.map_data == map_data and map_data.cells == original_cells, "%s seed %d preserved exact physical map" % [label, seed_index + 1]):
			return false
		var storage_count: int = 0
		for zone_id: int in data.get_zone_ids():
			var zone: InterpretationZone = data.get_zone(zone_id)
			if zone.area_role != storage_role:
				continue
			storage_count += 1
			if not _require(zone.coordinate_count() >= MINIMUM_STORAGE_TILES, "%s seed %d storage Zone retains 3x3 capacity" % [label, seed_index + 1]):
				return false
		if not _require(storage_count == expected_storage_count, "%s seed %d contains exactly %d storage Zones" % [label, seed_index + 1, expected_storage_count]):
			return false
		if not _require(_ownership_agrees(data), "%s seed %d ownership agrees" % [label, seed_index + 1]):
			return false
	print("%s: %s passed %d of %d randomized seeds." % [ORIGIN, label, SEEDS_PER_PAIRING, SEEDS_PER_PAIRING])
	return true


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
