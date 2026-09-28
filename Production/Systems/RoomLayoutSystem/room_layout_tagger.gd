class_name RoomLayoutTagger
extends RefCounted

const ERROR_ORIGIN: String = "Production/Systems/RoomLayoutSystem/room_layout_tagger.gd"


static func tag_rooms(
	map_data: RapidRoomMapData,
	archetype: RoomLayoutSemantics.Archetype
) -> bool:
	var random := RandomNumberGenerator.new()
	random.randomize()
	return _tag_rooms(map_data, archetype, random)


static func tag_rooms_seeded(
	map_data: RapidRoomMapData,
	archetype: RoomLayoutSemantics.Archetype,
	seed: int
) -> bool:
	var random := RandomNumberGenerator.new()
	random.seed = seed
	return _tag_rooms(map_data, archetype, random)


static func _tag_rooms(
	map_data: RapidRoomMapData,
	archetype: RoomLayoutSemantics.Archetype,
	random: RandomNumberGenerator
) -> bool:
	if map_data == null or map_data.rooms.is_empty():
		return _refuse("Rapid returned no rooms to tag.")
	var board_size: int = _derive_board_size(map_data.rooms)
	if board_size < 1:
		return _refuse("room panel counts do not form a square layer-one board.")
	var catalog_entries: Array[RoomLayoutEntry] = RoomLayoutCatalog.entries_for(archetype)
	if catalog_entries.is_empty():
		return _refuse("Archetype %d has no room catalog." % archetype)

	var entrance: RapidRoom = _select_entrance(map_data.rooms, board_size)
	var boss: RapidRoom = _select_boss(map_data.rooms, board_size, entrance.id)
	if boss == null:
		return _refuse("final candidate window has no unassigned 2-4 panel BossRoom.")

	var assignments: Dictionary = {}
	assignments[entrance.id] = RoomLayoutCatalog.entrance_entry()
	assignments[boss.id] = RoomLayoutCatalog.boss_entry()
	for entry: RoomLayoutEntry in catalog_entries:
		var candidates: Array[RapidRoom] = []
		for room: RapidRoom in map_data.rooms:
			if not assignments.has(room.id) and entry.accepts(room.panel_count):
				candidates.append(room)
		if candidates.is_empty():
			continue
		var selected: RapidRoom = candidates[random.randi_range(0, candidates.size() - 1)]
		assignments[selected.id] = entry
	var fallback: RoomLayoutEntry = RoomLayoutCatalog.default_entry()
	for room: RapidRoom in map_data.rooms:
		if not assignments.has(room.id):
			assignments[room.id] = fallback

	for room: RapidRoom in map_data.rooms:
		var assignment: RoomLayoutEntry = assignments[room.id]
		room.assign_layout(assignment.room_type, assignment.tags)
	return true


static func _derive_board_size(rooms: Array[RapidRoom]) -> int:
	var panel_total: int = 0
	for room: RapidRoom in rooms:
		panel_total += room.panel_count
	var board_size: int = int(round(sqrt(float(panel_total))))
	return board_size if board_size * board_size == panel_total else 0


static func _select_entrance(rooms: Array[RapidRoom], board_size: int) -> RapidRoom:
	var selected: RapidRoom = rooms[0]
	for index: int in range(1, mini(board_size, rooms.size())):
		var candidate: RapidRoom = rooms[index]
		if candidate.panel_count < selected.panel_count:
			selected = candidate
	return selected


static func _select_boss(
	rooms: Array[RapidRoom],
	board_size: int,
	entrance_id: int
) -> RapidRoom:
	var selected: RapidRoom
	var first_index: int = maxi(0, rooms.size() - board_size)
	for index: int in range(first_index, rooms.size()):
		var candidate: RapidRoom = rooms[index]
		if candidate.id == entrance_id or candidate.panel_count < 2 or candidate.panel_count > 4:
			continue
		if selected == null or candidate.panel_count > selected.panel_count or (
			candidate.panel_count == selected.panel_count and candidate.id > selected.id
		):
			selected = candidate
	return selected


static func _refuse(message: String) -> bool:
	push_error("%s: %s" % [ERROR_ORIGIN, message])
	return false
