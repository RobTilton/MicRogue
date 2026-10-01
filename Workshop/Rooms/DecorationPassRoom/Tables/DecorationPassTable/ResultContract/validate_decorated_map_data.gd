extends SceneTree

const ORIGIN := "res://Workshop/Rooms/DecorationPassRoom/Tables/DecorationPassTable/ResultContract/validate_decorated_map_data.gd"
const Generator := preload("res://Production/Systems/RapidRoomGenerationSystem/rapid_room_generator.gd")
const Layout := preload("res://Production/Systems/RoomLayoutSystem/room_layout_tagger.gd")
const Semantics := preload("res://Production/Systems/RoomLayoutSystem/room_layout_semantics.gd")
const CatalogAdapter := preload("res://Workshop/Rooms/DecorationPassRoom/Tables/DecorationPassTable/CatalogAdapter/decoration_catalog_adapter.gd")
const Result := preload("res://Workshop/Rooms/DecorationPassRoom/Tables/DecorationPassTable/ResultContract/decorated_map_data.gd")


func _initialize() -> void:
	var validation_error := _validate()
	if not validation_error.is_empty():
		push_error("%s: %s" % [ORIGIN, validation_error])
		quit(1)
		return
	print("%s: passed complete coverage, invalid-input refusal, detached context, and source non-mutation checks" % ORIGIN)
	quit(0)


func _validate() -> String:
	var adapter: RefCounted = CatalogAdapter.create()
	if adapter == null:
		return "accepted catalog adapter did not initialize"
	for size: int in [4, 5]:
		var source: RapidRoomMapData = Generator.make_seeded_map(size, 8100 + size)
		if source == null or not Layout.tag_rooms_seeded(source, Semantics.Archetype.CAVE, 9100 + size):
			return "could not prepare Layout-completed source for size %d" % size
		var before := _snapshot(source)
		var assignments: Array[StringName] = []
		assignments.resize(source.cells.size())
		assignments.fill(&"atlas_x16_y00")
		if not Result.validate_inputs(source, assignments, adapter).is_empty():
			return "valid source and assignments were refused for size %d" % size
		var result: RefCounted = Result.create(source, assignments, adapter)
		if result == null:
			return "valid result construction failed for size %d" % size
		if result.width * result.height != source.cells.size() or result.sprite_ids.size() != source.cells.size():
			return "result dimensions or exact assignment coverage differ for size %d" % size
		if result.physical_cells != source.cells or result.room_count != source.room_count or result.doorways.size() != source.doorways.size():
			return "result did not preserve complete Rapid/Layout context for size %d" % size
		if result.rooms[0] == source.rooms[0] or (not result.doorways.is_empty() and result.doorways[0] == source.doorways[0]):
			return "result context aliases source records for size %d" % size
		assignments[0] = &"atlas_x17_y00"
		result.physical_cells[0] = -1
		result.rooms[0].room_type = &"ChangedOnlyInResult"
		if result.sprite_ids[0] != &"atlas_x16_y00":
			return "result sprite assignments alias caller input for size %d" % size
		if _snapshot(source) != before:
			return "result construction mutated its source for size %d" % size
		assignments[0] = &"atlas_x16_y00"
		var incomplete := assignments.duplicate()
		incomplete.remove_at(incomplete.size() - 1)
		if Result.validate_inputs(source, incomplete, adapter).is_empty():
			return "incomplete assignments were accepted"
		var unknown := assignments.duplicate()
		unknown[0] = &"atlas_x99_y99"
		if Result.validate_inputs(source, unknown, adapter).is_empty():
			return "unknown catalog assignment was accepted"
	return ""


func _snapshot(source: RapidRoomMapData) -> Array:
	var room_values: Array = []
	for room: RapidRoom in source.rooms:
		room_values.append([room.id, room.panel_count, room.floor_coordinates.duplicate(), room.room_type, room.tags.duplicate()])
	var doorway_values: Array = []
	for doorway: RapidRoomDoorway in source.doorways:
		doorway_values.append([doorway.position, doorway.footprint_center, doorway.axis])
	return [source.cells.duplicate(), source.room_count, room_values, doorway_values]
