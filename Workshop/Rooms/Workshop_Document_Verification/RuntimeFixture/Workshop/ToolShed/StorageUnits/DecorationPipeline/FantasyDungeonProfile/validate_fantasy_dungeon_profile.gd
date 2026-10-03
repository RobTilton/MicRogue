extends SceneTree
const Generator := preload("res://Production/Systems/RapidRoomGenerationSystem/rapid_room_generator.gd")
const Layout := preload("res://Production/Systems/RoomLayoutSystem/room_layout_tagger.gd")
const Semantics := preload("res://Production/Systems/RoomLayoutSystem/room_layout_semantics.gd")
const Adapter := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/CatalogAdapter/decoration_catalog_adapter.gd")
const Profile := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/FantasyDungeonProfile/fantasy_dungeon_profile.gd")

func _initialize() -> void:
	var adapter: RefCounted = Adapter.create()
	for alias: StringName in Profile.aliases():
		if adapter.id_for_alias(alias).is_empty(): return _fail("profile alias unresolved: %s" % alias)
	for archetype in [Semantics.Archetype.CAVE, Semantics.Archetype.CATACOMB, Semantics.Archetype.NEST, Semantics.Archetype.SUB_PASSAGE]:
		for size in [4,5]:
			var source: RapidRoomMapData = Generator.make_seeded_map(size, 8100 + size)
			if not Layout.tag_rooms_seeded(source, archetype, 9100 + size): return _fail("layout failed")
			var a: RefCounted = Profile.decorate(source, 42, adapter); var b: RefCounted = Profile.decorate(source, 42, adapter)
			if a == null or a.sprite_ids.size() != source.cells.size() or a.sprite_ids != b.sprite_ids: return _fail("coverage or determinism failed")
			var footprints: Dictionary = {}; var door_positions: Dictionary = {}
			for doorway: RapidRoomDoorway in source.doorways:
				door_positions[doorway.position] = true
				for y in range(doorway.footprint_center.y - 1, doorway.footprint_center.y + 2):
					for x in range(doorway.footprint_center.x - 1, doorway.footprint_center.x + 2): footprints[Vector2i(x,y)] = true
			var eligible := 0; var decorated := 0; var side: int = a.width
			for index in range(source.cells.size()):
				var coordinate := Vector2i(index % side,index / side); var id: StringName = a.sprite_ids[index]
				if source.cells[index] == RapidRoomMapData.WALL and id.is_empty(): return _fail("wall sticker missing")
				if door_positions.has(coordinate) and id.is_empty(): return _fail("door sticker missing")
				if source.cells[index] == RapidRoomMapData.FLOOR and not footprints.has(coordinate): eligible += 1; decorated += 0 if id.is_empty() else 1
			if decorated != int(round(float(eligible) * 0.03)): return _fail("floor sticker coverage is not exact 3 percent")
	print("FantasyDungeonProfile: passed all mapped aliases and all four archetypes at sizes 4 and 5")
	quit(0)
func _fail(message: String) -> void: push_error(message); quit(1)
