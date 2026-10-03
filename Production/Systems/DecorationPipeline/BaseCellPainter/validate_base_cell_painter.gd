extends SceneTree
const Generator := preload("res://Production/Systems/RapidRoomGenerationSystem/rapid_room_generator.gd")
const Layout := preload("res://Production/Systems/RoomLayoutSystem/room_layout_tagger.gd")
const Semantics := preload("res://Production/Systems/RoomLayoutSystem/room_layout_semantics.gd")
const Painter := preload("res://Production/Systems/DecorationPipeline/BaseCellPainter/base_cell_painter.gd")

func _initialize() -> void:
	for archetype in [Semantics.Archetype.CAVE, Semantics.Archetype.CATACOMB, Semantics.Archetype.NEST, Semantics.Archetype.SUB_PASSAGE]:
		for size in [4,5]:
			var source: RapidRoomMapData = _make_source(size, archetype)
			if source == null: return _fail("layout failed")
			var before := _snapshot(source); var a: RefCounted = Painter.paint(source, 42); var b: RefCounted = Painter.paint(source, 42)
			if a == null or a.cells.size() != source.cells.size(): return _fail("coverage failed")
			for index in range(a.cells.size()):
				if a.cells[index].role != b.cells[index].role or a.cells[index].variant_key != b.cells[index].variant_key: return _fail("determinism failed")
			if _snapshot(source) != before: return _fail("source mutated")
	print("BaseCellPainter: passed all four archetypes at sizes 4 and 5 with exact deterministic coverage and non-mutation")
	quit(0)
func _make_source(size: int, archetype: int) -> RapidRoomMapData:
	var source: RapidRoomMapData = Generator.make_seeded_map(size, 8100 + size)
	return source if Layout.tag_rooms_seeded(source, archetype, 9100 + size) else null
func _snapshot(source: RapidRoomMapData) -> String: return var_to_str([source.cells, source.rooms.map(func(r): return [r.id,r.panel_count,r.floor_coordinates,r.room_type,r.tags]), source.doorways.map(func(d): return [d.position,d.footprint_center,d.axis,d.door_item_axis])])
func _fail(message: String) -> void: push_error(message); quit(1)
