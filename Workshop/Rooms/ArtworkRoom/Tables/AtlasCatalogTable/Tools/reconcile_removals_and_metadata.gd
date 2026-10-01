extends SceneTree

const TOOL_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Tools/reconcile_removals_and_metadata.gd"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json"
const CATALOG_HISTORY_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/History/fantasy_sprite_catalog_499_snapshot024.json"
const SELECTION_SOURCE_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Selections/atlas_selection_004.json"
const SELECTION_OUTPUT_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Selections/atlas_selection_005.json"
const SEMANTIC_SOURCE_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_024.json"
const SEMANTIC_OUTPUT_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_025.json"

const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const EXPECTED_SELECTION_SHA256 := "a574fa00b2018ccdfef122202e42d406d0724a790a401ca3a22fe69ba43fd3e9"
const EXPECTED_SEMANTIC_SHA256 := "cc3d0dd62f49ff0524c3b55b305957e01336c13aec07f11c841ddc7aa5ec2c95"
const SOURCE_COUNT := 499
const REMOVAL_COUNT := 13
const RETAINED_COUNT := SOURCE_COUNT - REMOVAL_COUNT


func _initialize() -> void:
	for output_path in [CATALOG_HISTORY_PATH, SELECTION_OUTPUT_PATH, SEMANTIC_OUTPUT_PATH]:
		if FileAccess.file_exists(output_path):
			_fail("refused to overwrite existing output: %s" % output_path)
			return
	if FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256 or FileAccess.get_sha256(SELECTION_SOURCE_PATH) != EXPECTED_SELECTION_SHA256 or FileAccess.get_sha256(SEMANTIC_SOURCE_PATH) != EXPECTED_SEMANTIC_SHA256:
		_fail("an authoritative input hash differs")
		return
	var catalog_text := FileAccess.get_file_as_string(CATALOG_PATH)
	var catalog = JSON.parse_string(catalog_text)
	var selection = JSON.parse_string(FileAccess.get_file_as_string(SELECTION_SOURCE_PATH))
	var semantic = JSON.parse_string(FileAccess.get_file_as_string(SEMANTIC_SOURCE_PATH))
	if not catalog is Dictionary or not selection is Dictionary or not semantic is Dictionary:
		_fail("an authoritative input could not be parsed")
		return
	if catalog.entries.size() != SOURCE_COUNT or selection.selected_cells.size() != SOURCE_COUNT or semantic.aliases.size() != SOURCE_COUNT:
		_fail("an authoritative input count differs")
		return

	var catalog_by_address: Dictionary = {}
	var selection_by_address: Dictionary = {}
	var semantic_by_address: Dictionary = {}
	var removal_addresses: Dictionary = {}
	for entry: Dictionary in catalog.entries:
		catalog_by_address[entry.id] = entry
	for cell: Dictionary in selection.selected_cells:
		selection_by_address[_address_for_xy(int(cell.x), int(cell.y))] = cell
	for record: Dictionary in semantic.aliases:
		var address := str(record.address)
		semantic_by_address[address] = record
		if typeof(record.get("remove_requested")) != TYPE_BOOL:
			_fail("semantic removal flag is missing or non-Boolean: %s" % address)
			return
		if bool(record.remove_requested):
			removal_addresses[address] = true
	if catalog_by_address.size() != SOURCE_COUNT or selection_by_address.size() != SOURCE_COUNT or semantic_by_address.size() != SOURCE_COUNT or removal_addresses.size() != REMOVAL_COUNT:
		_fail("input identity or removal count differs")
		return
	for address in catalog_by_address:
		if not selection_by_address.has(address) or not semantic_by_address.has(address):
			_fail("input membership differs: %s" % address)
			return

	var retained_catalog: Array[Dictionary] = []
	var retained_selection: Array[Dictionary] = []
	var normalized_semantics: Array[Dictionary] = []
	for entry: Dictionary in catalog.entries:
		var address := str(entry.id)
		if removal_addresses.has(address):
			continue
		retained_catalog.append(entry.duplicate(true))
		retained_selection.append(selection_by_address[address].duplicate(true))
		normalized_semantics.append(_normalize_semantic(semantic_by_address[address]))
	if retained_catalog.size() != RETAINED_COUNT or retained_selection.size() != RETAINED_COUNT or normalized_semantics.size() != RETAINED_COUNT:
		_fail("retained output count differs")
		return

	var selection_output: Dictionary = selection.duplicate(true)
	selection_output.save_sequence = 5
	selection_output.selected_cells = retained_selection
	selection_output.selected_count = RETAINED_COUNT
	var selection_text := JSON.stringify(selection_output, "\t") + "\n"

	var catalog_output: Dictionary = catalog.duplicate(true)
	catalog_output.entries = retained_catalog
	catalog_output.entry_count = RETAINED_COUNT
	catalog_output.source_snapshot = SELECTION_OUTPUT_PATH
	var catalog_output_text := JSON.stringify(catalog_output, "\t") + "\n"
	var catalog_output_hash := _sha256_text(catalog_output_text)

	var semantic_output: Dictionary = semantic.duplicate(true)
	semantic_output.alias_count = RETAINED_COUNT
	semantic_output.aliases = normalized_semantics
	semantic_output.catalog_entry_count = RETAINED_COUNT
	semantic_output.catalog_sha256 = catalog_output_hash
	semantic_output.record_count = RETAINED_COUNT
	semantic_output.save_sequence = 25
	var semantic_text := JSON.stringify(semantic_output, "\t") + "\n"

	if not _round_trip_has_count(selection_text, "selected_cells", RETAINED_COUNT) or not _round_trip_has_count(catalog_output_text, "entries", RETAINED_COUNT) or not _round_trip_has_count(semantic_text, "aliases", RETAINED_COUNT):
		_fail("a generated JSON payload failed pre-write round-trip validation")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CATALOG_HISTORY_PATH.get_base_dir()))
	if not _write_exact_new(CATALOG_HISTORY_PATH, catalog_text):
		return
	if not _write_exact_new(SELECTION_OUTPUT_PATH, selection_text):
		return
	if not _write_exact_new(SEMANTIC_OUTPUT_PATH, semantic_text):
		return
	var catalog_file := FileAccess.open(CATALOG_PATH, FileAccess.WRITE)
	if catalog_file == null:
		_fail("could not update current catalog")
		return
	catalog_file.store_string(catalog_output_text)
	catalog_file.flush()
	catalog_file.close()
	if FileAccess.get_sha256(CATALOG_PATH) != catalog_output_hash:
		_fail("updated current catalog failed exact hash verification")
		return
	print("%s: reconciled %d removals; retained %d entries; catalog SHA-256 %s" % [TOOL_ORIGIN, REMOVAL_COUNT, RETAINED_COUNT, catalog_output_hash])
	quit(0)


