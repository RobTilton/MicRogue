extends SceneTree

const CATALOG: GenerationCatalog = preload(
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "GenerationParameterResolver/starter_generation_catalog.tres"
)

var checks: int = 0
var failures: PackedStringArray = []


func _initialize() -> void:
	_test_one_plus()
	_test_two_offset_pluses()
	_test_six_wall_sunder()
	_test_void_and_boundary_rejection()
	_test_input_preservation_and_refusals()
	_test_generated_pipeline()
	if failures.is_empty():
		print("room_judgement_test.gd: PASS (", checks, " checks)")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _test_one_plus() -> void:
	var result := _judge(["#######", "#######", "#.#.###", "#######", "#######"])
	_expect(result.saved_room_count == 1, "Short gap was not saved.")
	_expect(result.punch_count == 1, "Short gap did not use one plus.")
	_expect(result.sundered_room_count == 0 and result.rooms.size() == 1, "Saved result contract failed.")


func _test_two_offset_pluses() -> void:
	var result := _judge(["########", "########", "#.######", "#####.##", "########", "########"])
	_expect(result.saved_room_count == 1, "Five-wall offset gap was not saved.")
	_expect(result.punch_count == 2, "Five-wall offset gap did not use two pluses.")


func _test_six_wall_sunder() -> void:
	var result := _judge(["##########", "##########", "#.######.#", "##########", "##########"])
	_expect(result.saved_room_count == 0 and result.sundered_room_count == 1, "Six-wall gap was not sundered.")
	_expect(result.field.cells.count(GeometryField.FLOOR) == 1, "Sundered floor footprint survived.")


func _test_void_and_boundary_rejection() -> void:
	var void_result := _judge(["#######", "#######", "#.0.###", "#######", "#######"])
	_expect(void_result.saved_room_count == 0, "Judgement punched through void.")
	_expect(void_result.field.cells.count(GeometryField.VOID) == 1, "Judgement mutated void.")
	var edge_result := _judge(["#######", ".#.####", "#######", "#######"])
	_expect(edge_result.saved_room_count == 0, "Judgement punched across outer boundary.")


func _test_input_preservation_and_refusals() -> void:
	var field := _field(["#######", "#######", "#.#.###", "#######", "#######"])
	var original := field.cells.duplicate()
	var discovery := RoomDiscoveryFill.discover(field, true)
	RoomJudgement.judge(field, discovery.rooms)
	_expect(field.cells == original, "Judgement mutated its input field.")
	var no_rooms: Array[DiscoveredRoom] = []
	_expect(not RoomJudgement.judge(null, no_rooms).is_success, "Null field succeeded.")
	_expect(not RoomJudgement.judge(field, no_rooms).is_success, "Empty room input succeeded.")


func _test_generated_pipeline() -> void:
	var judged_maps: int = 0
	var judged_cases := PackedStringArray()
	var combination: int = 0
	for archetype in GenerationSemantics.required_archetypes():
		for scale in GenerationSemantics.required_scales():
			for modifier in GenerationSemantics.required_modifiers():
				var parameters := GenerationParameterResolver.resolve(
					CATALOG,
					LayoutRequest.new(archetype, scale, modifier)
				).parameters
				var seed: int = 9000 + combination
				var rng := RandomNumberGenerator.new()
				rng.seed = seed
				combination += 1
				var field := BaseGeometryGenerator.generate_with_rng(parameters, rng).field
				var discovery := RoomDiscoveryFill.discover(field, true)
				var correction := ConnectionCorrection.correct(
					field,
					discovery,
					ConnectionCorrection.standard_patterns()
				)
				var cull := PreJudgementCull.apply(correction.field, correction.rooms)
				if not cull.requires_judgement:
					continue
				judged_maps += 1
				judged_cases.append(
					"seed %d: %s/%s/%s"
					% [
						seed,
						GenerationSemantics.Archetype.find_key(archetype),
						GenerationSemantics.Scale.find_key(scale),
						GenerationSemantics.GeometryModifier.find_key(modifier),
					]
				)
				var judgement := RoomJudgement.judge(cull.field, cull.surviving_rooms)
				_expect(judgement.is_success, "Generated judgement failed.")
				_expect(judgement.rooms.size() == 1, "Generated judgement retained multiple room records.")
				_expect(RoomDiscoveryFill.discover(judgement.field, false).rooms.size() == 1, "Generated judged field was disconnected.")
	_expect(combination == 27, "Expected 27 generated catalog combinations.")
	print("room_judgement_test.gd: generated maps requiring judgement = ", judged_maps)
	print("room_judgement_test.gd: judgement cases = ", judged_cases)


func _judge(rows: Array[String]) -> RoomJudgementResult:
	var field := _field(rows)
	return RoomJudgement.judge(field, RoomDiscoveryFill.discover(field, true).rooms)


func _field(rows: Array[String]) -> GeometryField:
	var cells := PackedInt32Array()
	for row in rows:
		for character in row:
			match character:
				".": cells.append(GeometryField.FLOOR)
				"#": cells.append(GeometryField.WALL)
				"0": cells.append(GeometryField.VOID)
	return GeometryField.new(Vector2i(rows[0].length(), rows.size()), cells)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
