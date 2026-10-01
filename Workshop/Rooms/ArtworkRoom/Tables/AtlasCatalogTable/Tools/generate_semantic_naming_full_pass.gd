extends SceneTree

const TOOL_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Tools/generate_semantic_naming_full_pass.gd"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json"
const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const SOURCE_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_004.json"
const EXPECTED_SOURCE_SHA256 := "2dfe06388be1ce6ea84eca8ed88254bac4e4fadd84390ef97bdd7e95b7004262"
const OUTPUT_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_005.json"
const EXPECTED_CATALOG_COUNT := 499


func _initialize() -> void:
	if FileAccess.file_exists(OUTPUT_PATH):
		_fail("refused to overwrite existing output: %s" % OUTPUT_PATH)
		return
	if FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256 or FileAccess.get_sha256(SOURCE_PATH) != EXPECTED_SOURCE_SHA256:
		_fail("catalog or source semantic hash differs")
		return
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var source = JSON.parse_string(FileAccess.get_file_as_string(SOURCE_PATH))
	if not catalog is Dictionary or not catalog.get("entries") is Array or catalog.entries.size() != EXPECTED_CATALOG_COUNT:
		_fail("catalog could not be parsed or count differs")
		return
	if not source is Dictionary or not source.get("aliases") is Array:
		_fail("source semantic snapshot could not be parsed")
		return
	if int(source.get("save_sequence", -1)) != 4 or int(source.get("alias_count", -1)) != 29 or int(source.get("record_count", -1)) != 30:
		_fail("source semantic counters differ")
		return

	var source_by_address: Dictionary = {}
	var seen_aliases: Dictionary = {}
	var counters: Dictionary = {}
	for raw_record in source.aliases:
		var record: Dictionary = raw_record.duplicate(true)
		var address := str(record.get("address", ""))
		var alias := str(record.get("alias", ""))
		if source_by_address.has(address):
			_fail("source duplicates address: %s" % address)
			return
		source_by_address[address] = record
		if not alias.is_empty():
			if seen_aliases.has(alias):
				_fail("source duplicates alias: %s" % alias)
				return
			seen_aliases[alias] = address
			_seed_counter(alias, counters)

	var records: Array[Dictionary] = []
	var generated_count := 0
	var updated_note_only_count := 0
	for catalog_entry: Dictionary in catalog.entries:
		var address := str(catalog_entry.id)
		if source_by_address.has(address) and not str(source_by_address[address].get("alias", "")).is_empty():
			records.append(source_by_address[address].duplicate(true))
			continue
		var classification := _classify(int(catalog_entry.x), int(catalog_entry.y))
		var alias := _allocate_alias(classification, counters, seen_aliases)
		var note := "Full Pass draft | %s" % classification.review
		if source_by_address.has(address):
			var existing: Dictionary = source_by_address[address]
			note = str(existing.get("note", ""))
			updated_note_only_count += 1
		var tags: Array = classification.tags.duplicate()
		for required_tag in ["full_pass", classification.review]:
			if not tags.has(required_tag):
				tags.append(required_tag)
		tags.sort()
		records.append({
			"address": address,
			"alias": alias,
			"category": classification.category,
			"family": classification.family,
			"note": note,
			"tags": tags,
		})
		seen_aliases[alias] = address
		generated_count += 1
	if records.size() != EXPECTED_CATALOG_COUNT or seen_aliases.size() != EXPECTED_CATALOG_COUNT:
		_fail("full pass did not produce exactly %d records and aliases" % EXPECTED_CATALOG_COUNT)
		return
	if generated_count != 470 or updated_note_only_count != 1:
		_fail("generated or note-only update count differs")
		return

	var payload: Dictionary = source.duplicate(true)
	payload.aliases = records
	payload.alias_count = EXPECTED_CATALOG_COUNT
	payload.record_count = EXPECTED_CATALOG_COUNT
	payload.save_sequence = 5
	var encoded := JSON.stringify(payload, "\t") + "\n"
	var output := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if output == null:
		_fail("could not open output")
		return
	output.store_string(encoded)
	output.flush()
	output.close()
	var round_trip = JSON.parse_string(FileAccess.get_file_as_string(OUTPUT_PATH))
	if not round_trip is Dictionary or int(round_trip.get("alias_count", -1)) != EXPECTED_CATALOG_COUNT or int(round_trip.get("record_count", -1)) != EXPECTED_CATALOG_COUNT or int(round_trip.get("save_sequence", -1)) != 5:
		_fail("full-pass output failed round-trip validation")
		return
	print("%s: preserved 29 aliases, named 470 remaining cells, and wrote 499-record draft to %s" % [TOOL_ORIGIN, OUTPUT_PATH])
	quit(0)


func _seed_counter(alias: String, counters: Dictionary) -> void:
	var regex := RegEx.new()
	regex.compile("^(.+)_([0-9]{3})$")
	var match := regex.search(alias)
	if match == null:
		return
	var prefix := match.get_string(1)
	var next_value := int(match.get_string(2)) + 1
	counters[prefix] = maxi(int(counters.get(prefix, 0)), next_value)


