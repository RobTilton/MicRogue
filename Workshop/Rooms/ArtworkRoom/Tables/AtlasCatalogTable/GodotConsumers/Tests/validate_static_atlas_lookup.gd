extends SceneTree

const TEST_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_static_atlas_lookup.gd"
const SOURCE_CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json"
const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const EXPECTED_ATLAS_SHA256 := "801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74"
const EXPECTED_ENTRY_COUNT := 499
const Catalog := preload("res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/fantasy_sprite_catalog.gd")


func _initialize() -> void:
	if FileAccess.get_sha256(SOURCE_CATALOG_PATH) != EXPECTED_CATALOG_SHA256:
		_fail("accepted source catalog hash changed")
		return
	if FileAccess.get_sha256(Catalog.ATLAS_PATH) != EXPECTED_ATLAS_SHA256:
		_fail("packed atlas hash changed")
		return
	var payload = JSON.parse_string(FileAccess.get_file_as_string(SOURCE_CATALOG_PATH))
	if not payload is Dictionary or not payload.get("entries") is Array:
		_fail("accepted source catalog could not be parsed")
		return
	var source_entries: Array = payload.entries
	if source_entries.size() != EXPECTED_ENTRY_COUNT:
		_fail("source catalog count is %d; expected %d" % [source_entries.size(), EXPECTED_ENTRY_COUNT])
		return
	if Catalog.entry_count() != EXPECTED_ENTRY_COUNT:
		_fail("Godot catalog count is %d; expected %d" % [Catalog.entry_count(), EXPECTED_ENTRY_COUNT])
		return
	var ids: Array[StringName] = Catalog.all_ids()
	if ids.size() != EXPECTED_ENTRY_COUNT:
		_fail("all_ids count does not match")
		return
	var seen_ids: Dictionary = {}
	var seen_coordinates: Dictionary = {}
	for index in range(source_entries.size()):
		var source: Dictionary = source_entries[index]
		var id := StringName(source.id)
		if ids[index] != id:
			_fail("Godot id order differs at index %d" % index)
			return
		if seen_ids.has(id):
			_fail("duplicate id at index %d: %s" % [index, id])
			return
		seen_ids[id] = true
		if not Catalog.has(id):
			_fail("has() rejected accepted id: %s" % id)
			return
		var entry: RefCounted = Catalog.entry(id)
		var expected_coords := Vector2i(int(source.x), int(source.y))
		var expected_region := Rect2i(
			int(source.region[0]), int(source.region[1]),
			int(source.region[2]), int(source.region[3])
		)
		if entry == null or entry.id != id or entry.category != StringName(source.category):
			_fail("entry identity or category differs: %s" % id)
			return
		if entry.atlas_coords != expected_coords or entry.frame != int(source.frame) or entry.region != expected_region:
			_fail("entry geometry differs: %s" % id)
			return
		if Catalog.atlas_coords_for(id) != expected_coords or Catalog.frame_for(id) != int(source.frame):
			_fail("convenience lookup differs: %s" % id)
			return
		if seen_coordinates.has(expected_coords):
			_fail("duplicate coordinate: %s" % expected_coords)
			return
		seen_coordinates[expected_coords] = true
		var texture: AtlasTexture = Catalog.texture_for(id)
		if texture == null or texture.region != Rect2(expected_region):
			_fail("texture region differs: %s" % id)
			return
		if texture.get_size() != Vector2(16, 16) or not texture.filter_clip:
			_fail("texture size or filter_clip differs: %s" % id)
			return
		if texture.atlas == null or texture.atlas.resource_path != Catalog.ATLAS_PATH:
			_fail("texture atlas differs: %s" % id)
			return
		if Catalog.texture_for(id) != texture:
			_fail("texture cache did not return the same object: %s" % id)
			return
	if Catalog.has(&"atlas_x99_y99"):
		_fail("unknown id was accepted")
		return
	print("%s: passed %d entries, exact geometry, textures, caching, and unknown-id refusal" % [TEST_ORIGIN, EXPECTED_ENTRY_COUNT])
	quit(0)


func _fail(message: String) -> void:
	push_error("%s: %s" % [TEST_ORIGIN, message])
	quit(1)