func _normalize_semantic(source: Dictionary) -> Dictionary:
	var alias := str(source.alias)
	var category := _category_for_alias(alias)
	var family := _family_for_alias(alias)
	var tags: Array[String] = []
	for raw_tag in source.tags:
		var tag := str(raw_tag).to_lower()
		if tag in ["full_pass", "draft", "review_required"]:
			continue
		if not tag.is_empty() and not tags.has(tag):
			tags.append(tag)
	for token in alias.split("_"):
		if token.is_valid_int() or token.length() <= 1:
			continue
		if not tags.has(token):
			tags.append(token)
	if not tags.has(category):
		tags.append(category)
	tags.sort()
	var note := str(source.get("note", ""))
	if note.begins_with("Full Pass draft |"):
		note = ""
	return {
		"address": source.address,
		"alias": alias,
		"category": category,
		"family": family,
		"note": note,
		"remove_requested": false,
		"tags": tags,
	}


func _category_for_alias(alias: String) -> String:
	var head := alias.get_slice("_", 0)
	match head:
		"actor": return "actor"
		"armor": return "armor"
		"weapon", "projectile": return "weapon"
		"equipment": return "equipment"
		"shield": return "shield"
		"hit": return "effect"
		"item", "consumable": return "item"
		"deco": return "deco"
		"dungeon", "floor", "forest", "ground": return "terrain"
		"ladder": return "structure"
		"overworld": return "structure" if alias.begins_with("overworld_structure_") else "terrain"
		"unknown": return "unresolved"
		_: return "unresolved"


func _family_for_alias(alias: String) -> String:
	var tokens := alias.split("_")
	if tokens[0] == "actor":
		return "actor"
	if tokens[0] == "floor" and tokens.size() >= 5 and tokens[1] in ["outer", "inner"]:
		return "floor_%s_%s" % [tokens[2], tokens[3]]
	if tokens[-1].is_valid_int() and tokens[-1].length() == 3:
		return "_".join(tokens.slice(0, tokens.size() - 1))
	if tokens.size() >= 2:
		return "%s_%s" % [tokens[0], tokens[1]]
	return tokens[0]


func _address_for_xy(x: int, y: int) -> String:
	return "atlas_x%02d_y%02d" % [x, y]


func _sha256_text(value: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(value.to_utf8_buffer())
	return context.finish().hex_encode()


func _round_trip_has_count(text: String, array_key: String, expected: int) -> bool:
	var payload = JSON.parse_string(text)
	return payload is Dictionary and payload.get(array_key) is Array and payload[array_key].size() == expected


func _write_exact_new(path: String, text: String) -> bool:
	if FileAccess.file_exists(path):
		_fail("refused to overwrite new output: %s" % path)
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_fail("could not open new output: %s" % path)
		return false
	file.store_string(text)
	file.flush()
	file.close()
	if FileAccess.get_file_as_string(path) != text:
		_fail("new output failed exact read-back: %s" % path)
		return false
	return true


func _fail(message: String) -> void:
	push_error("%s: %s" % [TOOL_ORIGIN, message])
	quit(1)