func _allocate_alias(classification: Dictionary, counters: Dictionary, seen: Dictionary) -> String:
	var prefix := str(classification.prefix)
	var number := int(counters.get(prefix, 0))
	var alias := ""
	while true:
		alias = "actor_%03d_unnamed" % number if prefix == "actor" else "%s_%03d" % [prefix, number]
		if not seen.has(alias):
			break
		number += 1
	counters[prefix] = number + 1
	return alias


func _classify(x: int, y: int) -> Dictionary:
	# Effects and consumables take priority over the broader terrain/equipment regions.
	if (y == 5 and _between(x, 21, 23)) or (_between(y, 8, 9) and _between(x, 18, 23)) or (y == 10 and _between(x, 37, 38)):
		return _group("effect_hit", "effect", "effect_hit", ["effect", "hit"], "draft")
	if _between(x, 43, 47) and _between(y, 11, 13):
		return _group("effect_magic", "effect", "effect_magic", ["effect", "magic"], "review_required")
	if _between(x, 14, 15) and y == 18:
		return _group("effect_water", "effect", "effect_water", ["effect", "water"], "review_required")
	if _between(x, 32, 34) and _between(y, 12, 14):
		return _group("item_consumable", "item", "item_consumable", ["consumable", "item"], "draft")
	if _between(x, 32, 34) and _between(y, 15, 16):
		return _group("deco_book_container", "deco", "deco_book_container", ["book", "container", "deco"], "review_required")

	# Weapons, guard effects, actors, and armor.
	if (x == 23 and y == 2) or (_between(x, 0, 5) and y == 15) or (_between(x, 25, 34) and y == 11) or (_between(x, 33, 34) and y == 20) or (x == 34 and y == 21):
		return _group("weapon_unknown", "weapon", "weapon_unknown", ["equipment", "weapon"], "review_required")
	if _between(x, 32, 36) and _between(y, 2, 10):
		return _group("weapon_blade", "weapon", "weapon_blade", ["blade", "equipment", "weapon"], "draft")
	if _between(x, 42, 46) and _between(y, 7, 9):
		return _group("effect_guard", "effect", "effect_guard", ["effect", "guard", "shield"], "review_required")
	if _between(x, 37, 41) and _between(y, 0, 9):
		return _group("equipment_piece", "equipment", "equipment_piece", ["equipment"], "review_required")
	if _between(x, 24, 31) and _between(y, 0, 10):
		return _group("actor", "actor", "actor_unnamed", ["actor", "fantasy"], "review_required")
	if _between(x, 32, 36) and _between(y, 0, 1):
		return _group("armor_headgear", "armor", "armor_headgear", ["armor", "equipment", "headgear"], "review_required")
	if _between(x, 42, 48) and _between(y, 0, 5):
		return _group("armor_piece", "armor", "armor_piece", ["armor", "equipment"], "review_required")

	# Containers and furnishings precede broad terrain ranges.
	if _between(x, 46, 48) and _between(y, 5, 9):
		return _group("deco_container", "deco", "deco_container", ["container", "deco"], "review_required")
	if _between(x, 0, 7) and _between(y, 3, 10):
		return _group("deco_structure", "deco", "deco_structure", ["deco", "structure"], "draft")
	if _between(x, 8, 17) and _between(y, 7, 10):
		return _group("deco_furniture", "deco", "deco_furniture", ["deco", "furniture"], "draft")
	if _between(x, 18, 23) and _between(y, 11, 13):
		return _group("deco_container", "deco", "deco_container", ["container", "deco"], "draft")

	# Nature and overworld detail.
	if _between(x, 1, 7) and y == 0:
		return _group("overworld_detail", "terrain", "overworld_detail", ["overworld", "terrain"], "review_required")
	if _between(x, 0, 7) and _between(y, 1, 2):
		return _group("forest_vegetation", "terrain", "forest_vegetation", ["forest", "overworld", "vegetation"], "draft")
	if _between(x, 13, 17) and y == 6:
		return _group("forest_detail", "terrain", "forest_detail", ["forest", "overworld", "vegetation"], "draft")
	if _between(x, 18, 20) and y == 5:
		return _group("forest_creature_detail", "deco", "forest_creature_detail", ["forest", "overworld"], "review_required")

	# Dungeon and overworld structural libraries.
	if (_between(x, 8, 22) and _between(y, 0, 4)) or (_between(x, 8, 17) and _between(y, 5, 6)):
		return _group("dungeon_tile", "terrain", "dungeon_tile", ["dungeon", "terrain"], "review_required")
	if _between(x, 0, 24) and _between(y, 11, 18):
		return _group("dungeon_tile", "terrain", "dungeon_tile", ["dungeon", "terrain"], "review_required")
	if _between(x, 0, 18) and _between(y, 19, 21):
		return _group("overworld_structure", "structure", "overworld_structure", ["overworld", "structure"], "review_required")

	return _group("deco_object", "deco", "deco_object", ["deco"], "review_required")


func _group(prefix: String, category: String, family: String, tags: Array, review: String) -> Dictionary:
	return {"prefix": prefix, "category": category, "family": family, "tags": tags, "review": review}


func _between(value: int, minimum: int, maximum: int) -> bool:
	return value >= minimum and value <= maximum


func _fail(message: String) -> void:
	push_error("%s: %s" % [TOOL_ORIGIN, message])
	quit(1)
