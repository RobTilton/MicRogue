extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/PackageAndSurface/Tests/test_system_integration.gd"

var _checks: int = 0
var _generation_times: Array[int] = []
var _interpretation_times: Array[int] = []
var _total_times: Array[int] = []
var _purpose_catalog: InitialPurposeCatalog


func _init() -> void:
	_purpose_catalog = InitialPurposeCatalog.create()
	var pairings: Array[Dictionary] = [
		{"archetype": GenerationSemantics.Archetype.DUNGEON, "purpose": LayoutInterpretationSemantics.Purpose.PRISON, "label": "DUNGEON/PRISON"},
		{"archetype": GenerationSemantics.Archetype.DUNGEON, "purpose": LayoutInterpretationSemantics.Purpose.CATACOMB, "label": "DUNGEON/CATACOMB"},
		{"archetype": GenerationSemantics.Archetype.TOWER, "purpose": LayoutInterpretationSemantics.Purpose.MAGE_TOWER, "label": "TOWER/MAGE_TOWER"},
		{"archetype": GenerationSemantics.Archetype.TOWER, "purpose": LayoutInterpretationSemantics.Purpose.GUARD_TOWER, "label": "TOWER/GUARD_TOWER"},
		{"archetype": GenerationSemantics.Archetype.CAVE, "purpose": LayoutInterpretationSemantics.Purpose.BURROW_NEST, "label": "CAVE/BURROW_NEST"},
		{"archetype": GenerationSemantics.Archetype.CAVE, "purpose": LayoutInterpretationSemantics.Purpose.MINE_SHAFT, "label": "CAVE/MINE_SHAFT"},
	]
	var expected_runs: int = pairings.size() * GenerationSemantics.required_scales().size()
	for pairing: Dictionary in pairings:
		for scale: GenerationSemantics.Scale in GenerationSemantics.required_scales():
			if not _run_case(pairing, scale):
				push_error("%s: FAIL at run %d of %d (%d completed checks)." % [ORIGIN, _total_times.size() + 1, expected_runs, _checks])
				quit(1)
				return
	_print_timing_summary()
	print("%s: PASS (%d checks across %d of %d active runs)." % [ORIGIN, _checks, expected_runs, expected_runs])
	quit(0)


func _run_case(pairing: Dictionary, scale: GenerationSemantics.Scale) -> bool:
	var label: String = "%s/%s" % [pairing["label"], _scale_name(scale)]
	var generation_started: int = Time.get_ticks_usec()
	var map_data: MapData = GeneratorCaller.make_map(MapParameters.new(
		pairing["archetype"],
		scale,
		GenerationSemantics.GeometryModifier.STANDARD
	))
	var generation_elapsed: int = Time.get_ticks_usec() - generation_started
	if not _require(map_data != null, "%s generator returned MapData" % label):
		return false
	var original_cells: PackedInt32Array = map_data.cells.duplicate()
	var interpretation_started: int = Time.get_ticks_usec()
	var data: InterpretationData = LayoutInterpreter.interpret(map_data, pairing["purpose"], scale)
	var interpretation_elapsed: int = Time.get_ticks_usec() - interpretation_started
	if not _require(data != null, "%s interpretation returned a complete package" % label):
		return false
	_generation_times.append(generation_elapsed)
	_interpretation_times.append(interpretation_elapsed)
	_total_times.append(generation_elapsed + interpretation_elapsed)
	if not _require(data.map_data == map_data, "%s exact MapData identity" % label):
		return false
	if not _require(map_data.cells == original_cells, "%s physical cells unchanged" % label):
		return false
	if not _require(data.purpose == pairing["purpose"], "%s purpose preserved" % label):
		return false
	if not _require(data.get_zone(data.entrance_zone_id).area_role == LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA, "%s Entrance exists" % label):
		return false
	if not _require(data.get_zone(data.boss_zone_id).area_role == LayoutInterpretationSemantics.AreaRole.BOSS_AREA, "%s Boss exists" % label):
		return false
	if not _require(_required_counts_match(data, _purpose_catalog.get_definition(pairing["purpose"], scale)), "%s required multiplicities" % label):
		return false
	if not _require(_relationships_resolve(data), "%s relationships resolve" % label):
		return false
	if not _require(_progression_metadata_matches(data, _purpose_catalog.get_definition(pairing["purpose"], scale)), "%s progression metadata" % label):
		return false
	if not _require(_ownership_agrees(data), "%s ownership agreement" % label):
		return false
	if not _require(_unzoned_agrees(data), "%s unzoned agreement" % label):
		return false
	if not _require(_coverage_agrees(data), "%s coverage agreement" % label):
		return false
	if not _require(_exercise_transfer(data), "%s ownership transfer" % label):
		return false
	print("%s: %s generation=%dus interpretation=%dus total=%dus zones=%d coverage=%.3f" % [
		ORIGIN,
		label,
		generation_elapsed,
		interpretation_elapsed,
		generation_elapsed + interpretation_elapsed,
		data.get_zone_ids().size(),
		data.coverage_ratio,
	])
	return true


