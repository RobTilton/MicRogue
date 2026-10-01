extends SceneTree

const TEST_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_semantic_naming_batch_01.gd"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json"
const SOURCE_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_003.json"
const DRAFT_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_004.json"
const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const EXPECTED_SOURCE_SHA256 := "5c5fc50ae99b44ccb5315ba915ac22deab7ca7ea3e883cbc5a6a1ffd63dcef51"
const EXPECTED_DRAFT_SHA256 := "2dfe06388be1ce6ea84eca8ed88254bac4e4fadd84390ef97bdd7e95b7004262"

const EXPECTED_ADDITIONS := {
	"atlas_x37_y02": "shield_round_brown_000",
	"atlas_x38_y02": "shield_round_gray_000",
	"atlas_x39_y02": "shield_round_brown_001",
	"atlas_x40_y02": "shield_round_gray_001",
	"atlas_x43_y02": "armor_crown_000",
	"atlas_x44_y02": "armor_crown_001",
	"atlas_x37_y03": "shield_tall_brown_000",
	"atlas_x38_y03": "shield_tall_gray_000",
	"atlas_x39_y03": "shield_tall_gray_001",
	"atlas_x40_y03": "shield_tall_brown_001",
}


func _initialize() -> void:
	if FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256 or FileAccess.get_sha256(SOURCE_PATH) != EXPECTED_SOURCE_SHA256 or FileAccess.get_sha256(DRAFT_PATH) != EXPECTED_DRAFT_SHA256:
		_fail("catalog, source, or draft hash differs")
		return
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var source = JSON.parse_string(FileAccess.get_file_as_string(SOURCE_PATH))
	var draft = JSON.parse_string(FileAccess.get_file_as_string(DRAFT_PATH))
	if not catalog is Dictionary or not source is Dictionary or not draft is Dictionary:
		_fail("an input could not be parsed")
		return
	if int(draft.get("save_sequence", -1)) != 4 or int(draft.get("alias_count", -1)) != 29 or int(draft.get("record_count", -1)) != 30:
		_fail("draft counters differ")
		return
	var valid_addresses: Dictionary = {}
	for entry: Dictionary in catalog.entries:
		valid_addresses[entry.id] = entry
	var source_by_address: Dictionary = {}
	for record: Dictionary in source.aliases:
		source_by_address[record.address] = record
	var draft_by_address: Dictionary = {}
	var seen_aliases: Dictionary = {}
	var actual_additions: Dictionary = {}
	for record: Dictionary in draft.aliases:
		var address := str(record.address)
		var alias := str(record.alias)
		if not valid_addresses.has(address) or draft_by_address.has(address):
			_fail("draft has unknown or duplicate address: %s" % address)
			return
		if not alias.is_empty():
			if seen_aliases.has(alias):
				_fail("draft has duplicate alias: %s" % alias)
				return
			seen_aliases[alias] = address
		draft_by_address[address] = record
		if source_by_address.has(address):
			if record != source_by_address[address]:
				_fail("source semantic record changed: %s" % address)
				return
		else:
			actual_additions[address] = alias
	if actual_additions != EXPECTED_ADDITIONS:
		_fail("draft additions differ from the exact bounded batch")
		return
	for address in EXPECTED_ADDITIONS:
		var catalog_entry: Dictionary = valid_addresses[address]
		if int(catalog_entry.x) < 37 or int(catalog_entry.x) > 48 or int(catalog_entry.y) < 2 or int(catalog_entry.y) > 3:
			_fail("draft addition escaped the reviewed rows: %s" % address)
			return
	print("%s: passed 20 preserved records and 10 exact region-bounded draft aliases" % TEST_ORIGIN)
	quit(0)


func _fail(message: String) -> void:
	push_error("%s: %s" % [TEST_ORIGIN, message])
	quit(1)
