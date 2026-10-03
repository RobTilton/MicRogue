class_name DecorationTileMapLayerAdapter
extends RefCounted
const ORIGIN := "res://Production/Systems/DecorationPipeline/TileMapLayerAdapter/decoration_tile_map_layer_adapter.gd"
const ATLAS := preload("res://Production/Assets/FantasySpriteCatalog/Atlas/colored-transparent_packed.png")
const SOURCE_ID := 0
const FLOOR_BASE := Vector2i(0,0)
const WALL_BASE := Vector2i(1,0)
const EARTH_COLOR := Color("352015")
const ABYSS_COLOR := Color("050506")
static func render(base_target: TileMapLayer, sticker_target: TileMapLayer, result: RefCounted, adapter: RefCounted) -> bool:
	var error := validate_inputs(base_target,sticker_target,result,adapter)
	if not error.is_empty(): push_error("%s: %s" % [ORIGIN,error]); return false
	var base_set := TileSet.new(); base_set.tile_size = Vector2i(16,16)
	var base_source := TileSetAtlasSource.new(); base_source.texture_region_size = Vector2i(16,16)
	var image := Image.create(32,16,false,Image.FORMAT_RGBA8); image.fill_rect(Rect2i(0,0,16,16),EARTH_COLOR); image.fill_rect(Rect2i(16,0,16,16),ABYSS_COLOR)
	base_source.texture = ImageTexture.create_from_image(image); base_source.create_tile(FLOOR_BASE); base_source.create_tile(WALL_BASE); base_set.add_source(base_source,SOURCE_ID)
	var sticker_set := TileSet.new(); sticker_set.tile_size = Vector2i(16,16)
	var sticker_source := TileSetAtlasSource.new(); sticker_source.texture = ATLAS; sticker_source.texture_region_size = Vector2i(16,16)
	var coordinates: Dictionary = {}
	for id: StringName in result.sprite_ids:
		if id.is_empty() or coordinates.has(id): continue
		coordinates[id] = adapter.atlas_coords_for(id); sticker_source.create_tile(coordinates[id])
	sticker_set.add_source(sticker_source,SOURCE_ID)
	base_target.clear(); sticker_target.clear(); base_target.tile_set = base_set; sticker_target.tile_set = sticker_set
	for index in range(result.sprite_ids.size()):
		var cell := Vector2i(index % result.width,index / result.width)
		base_target.set_cell(cell,SOURCE_ID,FLOOR_BASE if result.physical_cells[index] == RapidRoomMapData.FLOOR else WALL_BASE,0)
		var id: StringName = result.sprite_ids[index]
		if not id.is_empty(): sticker_target.set_cell(cell,SOURCE_ID,coordinates[id],0)
	return true
static func validate_inputs(base_target: TileMapLayer, sticker_target: TileMapLayer, result: RefCounted, adapter: RefCounted) -> String:
	if base_target == null or sticker_target == null or base_target == sticker_target: return "distinct base and sticker layers are required"
	if result == null or not result.get("sprite_ids") is Array: return "Decoration result is null or incompatible"
	if adapter == null or not adapter.has_method("has"): return "catalog adapter is null or incompatible"
	if result.width * result.height != result.sprite_ids.size() or result.physical_cells.size() != result.sprite_ids.size(): return "result coverage differs"
	for id: StringName in result.sprite_ids:
		if not id.is_empty() and not adapter.has(id): return "unknown sticker id: %s" % id
	return ""
