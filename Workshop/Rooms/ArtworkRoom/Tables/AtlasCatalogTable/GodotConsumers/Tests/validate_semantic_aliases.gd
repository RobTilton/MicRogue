extends SceneTree

const TEST_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_semantic_aliases.gd"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json"
const SELECTION_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Selections/atlas_selection_004.json"
const ALIAS_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_003.json"
const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const EXPECTED_SELECTION_SHA256 := "a574fa00b2018ccdfef122202e42d406d0724a790a401ca3a22fe69ba43fd3e9"
const EXPECTED_ALIAS_SHA256 := "5c5fc50ae99b44ccb5315ba915ac22deab7ca7ea3e883cbc5a6a1ffd63dcef51"
const EXPECTED_ALIAS_COUNT := 19
const EXPECTED_RECORD_COUNT := 20
const EXPECTED_CATALOG_COUNT := 499

const EXPECTED_BY_FRAME := {
	18: "floor_outer_stone_a_nw", 19: "floor_outer_stone_a_n", 20: "floor_outer_stone_a_ne",
	67: "floor_outer_stone_a_w", 68: "floor_inner_stone_a_center", 69: "floor_outer_stone_a_e",
	116: "floor_outer_stone_a_sw", 117: "floor_outer_stone_a_s", 118: "floor_outer_stone_a_se",
	145: "armor_hood_000", 165: "floor_inner_stone_a_se", 166: "floor_inner_stone_a_sw",
	167: "floor_outer_stone_a_sw2ne", 168: "floor_outer_stone_a_nw2se", 192: "armor_belt_000",
	214: "floor_inner_stone_a_ne", 215: "floor_inner_stone_a_nw",
	216: "floor_outer_stone_a_se2nw", 217: "floor_outer_stone_a_ne2sw",
}


func _initialize() -> void:
	if FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256:
		_fail("catalog hash differs from the accepted 499-entry source")
		return
	if FileAccess.get_sha256(SELECTION_PATH) != EXPECTED_SELECTION_SHA256:
		_fail("selection snapshot 004 hash differs")
		return
	if FileAccess.get_sha256(ALIAS_PATH) != EXPECTED_ALIAS_SHA256:
		_fail("semantic snapshot 003 hash differs")
		return
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var selection = JSON.parse_string(FileAccess.get_file_as_string(SELECTION_PATH))
	var snapshot = JSON.parse_string(FileAccess.get_file_as_string(ALIAS_PATH))
	if not catalog is Dictionary or not catalog.get("entries") is Array:
		_fail("catalog could not be parsed")
		return
	if catalog.entries.size() != EXPECTED_CATALOG_COUNT or int(catalog.get("entry_count", -1)) != EXPECTED_CATALOG_COUNT:
		_fail("catalog count does not equal %d" % EXPECTED_CATALOG_COUNT)
		return
	if catalog.get("source_snapshot") != SELECTION_PATH:
		_fail("catalog does not identify selection snapshot 004 as its source")
		return
	if not selection is Dictionary or not selection.get("selected_cells") is Array:
		_fail("selection snapshot 004 could not be parsed")
		return
	if int(selection.get("schema_version", -1)) != 2 or int(selection.get("save_sequence", -1)) != 4:
		_fail("selection snapshot 004 schema or sequence differs")
		return
	if selection.selected_cells.size() != EXPECTED_CATALOG_COUNT or int(selection.get("selected_count", -1)) != EXPECTED_CATALOG_COUNT:
		_fail("selection snapshot 004 count differs")
		return
	var valid_addresses: Dictionary = {}
	var frame_by_address: Dictionary = {}
	for index in range(catalog.entries.size()):
		var entry: Dictionary = catalog.entries[index]
		var selected: Dictionary = selection.selected_cells[index]
		if int(selected.x) != int(entry.x) or int(selected.y) != int(entry.y) or int(selected.frame) != int(entry.frame):
			_fail("catalog differs from selection snapshot 004 at index %d" % index)
			return
		if selected.get("review_state") != "keep" or selected.region != entry.region:
			_fail("selection state or region differs at index %d" % index)
			return
		valid_addresses[entry.id] = true
		frame_by_address[entry.id] = int(entry.frame)
	if not snapshot is Dictionary or not snapshot.get("aliases") is Array:
		_fail("semantic snapshot could not be parsed")
		return
	if int(snapshot.get("schema_version", -1)) != 1 or int(snapshot.get("save_sequence", -1)) != 3:
		_fail("semantic snapshot schema or sequence differs")
		return
	if snapshot.get("catalog_path") != CATALOG_PATH or snapshot.get("catalog_sha256") != EXPECTED_CATALOG_SHA256:
		_fail("semantic snapshot catalog contract differs")
		return
	var aliases: Array = snapshot.aliases
	if aliases.size() != EXPECTED_RECORD_COUNT or int(snapshot.get("record_count", -1)) != EXPECTED_RECORD_COUNT or int(snapshot.get("alias_count", -1)) != EXPECTED_ALIAS_COUNT:
		_fail("semantic snapshot record or alias count differs")
		return
	var pattern := RegEx.new()
	pattern.compile("^[a-z0-9]+(?:_[a-z0-9]+)*$")
	var seen_addresses: Dictionary = {}
	var seen_aliases: Dictionary = {}
	var observed_by_frame: Dictionary = {}
	var named_count := 0
	var note_only_count := 0
	for entry in aliases:
		if not entry is Dictionary:
			_fail("alias entry is not a dictionary")
			return
		var address := str(entry.get("address", ""))
		var alias := str(entry.get("alias", ""))
		if not valid_addresses.has(address):
			_fail("alias address is not accepted: %s" % address)
			return
		if seen_addresses.has(address) or (not alias.is_empty() and seen_aliases.has(alias)):
			_fail("duplicate address or named alias: %s / %s" % [address, alias])
			return
		if not alias.is_empty() and pattern.search(alias) == null:
			_fail("alias is not lowercase snake_case: %s" % alias)
			return
		if not alias.is_empty() and (str(entry.get("category", "")).is_empty() or str(entry.get("family", "")).is_empty()):
			_fail("category or family is empty: %s" % address)
			return
		if not entry.get("tags") is Array:
			_fail("tags are not an array: %s" % address)
			return
		seen_addresses[address] = true
		if not alias.is_empty():
			seen_aliases[alias] = true
			observed_by_frame[frame_by_address[address]] = alias
			named_count += 1
		elif str(entry.get("note", "")).is_empty():
			_fail("unnamed semantic record has no note: %s" % address)
			return
		else:
			note_only_count += 1
			if address != "atlas_x01_y01" or entry.note != "Tree number 2":
				_fail("note-only test record did not round-trip exactly")
				return
	if named_count != EXPECTED_ALIAS_COUNT or note_only_count != 1:
		_fail("named or note-only record count differs")
		return
	if observed_by_frame != EXPECTED_BY_FRAME:
		_fail("seeded frame-to-alias mapping differs from Robert's confirmed mapping")
		return
	print("%s: passed %d accepted catalog entries and %d exact semantic aliases" % [TEST_ORIGIN, EXPECTED_CATALOG_COUNT, EXPECTED_ALIAS_COUNT])
	quit(0)


func _fail(message: String) -> void:
	push_error("%s: %s" % [TEST_ORIGIN, message])
	quit(1)
