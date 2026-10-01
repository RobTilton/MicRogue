extends SceneTree

const TEST_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_removal_request_flag.gd"
const SNAPSHOT_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_006.json"
const EXPECTED_SHA256 := "480aec14d3a2d597118a17506bc501c49df9d193083e6873fb3ea5340f64dcec"
const EXPECTED_COUNT := 499


func _initialize() -> void:
	if FileAccess.get_sha256(SNAPSHOT_PATH) != EXPECTED_SHA256:
		_fail("human working snapshot 006 hash differs")
		return
	var payload = JSON.parse_string(FileAccess.get_file_as_string(SNAPSHOT_PATH))
	if not payload is Dictionary or not payload.get("aliases") is Array or payload.aliases.size() != EXPECTED_COUNT:
		_fail("snapshot 006 could not be parsed or count differs")
		return
	var seen_addresses: Dictionary = {}
	var seen_aliases: Dictionary = {}
	var normalized: Array[Dictionary] = []
	for raw_record in payload.aliases:
		var record: Dictionary = raw_record
		var address := str(record.get("address", ""))
		var alias := str(record.get("alias", ""))
		if address.is_empty() or alias.is_empty() or seen_addresses.has(address) or seen_aliases.has(alias):
			_fail("snapshot 006 has empty or duplicate identity")
			return
		if record.has("remove_requested") and typeof(record.remove_requested) != TYPE_BOOL:
			_fail("existing remove_requested value is not Boolean: %s" % address)
			return
		if bool(record.get("remove_requested", false)):
			_fail("snapshot 006 unexpectedly requests removal: %s" % address)
			return
		seen_addresses[address] = true
		seen_aliases[alias] = true
		var normalized_record: Dictionary = record.duplicate(true)
		normalized_record.remove_requested = bool(normalized_record.get("remove_requested", false))
		normalized.append(normalized_record)
	var round_trip = JSON.parse_string(JSON.stringify(normalized))
	if not round_trip is Array or round_trip.size() != EXPECTED_COUNT:
		_fail("normalized records failed JSON round trip")
		return
	for record: Dictionary in round_trip:
		if typeof(record.get("remove_requested")) != TYPE_BOOL or bool(record.remove_requested):
			_fail("Boolean false default did not round-trip")
			return
	print("%s: passed 499-record backward compatibility and Boolean false normalization" % TEST_ORIGIN)
	quit(0)


func _fail(message: String) -> void:
	push_error("%s: %s" % [TEST_ORIGIN, message])
	quit(1)
