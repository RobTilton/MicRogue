class_name PreJudgementCull
extends RefCounted

const ERROR_ORIGIN := "MapGenerationSystem/PreJudgementCull"
const LESSER_TOTAL_PERCENT := 15
const LESSER_ROOM_SHARE_PERCENT := 40


static func apply(
	field: GeometryField,
	rooms: Array[DiscoveredRoom]
) -> PreJudgementCullResult:
	if field == null:
		return _failure("GeometryField is required.")
	var result := PreJudgementCullResult.new()
	result.field = GeometryField.new(field.size, field.cells.duplicate())
	if rooms.is_empty():
		return result

	var largest: DiscoveredRoom = rooms[0]
	for room in rooms:
		if room.floor_cells.size() > largest.floor_cells.size():
			largest = room
	result.surviving_rooms.append(largest)

	var lesser_rooms: Array[DiscoveredRoom] = []
	var lesser_total: int = 0
	for room in rooms:
		if room == largest:
			continue
		lesser_rooms.append(room)
		lesser_total += room.floor_cells.size()

	if lesser_rooms.is_empty():
		return result
	if lesser_total * 100 > largest.floor_cells.size() * LESSER_TOTAL_PERCENT:
		result.surviving_rooms.append_array(lesser_rooms)
		result.requires_judgement = true
		return result

	for room in lesser_rooms:
		if room.floor_cells.size() * 100 >= lesser_total * LESSER_ROOM_SHARE_PERCENT:
			result.surviving_rooms.append(room)
			result.requires_judgement = true
			continue
		result.culled_rooms.append(room)
		result.culled_floor_count += room.floor_cells.size()
		for cell in room.floor_cells:
			result.field.set_cell(cell, GeometryField.WALL)
	return result


static func _failure(message: String) -> PreJudgementCullResult:
	var result := PreJudgementCullResult.new()
	result.error_message = "%s: %s" % [ERROR_ORIGIN, message]
	return result
