extends SceneTree

const TOOL_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Tools/generate_static_atlas_lookup.gd"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json"
const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const ATLAS_PATH := "res://Workshop/Rooms/ArtworkRoom/Assets/Possible_Artwork/colored-transparent_packed.png"
const EXPECTED_ATLAS_SHA256 := "801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74"
const OUTPUT_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/Generated/fantasy_sprite_regions.gd"
const CELL_SIZE := 16
const COLUMN_COUNT := 49
const ROW_COUNT := 22
const EXPECTED_ENTRY_COUNT := 499


func _initialize() -> void:
	var validation := _load_and_validate_catalog()
	if not validation.valid:
		_fail(validation.error)
		return
	var generated_text := _generate_source(validation.entries)
	if FileAccess.file_exists(OUTPUT_PATH):
		var existing_text := FileAccess.get_file_as_string(OUTPUT_PATH)
		if existing_text == generated_text:
			print("%s: deterministic output already current: %s" % [TOOL_ORIGIN, OUTPUT_PATH])
			quit(0)
			return
		_fail("refused to overwrite differing generated output; inspect existing file: %s" % OUTPUT_PATH)
		return
	var temporary_path := OUTPUT_PATH + ".tmp"
	if FileAccess.file_exists(temporary_path):
		_fail("refused because temporary output already exists: %s" % temporary_path)
		return
	var output := FileAccess.open(temporary_path, FileAccess.WRITE)
	if output == null:
		_fail("could not open temporary output: %s" % temporary_path)
		return
	output.store_string(generated_text)
	output.flush()
	output.close()
	if FileAccess.get_file_as_string(temporary_path) != generated_text:
		_fail("temporary output failed exact read-back and was retained: %s" % temporary_path)
		return
	var rename_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temporary_path),
		ProjectSettings.globalize_path(OUTPUT_PATH)
	)
	if rename_error != OK:
		_fail("temporary output could not be finalized (error %d) and was retained: %s" % [rename_error, temporary_path])
		return
	print("%s: generated %d entries at %s" % [TOOL_ORIGIN, validation.entries.size(), OUTPUT_PATH])
	quit(0)


func _load_and_validate_catalog() -> Dictionary:
	if not FileAccess.file_exists(CATALOG_PATH):
		return _invalid("catalog does not exist: %s" % CATALOG_PATH)
	if FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256:
		return _invalid("catalog hash does not match accepted input: %s" % CATALOG_PATH)
	if not FileAccess.file_exists(ATLAS_PATH):
		return _invalid("atlas does not exist: %s" % ATLAS_PATH)
	if FileAccess.get_sha256(ATLAS_PATH) != EXPECTED_ATLAS_SHA256:
		return _invalid("atlas hash does not match accepted input: %s" % ATLAS_PATH)
	var payload = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if not payload is Dictionary:
		return _invalid("catalog root is not a dictionary")
	if int(payload.get("schema_version", -1)) != 1:
		return _invalid("unsupported catalog schema")
	if payload.get("atlas_path") != ATLAS_PATH or payload.get("atlas_sha256") != EXPECTED_ATLAS_SHA256:
		return _invalid("catalog atlas contract does not match")
	if not _integer_array_matches(payload.get("atlas_size"), [COLUMN_COUNT * CELL_SIZE, ROW_COUNT * CELL_SIZE]):
		return _invalid("catalog atlas dimensions do not match")
	if not _integer_array_matches(payload.get("cell_size"), [CELL_SIZE, CELL_SIZE]):
		return _invalid("catalog cell dimensions do not match")
	if int(payload.get("columns", -1)) != COLUMN_COUNT or int(payload.get("rows", -1)) != ROW_COUNT:
		return _invalid("catalog grid does not match")
	var entries = payload.get("entries")
	if not entries is Array or entries.size() != EXPECTED_ENTRY_COUNT or int(payload.get("entry_count", -1)) != EXPECTED_ENTRY_COUNT:
		return _invalid("catalog must contain exactly %d entries" % EXPECTED_ENTRY_COUNT)
	var seen_ids: Dictionary = {}
	var seen_coordinates: Dictionary = {}
	var previous := Vector2i(-1, -1)
	for index in range(entries.size()):
		var entry = entries[index]
		if not entry is Dictionary:
			return _invalid("entry %d is not a dictionary" % index)
		var x := int(entry.get("x", -1))
		var y := int(entry.get("y", -1))
		var coordinate := Vector2i(x, y)
		var id := str(entry.get("id", ""))
		var expected_id := "atlas_x%02d_y%02d" % [x, y]
		if x < 0 or x >= COLUMN_COUNT or y < 0 or y >= ROW_COUNT:
			return _invalid("entry %d coordinate is out of bounds: %s" % [index, coordinate])
		if id != expected_id:
			return _invalid("entry %d id is %s; expected %s" % [index, id, expected_id])
		if entry.get("category") != "curated_fantasy":
			return _invalid("entry %d category is not curated_fantasy" % index)
		if seen_ids.has(id) or seen_coordinates.has(coordinate):
			return _invalid("entry %d duplicates id or coordinate" % index)
		if index > 0 and (y < previous.y or (y == previous.y and x <= previous.x)):
			return _invalid("entry %d is not strictly y-then-x sorted" % index)
		if int(entry.get("frame", -1)) != y * COLUMN_COUNT + x:
			return _invalid("entry %d frame does not match coordinate" % index)
		var expected_region := [x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE]
		if not _integer_array_matches(entry.get("region"), expected_region):
			return _invalid("entry %d region does not match coordinate" % index)
		seen_ids[id] = true
		seen_coordinates[coordinate] = true
		previous = coordinate
	return {"valid": true, "error": "", "entries": entries}


func _generate_source(entries: Array) -> String:
	var lines: PackedStringArray = [
		"# Generated by %s" % TOOL_ORIGIN,
		"# Source catalog SHA-256: %s" % EXPECTED_CATALOG_SHA256,
		"# Do not edit by hand.",
		"extends RefCounted",
		"",
		"const ENTRIES: Array[Dictionary] = [",
	]
	for entry: Dictionary in entries:
		lines.append(
			"\t{\"id\": &\"%s\", \"category\": &\"%s\", \"atlas_coords\": Vector2i(%d, %d), \"frame\": %d, \"region\": Rect2i(%d, %d, %d, %d)},"
			% [
				entry.id, entry.category, entry.x, entry.y, entry.frame,
				entry.region[0], entry.region[1], entry.region[2], entry.region[3],
			]
		)
	lines.append("]")
	lines.append("")
	return "\n".join(lines)


func _invalid(message: String) -> Dictionary:
	return {"valid": false, "error": message, "entries": []}


func _integer_array_matches(value, expected: Array) -> bool:
	if not value is Array or value.size() != expected.size():
		return false
	for index in range(expected.size()):
		if int(value[index]) != int(expected[index]):
			return false
	return true


func _fail(message: String) -> void:
	push_error("%s: %s" % [TOOL_ORIGIN, message])
	quit(1)
