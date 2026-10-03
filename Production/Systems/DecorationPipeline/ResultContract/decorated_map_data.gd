class_name DecoratedMapData
extends RefCounted

const IMPLEMENTATION_ORIGIN := "res://Production/Systems/DecorationPipeline/ResultContract/decorated_map_data.gd"
const MapData := preload("res://Production/Systems/RapidRoomGenerationSystem/rapid_room_map_data.gd")
const Room := preload("res://Production/Systems/RapidRoomGenerationSystem/rapid_room.gd")
const Doorway := preload("res://Production/Systems/RapidRoomGenerationSystem/rapid_room_doorway.gd")

var width: int
var height: int
var physical_cells: PackedInt32Array
var sprite_ids: Array[StringName]
var rooms: Array[RapidRoom]
var room_count: int
var doorways: Array[RapidRoomDoorway]


static func create(
	source: MapData,
	assignments: Array[StringName],
	catalog_adapter: RefCounted
) -> RefCounted:
	var validation_error := validate_inputs(source, assignments, catalog_adapter)
	if not validation_error.is_empty():
		push_error("%s: %s" % [IMPLEMENTATION_ORIGIN, validation_error])
		return null
	var side_length := int(sqrt(float(source.cells.size())))
	var result: RefCounted = (load(IMPLEMENTATION_ORIGIN) as GDScript).new()
	result._initialize_from_validated_input(source, assignments, side_length)
	return result


static func validate_inputs(
	source: MapData,
	assignments: Array[StringName],
	catalog_adapter: RefCounted
) -> String:
	var source_error := validate_source(source)
	if not source_error.is_empty():
		return source_error
	if catalog_adapter == null or not catalog_adapter.has_method("entry_count") or not catalog_adapter.has_method("has"):
		return "catalog adapter is null or does not expose the validated adapter contract"
	if catalog_adapter.entry_count() <= 0:
		return "catalog adapter is null or has not passed authority validation"
	var cell_count := source.cells.size()
	if assignments.size() != cell_count:
		return "sprite assignment count %d does not equal physical cell count %d" % [assignments.size(), cell_count]
	for index: int in range(cell_count):
		var sprite_id := assignments[index]
		if sprite_id.is_empty():
			if source.cells[index] == MapData.WALL: return "wall sticker assignment %d is empty" % index
			continue
		if not catalog_adapter.has(sprite_id): return "sticker assignment %d is absent from the accepted catalog: %s" % [index, sprite_id]
	return ""


static func validate_source(source: MapData) -> String:
	if source == null:
		return "source RapidRoomMapData is null"
	var cell_count := source.cells.size()
	var side_length := int(round(sqrt(float(cell_count))))
	if cell_count <= 0 or side_length * side_length != cell_count:
		return "physical cells do not form a non-empty square map"
	for index: int in range(cell_count):
		var physical_cell := source.cells[index]
		if physical_cell != MapData.FLOOR and physical_cell != MapData.WALL:
			return "physical cell %d has unsupported value %d" % [index, physical_cell]
	if source.room_count != source.rooms.size() or source.room_count <= 0:
		return "room_count does not equal a non-empty rooms array"
	var owned_floor_coordinates: Dictionary = {}
	for index: int in range(source.rooms.size()):
		var room: RapidRoom = source.rooms[index]
		if room == null or room.id != index:
			return "rooms are null, unordered, or do not have contiguous IDs at index %d" % index
		if room.panel_count < 1 or room.panel_count > 4:
			return "room %d has unsupported panel count %d" % [room.id, room.panel_count]
		if room.room_type.is_empty():
			return "room %d has no Layout-assigned room type" % room.id
		for tag: StringName in room.tags:
			if tag.is_empty():
				return "room %d contains an empty Layout tag" % room.id
		for coordinate: Vector2i in room.floor_coordinates:
			var coordinate_error := _validate_coordinate(coordinate, side_length, "room %d floor" % room.id)
			if not coordinate_error.is_empty():
				return coordinate_error
			var cell_index := coordinate.y * side_length + coordinate.x
			if source.cells[cell_index] != MapData.FLOOR:
				return "room %d owns non-floor coordinate %s" % [room.id, coordinate]
			if owned_floor_coordinates.has(coordinate):
				return "room floor coordinate %s is owned more than once" % coordinate
			owned_floor_coordinates[coordinate] = true
	for index: int in range(source.doorways.size()):
		var doorway: RapidRoomDoorway = source.doorways[index]
		if doorway == null:
			return "doorway %d is null" % index
		var position_error := _validate_coordinate(doorway.position, side_length, "doorway %d position" % index)
		if not position_error.is_empty():
			return position_error
		var center_error := _validate_coordinate(doorway.footprint_center, side_length, "doorway %d footprint center" % index)
		if not center_error.is_empty():
			return center_error
		if doorway.axis != Doorway.Axis.HORIZONTAL and doorway.axis != Doorway.Axis.VERTICAL:
			return "doorway %d has unsupported axis %d" % [index, doorway.axis]
		if doorway.door_item_axis != Doorway.Axis.HORIZONTAL and doorway.door_item_axis != Doorway.Axis.VERTICAL:
			return "doorway %d has unsupported local door-item axis %d" % [index, doorway.door_item_axis]
		if source.cells[doorway.position.y * side_length + doorway.position.x] != MapData.FLOOR:
			return "doorway %d position is not floor" % index
		var traversal_step := Vector2i.RIGHT if doorway.door_item_axis == Doorway.Axis.HORIZONTAL else Vector2i.DOWN
		for adjacent: Vector2i in [doorway.position - traversal_step, doorway.position + traversal_step]:
			var adjacent_error := _validate_coordinate(adjacent, side_length, "doorway %d traversal neighbor" % index)
			if not adjacent_error.is_empty():
				return adjacent_error
			if source.cells[adjacent.y * side_length + adjacent.x] != MapData.FLOOR:
				return "doorway %d traversal neighbor is not floor" % index
	return ""


static func _validate_coordinate(coordinate: Vector2i, side_length: int, label: String) -> String:
	if coordinate.x < 0 or coordinate.y < 0 or coordinate.x >= side_length or coordinate.y >= side_length:
		return "%s coordinate %s is outside the map" % [label, coordinate]
	return ""


func _initialize_from_validated_input(
	source: MapData,
	assignments: Array[StringName],
	side_length: int
) -> void:
	width = side_length
	height = side_length
	physical_cells = source.cells.duplicate()
	sprite_ids = assignments.duplicate()
	rooms = []
	for room: RapidRoom in source.rooms:
		rooms.append(room.duplicate_detached())
	room_count = rooms.size()
	doorways = []
	for doorway: RapidRoomDoorway in source.doorways:
		doorways.append(doorway.duplicate_detached())
