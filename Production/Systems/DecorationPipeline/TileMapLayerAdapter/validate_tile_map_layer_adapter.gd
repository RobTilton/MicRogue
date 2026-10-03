extends SceneTree
const Generator := preload("res://Production/Systems/RapidRoomGenerationSystem/rapid_room_generator.gd")
const Layout := preload("res://Production/Systems/RoomLayoutSystem/room_layout_tagger.gd")
const Semantics := preload("res://Production/Systems/RoomLayoutSystem/room_layout_semantics.gd")
const Catalog := preload("res://Production/Systems/DecorationPipeline/CatalogAdapter/decoration_catalog_adapter.gd")
const Profile := preload("res://Production/Systems/DecorationPipeline/FantasyDungeonProfile/fantasy_dungeon_profile.gd")
const Renderer := preload("res://Production/Systems/DecorationPipeline/TileMapLayerAdapter/decoration_tile_map_layer_adapter.gd")
func _initialize() -> void:
	var adapter: RefCounted = Catalog.create()
	for archetype in [Semantics.Archetype.CAVE,Semantics.Archetype.CATACOMB,Semantics.Archetype.NEST,Semantics.Archetype.SUB_PASSAGE]:
		for size in [4,5]:
			var map: RapidRoomMapData = Generator.make_seeded_map(size,8100+size); if not Layout.tag_rooms_seeded(map,archetype,9100+size): return _fail("layout failed")
			var result: RefCounted = Profile.decorate(map,42,adapter); var base := TileMapLayer.new(); var stickers := TileMapLayer.new()
			if not Renderer.render(base,stickers,result,adapter) or base.get_used_cells().size() != result.sprite_ids.size(): return _fail("base rendering failed")
			for index in range(result.sprite_ids.size()):
				var cell := Vector2i(index % result.width,index / result.width); var id: StringName = result.sprite_ids[index]
				if id.is_empty() and stickers.get_cell_source_id(cell) != -1: return _fail("unexpected sticker")
				if not id.is_empty() and stickers.get_cell_atlas_coords(cell) != adapter.atlas_coords_for(id): return _fail("sticker differs")
			base.free(); stickers.free()
	print("TileMapLayerAdapter: passed complete base and sparse sticker rendering for all archetypes at sizes 4 and 5"); quit(0)
func _fail(message:String)->void: push_error(message); quit(1)