func _required_counts_match(data: InterpretationData, definition: LayoutPurposeDefinition) -> bool:
	for requirement: LayoutAreaRequirement in definition.requirements:
		var count: int = 0
		for zone_id: int in data.get_zone_ids():
			if data.get_zone(zone_id).requirement_id == requirement.id:
				count += 1
		if count < requirement.minimum_count or count > requirement.maximum_count:
			return false
	return true


func _relationships_resolve(data: InterpretationData) -> bool:
	for zone_id: int in data.get_zone_ids():
		var zone: InterpretationZone = data.get_zone(zone_id)
		if zone.relationship_kind == LayoutInterpretationSemantics.RelationshipKind.NONE or zone.relationship_kind == LayoutInterpretationSemantics.RelationshipKind.PROGRESSION_TARGETS:
			continue
		if zone.target_zone_ids.is_empty():
			return false
		for target_zone_id: int in zone.target_zone_ids:
			if data.get_zone(target_zone_id) == null:
				return false
	return true


func _progression_metadata_matches(data: InterpretationData, definition: LayoutPurposeDefinition) -> bool:
	var targets_by_requirement: Dictionary = {}
	for requirement: LayoutAreaRequirement in definition.requirements:
		if requirement.relationship_kind == LayoutInterpretationSemantics.RelationshipKind.PROGRESSION_TARGETS:
			targets_by_requirement[requirement.id] = requirement.progression_targets_percent
	for zone_id: int in data.get_zone_ids():
		var zone: InterpretationZone = data.get_zone(zone_id)
		if zone.progression_target_percent < 0:
			continue
		if not targets_by_requirement.has(zone.requirement_id):
			return false
		if zone.progression_target_percent not in targets_by_requirement[zone.requirement_id]:
			return false
	return true


func _ownership_agrees(data: InterpretationData) -> bool:
	var seen: Dictionary = {}
	for zone_id: int in data.get_zone_ids():
		for coordinate: Vector2i in data.get_zone(zone_id).get_coordinates():
			if seen.has(coordinate) or data.get_zone_id_at(coordinate) != zone_id:
				return false
			seen[coordinate] = zone_id
	return true


func _unzoned_agrees(data: InterpretationData) -> bool:
	var expected: Dictionary = {}
	for y: int in range(data.map_data.height):
		for x: int in range(data.map_data.width):
			var coordinate := Vector2i(x, y)
			var index: int = y * data.map_data.width + x
			if data.map_data.cells[index] == MapData.FLOOR and data.get_zone_id_at(coordinate) == 0:
				expected[coordinate] = true
	if expected.size() != data.unzoned_floor.size():
		return false
	for coordinate: Vector2i in data.unzoned_floor:
		if not expected.has(coordinate):
			return false
	return true


func _coverage_agrees(data: InterpretationData) -> bool:
	var floor_count: int = 0
	var claimed_count: int = 0
	for y: int in range(data.map_data.height):
		for x: int in range(data.map_data.width):
			var index: int = y * data.map_data.width + x
			if data.map_data.cells[index] != MapData.FLOOR:
				continue
			floor_count += 1
			if data.get_zone_id_at(Vector2i(x, y)) > 0:
				claimed_count += 1
	return floor_count > 0 and is_equal_approx(data.coverage_ratio, float(claimed_count) / float(floor_count))


func _exercise_transfer(data: InterpretationData) -> bool:
	var destination: InterpretationZone = data.get_zone(data.boss_zone_id)
	for zone_id: int in data.get_zone_ids():
		if zone_id == destination.id:
			continue
		var source: InterpretationZone = data.get_zone(zone_id)
		if source.coordinate_count() == 0:
			continue
		var coordinate: Vector2i = source.get_coordinates().front()
		var destination_count: int = destination.coordinate_count()
		if not data.reassign_cells([coordinate], destination.id):
			return false
		return data.get_zone_id_at(coordinate) == destination.id and destination.coordinate_count() == destination_count + 1
	return false


func _require(condition: bool, message: String) -> bool:
	_checks += 1
	if condition:
		return true
	push_error("%s: integration check failed: %s." % [ORIGIN, message])
	return false


func _scale_name(scale: GenerationSemantics.Scale) -> String:
	match scale:
		GenerationSemantics.Scale.SMALL:
			return "SMALL"
		GenerationSemantics.Scale.MEDIUM:
			return "MEDIUM"
		GenerationSemantics.Scale.LARGE:
			return "LARGE"
	return "INVALID"


func _print_timing_summary() -> void:
	print("%s: generation timing min=%dus max=%dus average=%dus" % [ORIGIN, _minimum(_generation_times), _maximum(_generation_times), _average(_generation_times)])
	print("%s: interpretation timing min=%dus max=%dus average=%dus" % [ORIGIN, _minimum(_interpretation_times), _maximum(_interpretation_times), _average(_interpretation_times)])
	print("%s: total timing min=%dus max=%dus average=%dus" % [ORIGIN, _minimum(_total_times), _maximum(_total_times), _average(_total_times)])


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
