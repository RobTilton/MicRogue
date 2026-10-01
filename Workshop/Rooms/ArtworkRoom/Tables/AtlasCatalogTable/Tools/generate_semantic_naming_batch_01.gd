extends SceneTree

const TOOL_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Tools/generate_semantic_naming_batch_01.gd"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json"
const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const SOURCE_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_003.json"
const EXPECTED_SOURCE_SHA256 := "5c5fc50ae99b44ccb5315ba915ac22deab7ca7ea3e883cbc5a6a1ffd63dcef51"
const OUTPUT_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_004.json"

const ADDITIONS: Array[Dictionary] = [
	{"address": "atlas_x37_y02", "alias": "shield_round_brown_000", "category": "shield", "family": "shield_round_brown", "tags": ["brown", "equipment", "shield"], "note": "Batch 01 conservative visual draft."},
	{"address": "atlas_x38_y02", "alias": "shield_round_gray_000", "category": "shield", "family": "shield_round_gray", "tags": ["equipment", "gray", "shield"], "note": "Batch 01 conservative visual draft."},
	{"address": "atlas_x39_y02", "alias": "shield_round_brown_001", "category": "shield", "family": "shield_round_brown", "tags": ["brown", "equipment", "shield"], "note": "Batch 01 conservative visual draft."},
	{"address": "atlas_x40_y02", "alias": "shield_round_gray_001", "category": "shield", "family": "shield_round_gray", "tags": ["equipment", "gray", "shield"], "note": "Batch 01 conservative visual draft."},
	{"address": "atlas_x43_y02", "alias": "armor_crown_000", "category": "armor", "family": "armor_crown", "tags": ["armor", "crown", "equipment"], "note": "Batch 01 conservative visual draft."},
	{"address": "atlas_x44_y02", "alias": "armor_crown_001", "category": "armor", "family": "armor_crown", "tags": ["armor", "crown", "equipment"], "note": "Batch 01 conservative visual draft."},
	{"address": "atlas_x37_y03", "alias": "shield_tall_brown_000", "category": "shield", "family": "shield_tall_brown", "tags": ["brown", "equipment", "shield"], "note": "Batch 01 conservative visual draft."},
	{"address": "atlas_x38_y03", "alias": "shield_tall_gray_000", "category": "shield", "family": "shield_tall_gray", "tags": ["equipment", "gray", "shield"], "note": "Batch 01 conservative visual draft."},
	{"address": "atlas_x39_y03", "alias": "shield_tall_gray_001", "category": "shield", "family": "shield_tall_gray", "tags": ["equipment", "gray", "shield"], "note": "Batch 01 conservative visual draft."},
	{"address": "atlas_x40_y03", "alias": "shield_tall_brown_001", "category": "shield", "family": "shield_tall_brown", "tags": ["brown", "equipment", "shield"], "note": "Batch 01 conservative visual draft."},
]


func _initialize() -> void:
	if FileAccess.file_exists(OUTPUT_PATH):
		_fail("refused to overwrite existing output: %s" % OUTPUT_PATH)
		return
	if FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256:
		_fail("accepted catalog hash differs")
		return
	if FileAccess.get_sha256(SOURCE_PATH) != EXPECTED_SOURCE_SHA256:
		_fail("source semantic snapshot hash differs")
		return
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var source = JSON.parse_string(FileAccess.get_file_as_string(SOURCE_PATH))
	if not catalog is Dictionary or not catalog.get("entries") is Array:
		_fail("catalog could not be parsed")
		return
	if not source is Dictionary or not source.get("aliases") is Array:
		_fail("source semantic snapshot could not be parsed")
		return
	if int(source.get("save_sequence", -1)) != 3 or int(source.get("alias_count", -1)) != 19 or int(source.get("record_count", -1)) != 20:
		_fail("source semantic snapshot counters differ")
		return
	var valid_addresses: Dictionary = {}
	for entry: Dictionary in catalog.entries:
		valid_addresses[entry.id] = true
	var records: Array[Dictionary] = []
	var seen_addresses: Dictionary = {}
	var seen_aliases: Dictionary = {}
	for raw_record in source.aliases:
		var record: Dictionary = raw_record.duplicate(true)
		var address := str(record.get("address", ""))
		var alias := str(record.get("alias", ""))
		if not valid_addresses.has(address) or seen_addresses.has(address):
			_fail("source contains an unknown or duplicate address: %s" % address)
			return
		if not alias.is_empty():
			if seen_aliases.has(alias):
				_fail("source contains duplicate alias: %s" % alias)
				return
			seen_aliases[alias] = true
		seen_addresses[address] = true
		records.append(record)
	for addition: Dictionary in ADDITIONS:
		var address := str(addition.address)
		var alias := str(addition.alias)
		if not valid_addresses.has(address) or seen_addresses.has(address) or seen_aliases.has(alias):
			_fail("addition conflicts with catalog or source: %s / %s" % [address, alias])
			return
		seen_addresses[address] = true
		seen_aliases[alias] = true
		records.append(addition.duplicate(true))
	var order_by_address: Dictionary = {}
	for index in range(catalog.entries.size()):
		order_by_address[catalog.entries[index].id] = index
	records.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(order_by_address[left.address]) < int(order_by_address[right.address])
	)
	var payload: Dictionary = source.duplicate(true)
	payload.aliases = records
	payload.alias_count = 29
	payload.record_count = 30
	payload.save_sequence = 4
	var encoded := JSON.stringify(payload, "\t") + "\n"
	var output := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if output == null:
		_fail("could not open output")
		return
	output.store_string(encoded)
	output.flush()
	output.close()
	var round_trip = JSON.parse_string(FileAccess.get_file_as_string(OUTPUT_PATH))
	if not round_trip is Dictionary or int(round_trip.get("alias_count", -1)) != 29 or int(round_trip.get("record_count", -1)) != 30 or int(round_trip.get("save_sequence", -1)) != 4:
		_fail("output failed round-trip counters")
		return
	print("%s: wrote 10 draft aliases; snapshot now has 29 aliases and 30 records at %s" % [TOOL_ORIGIN, OUTPUT_PATH])
	quit(0)


func _fail(message: String) -> void:
	push_error("%s: %s" % [TOOL_ORIGIN, message])
	quit(1)
