extends SceneTree

const TEST_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_semantic_aliases_024.gd"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/History/fantasy_sprite_catalog_499_snapshot024.json"
const SNAPSHOT_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_024.json"
const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const EXPECTED_SNAPSHOT_SHA256 := "cc3d0dd62f49ff0524c3b55b305957e01336c13aec07f11c841ddc7aa5ec2c95"
const EXPECTED_COUNT := 499
const EXPECTED_REMOVE_COUNT := 13


func _initialize() -> void:
	if FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256 or FileAccess.get_sha256(SNAPSHOT_PATH) != EXPECTED_SNAPSHOT_SHA256:
		_fail("catalog or snapshot 024 hash differs")
		return
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var snapshot = JSON.parse_string(FileAccess.get_file_as_string(SNAPSHOT_PATH))
	if not catalog is Dictionary or not snapshot is Dictionary:
		_fail("catalog or snapshot could not be parsed")
		return
	if int(snapshot.get("save_sequence", -1)) != 24 or int(snapshot.get("alias_count", -1)) != EXPECTED_COUNT or int(snapshot.get("record_count", -1)) != EXPECTED_COUNT:
		_fail("snapshot counters differ")
		return
	if not snapshot.get("aliases") is Array or snapshot.aliases.size() != EXPECTED_COUNT or catalog.entries.size() != EXPECTED_COUNT:
		_fail("snapshot or catalog entry count differs")
		return
	var alias_pattern := RegEx.new()
	alias_pattern.compile("^[a-z0-9]+(?:_[a-z0-9]+)*$")
	var seen_addresses: Dictionary = {}
	var seen_aliases: Dictionary = {}
	var remove_count := 0
	for index in range(EXPECTED_COUNT):
		var accepted: Dictionary = catalog.entries[index]
		var record: Dictionary = snapshot.aliases[index]
		var address := str(record.get("address", ""))
		var alias := str(record.get("alias", ""))
		if address != str(accepted.id):
			_fail("catalog order/address differs at index %d" % index)
			return
		if seen_addresses.has(address) or seen_aliases.has(alias):
			_fail("duplicate address or alias at index %d" % index)
			return
		if alias_pattern.search(alias) == null:
			_fail("alias is not lowercase snake_case at index %d: %s" % [index, alias])
			return
		if str(record.get("category", "")).is_empty() or str(record.get("family", "")).is_empty() or not record.get("tags") is Array:
			_fail("semantic metadata is incomplete: %s" % address)
			return
		if not record.has("remove_requested") or typeof(record.remove_requested) != TYPE_BOOL:
			_fail("remove_requested is missing or non-Boolean: %s" % address)
			return
		if bool(record.remove_requested):
			remove_count += 1
		seen_addresses[address] = true
		seen_aliases[alias] = true
	if remove_count != EXPECTED_REMOVE_COUNT:
		_fail("remove-request count is %d; expected %d" % [remove_count, EXPECTED_REMOVE_COUNT])
		return
	for sequence in range(1, 25):
		var path := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_%03d.json" % sequence
		if not FileAccess.file_exists(path):
			_fail("append-only history is missing sequence %03d" % sequence)
			return
	print("%s: passed 499 catalog-ordered unique aliases, 13 Boolean removal requests, and complete snapshots 001-024" % TEST_ORIGIN)
	quit(0)


func _fail(message: String) -> void:
	push_error("%s: %s" % [TEST_ORIGIN, message])
	quit(1)
