extends SceneTree

var checks: int = 0
var failures: PackedStringArray = []


func _initialize() -> void:
	_test_single_room_bypass()
	_test_collective_threshold()
	_test_lesser_share_threshold()
	_test_all_lesser_rooms_culled()
	_test_null_refusal()
	if failures.is_empty():
		print("pre_judgement_cull_test.gd: PASS (", checks, " checks)")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _test_single_room_bypass() -> void:
	var fixture := _fixture([100])
	var result := PreJudgementCull.apply(fixture.field, fixture.rooms)
	_expect(result.surviving_rooms.size() == 1, "Single room was not preserved.")
	_expect(not result.requires_judgement, "Single room required judgement.")


func _test_collective_threshold() -> void:
	var exact := _fixture([100, 8, 7])
	var exact_result := PreJudgementCull.apply(exact.field, exact.rooms)
	_expect(exact_result.requires_judgement, "Exact 15% lesser total did not enter filtering.")
	_expect(exact_result.surviving_rooms.size() == 3, "Exact 15% survivors were wrong.")
	var above := _fixture([100, 8, 8])
	var above_result := PreJudgementCull.apply(above.field, above.rooms)
	_expect(above_result.requires_judgement, "Above-15% lesser total bypassed judgement.")
	_expect(above_result.culled_rooms.is_empty(), "Above-15% lesser rooms were culled.")


func _test_lesser_share_threshold() -> void:
	var fixture := _fixture([100, 6, 5, 4])
	var result := PreJudgementCull.apply(fixture.field, fixture.rooms)
	_expect(result.requires_judgement, "Exact 40% lesser room did not survive.")
	_expect(result.surviving_rooms.size() == 2, "Wrong rooms survived 40% filtering.")
	_expect(result.culled_floor_count == 9, "Culled floor count mismatch.")
	_expect(result.field.cells.count(GeometryField.FLOOR) == 106, "Culled floors were not converted to walls.")


func _test_all_lesser_rooms_culled() -> void:
	var fixture := _fixture([100, 5, 5, 5])
	var result := PreJudgementCull.apply(fixture.field, fixture.rooms)
	_expect(not result.requires_judgement, "Equal small rooms incorrectly required judgement.")
	_expect(result.surviving_rooms.size() == 1, "Largest room was not the only survivor.")
	_expect(result.culled_rooms.size() == 3, "Not all lesser rooms were culled.")
	_expect(result.culled_floor_count == 15, "All-cull floor count mismatch.")


func _test_null_refusal() -> void:
	var empty_rooms: Array[DiscoveredRoom] = []
	var result := PreJudgementCull.apply(null, empty_rooms)
	_expect(not result.is_success, "Null field succeeded.")
	_expect(result.error_message.begins_with(PreJudgementCull.ERROR_ORIGIN), "Null refusal omitted origin.")


func _fixture(sizes: Array[int]) -> Dictionary:
	var total: int = 0
	for size in sizes:
		total += size
	var cells := PackedInt32Array()
	cells.resize(total)
	cells.fill(GeometryField.FLOOR)
	var field := GeometryField.new(Vector2i(total, 1), cells)
	var rooms: Array[DiscoveredRoom] = []
	var cursor: int = 0
	for room_size in sizes:
		var floor_cells: Array[Vector2i] = []
		for index in range(room_size):
			floor_cells.append(Vector2i(cursor + index, 0))
		cursor += room_size
		rooms.append(DiscoveredRoom.new(rooms.size(), floor_cells, []))
	return {"field": field, "rooms": rooms}


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
