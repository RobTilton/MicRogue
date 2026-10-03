extends SceneTree

const ORIGIN := "Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/validate_sprite_atlas_curation.gd"
const CONFIG_PATH := "res://Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/fantasy_sprite_catalog_validation_config.tres"
const SELECTION_PATH := "res://Production/Assets/FantasySpriteCatalog/Validation/atlas_selection_005.json"
const SELECTION_SCENE := "res://Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/AtlasSelectionTool.tscn"
const NAMING_SCENE := "res://Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/SemanticNamingTool.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config := load(CONFIG_PATH) as SpriteAtlasCurationConfig
	if config == null or not config.validate_for_naming().is_empty():
		_fail("validation configuration did not pass")
		return
	var invalid := config.duplicate() as SpriteAtlasCurationConfig
	invalid.expected_atlas_sha256 = "intentionally_invalid"
	if invalid.validate_for_selection().is_empty():
		_fail("invalid atlas hash was accepted")
		return
	var selection = JSON.parse_string(FileAccess.get_file_as_string(SELECTION_PATH))
	var generated := SpriteAtlasCatalogBuilder.build_payload(config, selection)
	if not bool(generated.get("valid", false)) or int(generated.get("entry_count", -1)) != 486:
		_fail("selection-to-catalog validation failed: %s" % generated.get("error", "wrong count"))
		return
	for field: String in ["schema_version", "columns", "rows", "selected_count"]:
		var malformed: Dictionary = selection.duplicate(true)
		malformed[field] = 999
		if bool(SpriteAtlasCatalogBuilder.build_payload(config, malformed).get("valid", false)):
			_fail("invalid selection header was accepted: %s" % field)
			return
	for field: String in ["cell_size", "atlas_size"]:
		var malformed: Dictionary = selection.duplicate(true)
		malformed[field] = [1, 1]
		if bool(SpriteAtlasCatalogBuilder.build_payload(config, malformed).get("valid", false)):
			_fail("invalid selection geometry was accepted: %s" % field)
			return
	if SpriteAtlasCatalogBuilder.write_target_error(config.catalog_path).is_empty():
		_fail("existing final target was accepted")
		return
	var current = JSON.parse_string(FileAccess.get_file_as_string(config.catalog_path))
	if not current is Dictionary or not current.get("entries") is Array or current.entries.size() != generated.entries.size():
		_fail("current catalog cannot be compared")
		return
	for index in range(generated.entries.size()):
		var expected: Dictionary = current.entries[index]
		var actual: Dictionary = generated.entries[index]
		for key in ["id", "category"]:
			if str(actual.get(key)) != str(expected.get(key)):
				_fail("generated catalog differs at index %d key %s" % [index, key])
				return
		for key in ["x", "y", "frame"]:
			if int(actual.get(key, -1)) != int(expected.get(key, -1)):
				_fail("generated catalog differs at index %d key %s" % [index, key])
				return
		if not _array_matches_ints(actual.region, expected.region):
			_fail("generated region differs at index %d" % index)
			return
	var selection_tool := (load(SELECTION_SCENE) as PackedScene).instantiate() as ReusableAtlasSelectionTool
	selection_tool.config = config
	root.add_child(selection_tool)
	await process_frame
	if not selection_tool.valid or selection_tool.selected.size() != 486 or selection_tool.loaded_name != "atlas_selection_005.json":
		_fail("selection scene did not load the current 486-cell snapshot")
		return
	var unsupported: Dictionary = selection.duplicate(true)
	unsupported["schema_version"] = 999
	if bool(selection_tool.call("_validate_payload", unsupported).get("valid", false)):
		_fail("selection UI accepted unsupported schema")
		return
	selection_tool.queue_free()
	await process_frame
	var naming_tool := (load(NAMING_SCENE) as PackedScene).instantiate() as ReusableSemanticNamingTool
	naming_tool.config = config
	root.add_child(naming_tool)
	await process_frame
	if not naming_tool.valid or naming_tool.entries.size() != 486 or naming_tool.records.size() != 486 or naming_tool.loaded != "semantic_aliases_001.json":
		_fail("naming scene did not load current catalog and semantic snapshot")
		return
	naming_tool.queue_free()
	await process_frame
	print("%s: passed atlas authority, invalid-hash/header/schema refusal, existing-target refusal, exact 486-entry derivation, selection/semantic preload and UI teardown" % ORIGIN)
	quit(0)


func _array_matches_ints(left: Variant, right: Variant) -> bool:
	if not left is Array or not right is Array or left.size() != right.size(): return false
	for index in range(left.size()):
		if int(left[index]) != int(right[index]): return false
	return true


func _fail(message: String) -> void:
	push_error("%s: %s" % [ORIGIN, message])
	quit(1)
