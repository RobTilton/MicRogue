extends SceneTree

const ORIGIN := "Production/Assets/FantasySpriteCatalog/Validation/validate_fantasy_sprite_catalog.gd"
const ATLAS_PATH := "res://Production/Assets/FantasySpriteCatalog/Atlas/colored-transparent_packed.png"
const ATLAS_HASH := "801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74"
const CATALOG_PATH := "res://Production/Assets/FantasySpriteCatalog/Data/fantasy_sprite_catalog.json"
const CATALOG_HASH := "d82eb8e6f4666097145ea39bca76106383712dd4f910c4f2a16d62b158ef8948"
const SEMANTIC_PATH := "res://Production/Assets/FantasySpriteCatalog/Data/semantic_aliases_001.json"
const GENERATED := preload("res://Production/Assets/FantasySpriteCatalog/Godot/Generated/fantasy_sprite_regions.gd")
const API := preload("res://Production/Assets/FantasySpriteCatalog/Godot/fantasy_sprite_catalog.gd")


func _initialize() -> void:
	var error := _validate()
	if not error.is_empty():
		push_error("%s: %s" % [ORIGIN, error])
		quit(1)
		return
	print("%s: passed 486 catalog entries, semantics, generated lookup, atlas regions, and cached API textures" % ORIGIN)
	quit(0)


func _validate() -> String:
	if FileAccess.get_sha256(ATLAS_PATH) != ATLAS_HASH: return "atlas hash differs"
	if FileAccess.get_sha256(CATALOG_PATH) != CATALOG_HASH: return "catalog hash differs"
	var atlas := load(ATLAS_PATH) as Texture2D
	if atlas == null or Vector2i(atlas.get_size()) != Vector2i(784, 352): return "atlas dimensions differ"
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var semantics = JSON.parse_string(FileAccess.get_file_as_string(SEMANTIC_PATH))
	if not catalog is Dictionary or not catalog.get("entries") is Array or int(catalog.get("entry_count", -1)) != 486: return "catalog structure/count differs"
	if catalog.get("atlas_path") != ATLAS_PATH or catalog.get("atlas_sha256") != ATLAS_HASH: return "catalog atlas authority differs"
	if not semantics is Dictionary or not semantics.get("aliases") is Array or int(semantics.get("alias_count", -1)) != 486 or int(semantics.get("record_count", -1)) != 486: return "semantic structure/count differs"
	if semantics.get("catalog_path") != CATALOG_PATH or semantics.get("catalog_sha256") != CATALOG_HASH: return "semantic catalog authority differs"
	if GENERATED.ENTRIES.size() != 486 or API.entry_count() != 486: return "generated/API count differs"
	var semantic_by_address: Dictionary = {}
	var aliases: Dictionary = {}
	for raw in semantics.aliases:
		if not raw is Dictionary: return "semantic record is not a dictionary"
		var address := str(raw.get("address", "")); var alias := str(raw.get("alias", ""))
		if semantic_by_address.has(address) or alias.is_empty() or aliases.has(alias) or bool(raw.get("remove_requested", true)): return "semantic identity/alias/removal contract differs"
		semantic_by_address[address] = raw; aliases[alias] = true
	for index in range(486):
		var entry: Dictionary = catalog.entries[index]
		var coordinate := Vector2i(int(entry.get("x", -1)), int(entry.get("y", -1)))
		var address := "atlas_x%02d_y%02d" % [coordinate.x, coordinate.y]
		var region := [coordinate.x * 16, coordinate.y * 16, 16, 16]
		if entry.get("id") != address or int(entry.get("frame", -1)) != coordinate.y * 49 + coordinate.x or not _array_matches(entry.get("region"), region): return "catalog geometry differs at index %d" % index
		if not semantic_by_address.has(address): return "semantic record missing for %s" % address
		var generated: Dictionary = GENERATED.ENTRIES[index]
		if generated.id != StringName(address) or generated.atlas_coords != coordinate or generated.frame != int(entry.frame) or generated.region != Rect2i(region[0], region[1], 16, 16): return "generated lookup differs at index %d" % index
		var api_entry = API.entry(StringName(address))
		if api_entry == null or api_entry.atlas_coords != coordinate: return "API entry differs at index %d" % index
	var first_id := StringName(str(catalog.entries[0].id))
	var texture_a: AtlasTexture = API.texture_for(first_id)
	var texture_b: AtlasTexture = API.texture_for(first_id)
	if texture_a == null or texture_a != texture_b or texture_a.atlas != atlas or Vector2i(texture_a.region.size) != Vector2i(16, 16) or not texture_a.filter_clip: return "texture ownership/cache contract differs"
	return ""


func _array_matches(value: Variant, expected: Array) -> bool:
	if not value is Array or value.size() != expected.size(): return false
	for index in range(expected.size()):
		if int(value[index]) != int(expected[index]): return false
	return true
