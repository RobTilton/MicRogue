extends SceneTree

const TEST_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_semantic_naming_full_pass.gd"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/History/fantasy_sprite_catalog_499_snapshot024.json"
const SOURCE_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_004.json"
const DRAFT_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_005.json"
const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const EXPECTED_SOURCE_SHA256 := "2dfe06388be1ce6ea84eca8ed88254bac4e4fadd84390ef97bdd7e95b7004262"
const EXPECTED_DRAFT_SHA256 := "407ab8ec2f71744bc3a8ccb10fd890c4e1eebd7c607cb1d396672ec09b34c670"
const EXPECTED_COUNT := 499


func _initialize() -> void:
	if FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256 or FileAccess.get_sha256(SOURCE_PATH) != EXPECTED_SOURCE_SHA256 or FileAccess.get_sha256(DRAFT_PATH) != EXPECTED_DRAFT_SHA256:
		_fail("catalog, source, or full draft hash differs")
		return
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var source = JSON.parse_string(FileAccess.get_file_as_string(SOURCE_PATH))
	var draft = JSON.parse_string(FileAccess.get_file_as_string(DRAFT_PATH))
	if not catalog is Dictionary or not source is Dictionary or not draft is Dictionary:
		_fail("an input could not be parsed")
		return
	if int(draft.get("save_sequence", -1)) != 5 or int(draft.get("alias_count", -1)) != EXPECTED_COUNT or int(draft.get("record_count", -1)) != EXPECTED_COUNT:
		_fail("full draft counters differ")
		return
	if draft.aliases.size() != EXPECTED_COUNT or catalog.entries.size() != EXPECTED_COUNT:
		_fail("full draft or catalog array count differs")
		return

	var source_by_address: Dictionary = {}
	for record: Dictionary in source.aliases:
		source_by_address[record.address] = record
	var alias_pattern := RegEx.new()
	alias_pattern.compile("^[a-z0-9]+(?:_[a-z0-9]+)*$")
	var seen_addresses: Dictionary = {}
	var seen_aliases: Dictionary = {}
	var full_pass_count := 0
	var draft_count := 0
	var review_count := 0
	var preserved_alias_count := 0
	var enriched_note_only_count := 0
	for index in range(EXPECTED_COUNT):
		var catalog_entry: Dictionary = catalog.entries[index]
		var record: Dictionary = draft.aliases[index]
		var address := str(record.get("address", ""))
		var alias := str(record.get("alias", ""))
		if address != str(catalog_entry.id):
			_fail("record/catalog ordering or address differs at index %d" % index)
			return
		if seen_addresses.has(address) or seen_aliases.has(alias):
			_fail("duplicate address or alias at index %d" % index)
			return
		if alias_pattern.search(alias) == null:
			_fail("alias syntax differs at index %d: %s" % [index, alias])
			return
		if str(record.get("category", "")).is_empty() or str(record.get("family", "")).is_empty() or not record.get("tags") is Array:
			_fail("semantic metadata is incomplete at index %d" % index)
			return
		seen_addresses[address] = true
		seen_aliases[alias] = true
		var tags: Array = record.tags
		if tags.has("full_pass"):
			full_pass_count += 1
			var has_draft := tags.has("draft")
			var has_review := tags.has("review_required")
			if has_draft == has_review:
				_fail("full-pass status must be exactly one of draft/review_required: %s" % address)
				return
			if has_draft:
				draft_count += 1
			else:
				review_count += 1
		if source_by_address.has(address):
			var source_record: Dictionary = source_by_address[address]
			if not str(source_record.alias).is_empty():
				if record != source_record:
					_fail("existing named record changed: %s" % address)
					return
				preserved_alias_count += 1
			else:
				if record.note != source_record.note or alias.is_empty():
					_fail("note-only record was not enriched losslessly: %s" % address)
					return
				enriched_note_only_count += 1
	if seen_addresses.size() != EXPECTED_COUNT or seen_aliases.size() != EXPECTED_COUNT:
		_fail("unique coverage count differs")
		return
	if full_pass_count != 470 or draft_count != 157 or review_count != 313:
		_fail("full-pass status counts differ")
		return
	if preserved_alias_count != 29 or enriched_note_only_count != 1:
		_fail("source preservation counts differ")
		return
	print("%s: passed 499 unique aliases; 29 preserved, 470 generated, 157 draft, 313 review_required" % TEST_ORIGIN)
	quit(0)


func _fail(message: String) -> void:
	push_error("%s: %s" % [TEST_ORIGIN, message])
	quit(1)
