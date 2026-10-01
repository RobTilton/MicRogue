class_name FantasySpriteCatalog
extends RefCounted

const IMPLEMENTATION_ORIGIN := "res://Workshop/WorkshopAssets/FantasySpriteCatalog/Godot/fantasy_sprite_catalog.gd"
const ATLAS_PATH := "res://Workshop/WorkshopAssets/FantasySpriteCatalog/Atlas/colored-transparent_packed.png"
const ATLAS_SHA256 := "801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74"
const CELL_SIZE := Vector2i(16, 16)
const COLUMN_COUNT := 49
const ROW_COUNT := 22
const EXPECTED_ENTRY_COUNT := 486
const AtlasTextureSource := preload(ATLAS_PATH)
const GeneratedRegions := preload("res://Workshop/WorkshopAssets/FantasySpriteCatalog/Godot/Generated/fantasy_sprite_regions.gd")
const EntrySource := preload("res://Workshop/WorkshopAssets/FantasySpriteCatalog/Godot/fantasy_sprite_entry.gd")

static var _entries: Dictionary = {}
static var _texture_cache: Dictionary = {}


static func has(id: StringName) -> bool:
	_ensure_initialized()
	return _entries.has(id)


static func entry(id: StringName) -> RefCounted:
	_ensure_initialized()
	if not _entries.has(id):
		push_error("%s: unknown sprite id: %s" % [IMPLEMENTATION_ORIGIN, id])
		return null
	return _entries[id]


static func texture_for(id: StringName) -> AtlasTexture:
	_ensure_initialized()
	if _texture_cache.has(id):
		return _texture_cache[id]
	var sprite_entry := entry(id)
	if sprite_entry == null:
		return null
	var texture := AtlasTexture.new()
	texture.atlas = AtlasTextureSource
	texture.region = Rect2(sprite_entry.region)
	texture.filter_clip = true
	_texture_cache[id] = texture
	return texture


static func atlas_coords_for(id: StringName) -> Vector2i:
	var sprite_entry := entry(id)
	return sprite_entry.atlas_coords if sprite_entry != null else Vector2i(-1, -1)


static func frame_for(id: StringName) -> int:
	var sprite_entry := entry(id)
	return sprite_entry.frame if sprite_entry != null else -1


static func all_ids() -> Array[StringName]:
	_ensure_initialized()
	var ids: Array[StringName] = []
	for id: StringName in _entries:
		ids.append(id)
	return ids


static func entry_count() -> int:
	_ensure_initialized()
	return _entries.size()


static func _ensure_initialized() -> void:
	if not _entries.is_empty():
		return
	for data: Dictionary in GeneratedRegions.ENTRIES:
		var id: StringName = data.id
		if _entries.has(id):
			push_error("%s: generated data contains duplicate id: %s" % [IMPLEMENTATION_ORIGIN, id])
			continue
		_entries[id] = EntrySource.new(
			id,
			data.category,
			data.atlas_coords,
			data.frame,
			data.region
		)
