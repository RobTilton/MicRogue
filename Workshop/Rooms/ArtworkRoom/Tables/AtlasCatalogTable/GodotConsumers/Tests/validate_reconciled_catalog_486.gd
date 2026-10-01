extends SceneTree

const TEST_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_reconciled_catalog_486.gd"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json"
const HISTORY_CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/History/fantasy_sprite_catalog_499_snapshot024.json"
const SELECTION_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Selections/atlas_selection_005.json"
const SEMANTIC_SOURCE_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_024.json"
const SEMANTIC_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_025.json"
const EXPECTED_CATALOG_SHA256 := "48e5a186b5ea1abdc666c4d4ec911ddd956aed668552259e735cb7ec3a809285"
const EXPECTED_HISTORY_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const EXPECTED_SELECTION_SHA256 := "de185289097da67cf22a9fb6b621a4786ad6da9ce3d4e2d1142268a446e6cb88"
const EXPECTED_SEMANTIC_SHA256 := "cdae69a748fbb90d5964b2e92662b8b6dfc427b302a7a6acf3e74b5df2174f56"
const EXPECTED_COUNT := 486
const REMOVED := [
	"atlas_x08_y00", "atlas_x09_y00", "atlas_x10_y00", "atlas_x11_y00", "atlas_x12_y00",
	"atlas_x08_y02", "atlas_x09_y02", "atlas_x10_y02", "atlas_x11_y02", "atlas_x12_y02",
	"atlas_x31_y06", "atlas_x12_y12", "atlas_x04_y14",
]


func _initialize() -> void:
	if FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256 or FileAccess.get_sha256(HISTORY_CATALOG_PATH) != EXPECTED_HISTORY_SHA256 or FileAccess.get_sha256(SELECTION_PATH) != EXPECTED_SELECTION_SHA256 or FileAccess.get_sha256(SEMANTIC_PATH) != EXPECTED_SEMANTIC_SHA256:
		_fail("a reconciled or historical artifact hash differs")
		return
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var selection = JSON.parse_string(FileAccess.get_file_as_string(SELECTION_PATH))
	var semantic_source = JSON.parse_string(FileAccess.get_file_as_string(SEMANTIC_SOURCE_PATH))
	var semantic = JSON.parse_string(FileAccess.get_file_as_string(SEMANTIC_PATH))
	if not catalog is Dictionary or not selection is Dictionary or not semantic_source is Dictionary or not semantic is Dictionary:
		_fail("an artifact could not be parsed")
		return
	if catalog.entries.size() != EXPECTED_COUNT or selection.selected_cells.size() != EXPECTED_COUNT or semantic.aliases.size() != EXPECTED_COUNT:
		_fail("a retained array count differs")
		return
	if int(catalog.entry_count) != EXPECTED_COUNT or int(selection.selected_count) != EXPECTED_COUNT or int(semantic.alias_count) != EXPECTED_COUNT or int(semantic.record_count) != EXPECTED_COUNT:
		_fail("a declared retained count differs")
		return
	if int(selection.save_sequence) != 5 or int(semantic.save_sequence) != 25 or catalog.source_snapshot != SELECTION_PATH or semantic.catalog_sha256 != EXPECTED_CATALOG_SHA256:
		_fail("sequence or source binding differs")
		return
	var source_by_address: Dictionary = {}
	for record: Dictionary in semantic_source.aliases:
		source_by_address[record.address] = record
	var seen: Dictionary = {}
	var aliases: Dictionary = {}
	for index in range(EXPECTED_COUNT):
		var catalog_entry: Dictionary = catalog.entries[index]
		var selected: Dictionary = selection.selected_cells[index]
		var record: Dictionary = semantic.aliases[index]
		var address := str(catalog_entry.id)
		if address != _address(int(selected.x), int(selected.y)) or address != str(record.address):
			_fail("retained artifacts differ at index %d" % index)
			return
		if int(catalog_entry.frame) != int(selected.frame) or catalog_entry.region != selected.region or selected.review_state != "keep":
			_fail("selection geometry/state differs at index %d" % index)
			return
		if seen.has(address) or aliases.has(record.alias):
			_fail("duplicate retained address or alias at index %d" % index)
			return
		if not source_by_address.has(address) or record.alias != source_by_address[address].alias:
			_fail("retained alias changed: %s" % address)
			return
		if bool(record.remove_requested) or str(record.category).is_empty() or str(record.family).is_empty():
			_fail("normalized metadata is incomplete: %s" % address)
			return
		for workflow_tag in ["full_pass", "draft", "review_required"]:
			if record.tags.has(workflow_tag):
				_fail("obsolete workflow tag remains: %s / %s" % [address, workflow_tag])
				return
		if str(record.note).begins_with("Full Pass draft |"):
			_fail("generated full-pass note remains: %s" % address)
			return
		seen[address] = true
		aliases[record.alias] = true
	for address in REMOVED:
		if seen.has(address):
			_fail("requested removal remains current: %s" % address)
			return
		if not source_by_address.has(address) or not bool(source_by_address[address].remove_requested):
			_fail("removed address lacks snapshot 024 authority: %s" % address)
			return
	print("%s: passed 486 aligned retained entries, 13 exact removals, alias preservation, and metadata cleanup" % TEST_ORIGIN)
	quit(0)


func _address(x: int, y: int) -> String:
	return "atlas_x%02d_y%02d" % [x, y]


func _fail(message: String) -> void:
	push_error("%s: %s" % [TEST_ORIGIN, message])
	quit(1)
