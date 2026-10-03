extends SceneTree

const ORIGIN: String = "Workshop/Rooms/Workshop_Document_Verification/verify_rapid_document_claims.gd"

func _initialize() -> void:
	for requested_size: int in [1, 2, 3, 4]:
		var actual: RapidRoomMapData = RapidRoomGenerator.make_seeded_map(requested_size, 42)
		var expected: RapidRoomMapData = RapidRoomGenerator.make_seeded_map(4, 42)
		if var_to_str(_snapshot(actual)) != var_to_str(_snapshot(expected)):
			push_error("%s: FAIL size normalization at requested size %d" % [ORIGIN, requested_size])
			quit(1)
			return
	print("%s: PASS exact seeded size normalization for requests 1/2/3/4 at seed 42" % ORIGIN)
	var data: RapidRoomMapData = RapidRoomGenerator.make_seeded_map(4, 42)
	var side: int = int(sqrt(float(data.cells.size())))
	for doorway: RapidRoomDoorway in data.doorways:
		var direction: Vector2i = Vector2i.RIGHT if doorway.axis == RapidRoomDoorway.Axis.HORIZONTAL else Vector2i.DOWN
		for neighbor: Vector2i in [doorway.position - direction, doorway.position + direction]:
			if data.cells[neighbor.y * side + neighbor.x] != RapidRoomMapData.FLOOR:
				push_error("%s: FAIL documented traversal-axis floor guarantee; size=4 seed=42 position=%s footprint_center=%s axis=%d door_item_axis=%d neighbor=%s cell=%d" % [ORIGIN, doorway.position, doorway.footprint_center, doorway.axis, doorway.door_item_axis, neighbor, data.cells[neighbor.y * side + neighbor.x]])
				quit(1)
				return
	print("%s: PASS documented traversal-axis floor guarantee for size=4 seed=42" % ORIGIN)
	quit(0)

func _snapshot(data: RapidRoomMapData) -> Array:
	var rooms: Array = []
	for room: RapidRoom in data.rooms:
		rooms.append([room.id, room.panel_count, room.floor_coordinates, room.room_type, room.tags])
	var doorways: Array = []
	for doorway: RapidRoomDoorway in data.doorways:
		doorways.append([doorway.position, doorway.footprint_center, doorway.axis, doorway.door_item_axis])
	return [data.cells, data.room_count, rooms, doorways]
