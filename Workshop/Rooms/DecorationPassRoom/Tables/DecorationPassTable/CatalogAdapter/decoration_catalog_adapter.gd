class_name DecorationCatalogAdapter
extends RefCounted

const IMPLEMENTATION_ORIGIN := "res://Workshop/Rooms/DecorationPassRoom/Tables/DecorationPassTable/CatalogAdapter/decoration_catalog_adapter.gd"
const CATALOG_PATH := "res://Workshop/WorkshopAssets/FantasySpriteCatalog/Data/fantasy_sprite_catalog.json"
const SEMANTIC_PATH := "res://Workshop/WorkshopAssets/FantasySpriteCatalog/Data/semantic_aliases_001.json"
const EXPECTED_CATALOG_SHA256 := "6e2d93232faebf9ea7ce5cd0623d312156ff80f8d4f3f061a2788eb1c549df71"
const EXPECTED_SEMANTIC_SHA256 := "7199e90a6247dcf72f5b646d8cb7cd6a355216787a3f1b15a8ec1ae7dabf7d52"
const EXPECTED_ENTRY_COUNT := 486
const Catalog := preload("res://Workshop/WorkshopAssets/FantasySpriteCatalog/Godot/fantasy_sprite_catalog.gd")
const Query := preload("res://Workshop/Rooms/DecorationPassRoom/Tables/DecorationPassTable/CatalogAdapter/decoration_sprite_query.gd")
const Record := preload("res://Workshop/Rooms/DecorationPassRoom/Tables/DecorationPassTable/CatalogAdapter/decoration_sprite_record.gd")

var _records_by_id: Dictionary = {}
var _ids_by_alias: Dictionary = {}
var _is_ready := false


static func create() -> RefCounted:
	var adapter: RefCounted = (load(IMPLEMENTATION_ORIGIN) as GDScript).new()
	var validation_error: String = adapter._load_and_validate_authority()
	if not validation_error.is_empty():
		push_error("%s: %s" % [IMPLEMENTATION_ORIGIN, validation_error])
		return null
	adapter._is_ready = true
	return adapter


func ids_for(query: Query) -> Array[StringName]:
	if not _require_ready():
		return []
	if query == null:
		push_error("%s: sprite query is null" % IMPLEMENTATION_ORIGIN)
		return []
	var query_error := query.validation_error()
	if not query_error.is_empty():
		push_error("%s: %s" % [IMPLEMENTATION_ORIGIN, query_error])
		return []
	var matches: Array[StringName] = []
	for id: StringName in _records_by_id:
		var record: Record = _records_by_id[id]
		if _matches(record, query):
			matches.append(id)
	matches.sort()
	if matches.is_empty():
		push_error("%s: sprite query matched no accepted catalog entries" % IMPLEMENTATION_ORIGIN)
	return matches


func id_for_alias(alias: StringName) -> StringName:
	if not _require_ready():
		return &""
	if alias.is_empty() or not _ids_by_alias.has(alias):
		push_error("%s: unknown sprite alias: %s" % [IMPLEMENTATION_ORIGIN, alias])
		return &""
	return _ids_by_alias[alias]


func unique_id_for(query: Query) -> StringName:
	var matches := ids_for(query)
	if matches.size() != 1:
		if matches.size() > 1:
			push_error("%s: unique sprite query is ambiguous; matched %d entries" % [IMPLEMENTATION_ORIGIN, matches.size()])
		return &""
	return matches[0]


func record(id: StringName) -> Record:
	if not _require_ready():
		return null
	if not _records_by_id.has(id):
		push_error("%s: unknown accepted sprite id: %s" % [IMPLEMENTATION_ORIGIN, id])
		return null
	return _records_by_id[id]


func has(id: StringName) -> bool:
	return _is_ready and _records_by_id.has(id)


func entry_count() -> int:
	return _records_by_id.size() if _is_ready else 0


func _require_ready() -> bool:
	if _is_ready:
		return true
	push_error("%s: adapter must be obtained through create() so catalog authority is validated before use" % IMPLEMENTATION_ORIGIN)
	return false


func _load_and_validate_authority() -> String:
	if FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256:
		return "catalog authority hash differs from the accepted contract"
	if FileAccess.get_sha256(SEMANTIC_PATH) != EXPECTED_SEMANTIC_SHA256:
		return "semantic authority hash differs from the accepted contract"
	var catalog_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var semantic_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SEMANTIC_PATH))
	if not catalog_data is Dictionary or not catalog_data.get("entries") is Array:
		return "catalog authority is malformed"
	if int(catalog_data.get("entry_count", -1)) != EXPECTED_ENTRY_COUNT:
		return "catalog authority entry count differs"
	if not semantic_data is Dictionary or not semantic_data.get("aliases") is Array:
		return "semantic authority is malformed"
	if int(semantic_data.get("alias_count", -1)) != EXPECTED_ENTRY_COUNT or int(semantic_data.get("record_count", -1)) != EXPECTED_ENTRY_COUNT:
		return "semantic authority record count differs"
	if semantic_data.get("catalog_path") != CATALOG_PATH or semantic_data.get("catalog_sha256") != EXPECTED_CATALOG_SHA256:
		return "semantic authority references a different catalog"
	if Catalog.entry_count() != EXPECTED_ENTRY_COUNT:
		return "Godot catalog API entry count differs"

	var catalog_ids: Dictionary = {}
	for raw_entry: Variant in catalog_data.entries:
		if not raw_entry is Dictionary:
			return "catalog authority contains a non-dictionary entry"
		var id := StringName(str(raw_entry.get("id", "")))
		if id.is_empty() or catalog_ids.has(id) or not Catalog.has(id):
			return "catalog identity is missing, duplicated, or absent from the Godot API: %s" % id
		catalog_ids[id] = true

	for raw_record: Variant in semantic_data.aliases:
		if not raw_record is Dictionary:
			return "semantic authority contains a non-dictionary record"
		var id := StringName(str(raw_record.get("address", "")))
		var alias := StringName(str(raw_record.get("alias", "")))
		var family := StringName(str(raw_record.get("family", "")))
		var category := StringName(str(raw_record.get("category", "")))
		if not catalog_ids.has(id) or _records_by_id.has(id):
			return "semantic sprite identity is unknown or duplicated: %s" % id
		if alias.is_empty() or _ids_by_alias.has(alias):
			return "semantic alias is missing or duplicated: %s" % alias
		if family.is_empty() or category.is_empty() or bool(raw_record.get("remove_requested", true)):
			return "semantic record is incomplete or marked for removal: %s" % id
		var raw_tags: Variant = raw_record.get("tags")
		if not raw_tags is Array or raw_tags.is_empty():
			return "semantic record has no valid tags: %s" % id
		var tags: Array[StringName] = []
		for raw_tag: Variant in raw_tags:
			var tag := StringName(str(raw_tag))
			if tag.is_empty() or tags.has(tag):
				return "semantic record has an empty or duplicate tag: %s" % id
			tags.append(tag)
		_records_by_id[id] = Record.new(id, alias, family, category, tags)
		_ids_by_alias[alias] = id

	if _records_by_id.size() != EXPECTED_ENTRY_COUNT or _records_by_id.size() != catalog_ids.size():
		return "catalog and semantic authority membership differs"
	return ""


func _matches(record: Record, query: Query) -> bool:
	if not query.alias.is_empty() and record.alias != query.alias:
		return false
	if not query.family.is_empty() and record.family != query.family:
		return false
	if not query.category.is_empty() and record.category != query.category:
		return false
	for required_tag: StringName in query.required_tags:
		if not record.tags.has(required_tag):
			return false
	return true
