class_name SpriteAtlasCatalogBuilder
extends RefCounted

const ERROR_ORIGIN := "Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/sprite_atlas_catalog_builder.gd"


static func build_payload(config: SpriteAtlasCurationConfig, selection_payload: Variant) -> Dictionary:
	var error := config.validate_for_selection()
	if not error.is_empty():
		return {"valid": false, "error": error}
	if not selection_payload is Dictionary or not selection_payload.get("selected_cells") is Array:
		return {"valid": false, "error": "selection root or selected_cells is invalid"}
	if selection_payload.get("atlas_path") != config.atlas_path or selection_payload.get("atlas_sha256") != config.expected_atlas_sha256:
		return {"valid": false, "error": "selection atlas authority differs from configuration"}
	var entries: Array[Dictionary] = []
	var seen: Dictionary = {}
	var previous := Vector2i(-1, -1)
	for raw_cell in selection_payload.selected_cells:
		if not raw_cell is Dictionary:
			return {"valid": false, "error": "selection contains a non-dictionary cell"}
		var coordinate := Vector2i(int(raw_cell.get("x", -1)), int(raw_cell.get("y", -1)))
		var address := config.address_for(coordinate)
		if coordinate.x < 0 or coordinate.x >= config.columns or coordinate.y < 0 or coordinate.y >= config.rows:
			return {"valid": false, "error": "selection contains an out-of-bounds cell"}
		if seen.has(address) or (not entries.is_empty() and (coordinate.y < previous.y or (coordinate.y == previous.y and coordinate.x <= previous.x))):
			return {"valid": false, "error": "selection is duplicated or not strictly y-then-x sorted"}
		if str(raw_cell.get("review_state", "keep")) != "keep":
			return {"valid": false, "error": "catalog generation requires every retained cell to be keep"}
		var frame := coordinate.y * config.columns + coordinate.x
		var region := [coordinate.x * config.cell_size.x, coordinate.y * config.cell_size.y, config.cell_size.x, config.cell_size.y]
		if int(raw_cell.get("frame", -1)) != frame or not _array_matches_ints(raw_cell.get("region"), region):
			return {"valid": false, "error": "selection geometry differs at %s" % address}
		entries.append({"id": address, "category": config.catalog_category, "x": coordinate.x, "y": coordinate.y, "frame": frame, "region": region})
		seen[address] = true
		previous = coordinate
	return {
		"valid": true,
		"schema_version": 1,
		"atlas_path": config.atlas_path,
		"atlas_sha256": config.expected_atlas_sha256,
		"cell_size": [config.cell_size.x, config.cell_size.y],
		"columns": config.columns,
		"rows": config.rows,
		"entry_count": entries.size(),
		"entries": entries,
	}


static func _array_matches_ints(value: Variant, expected: Array) -> bool:
	if not value is Array or value.size() != expected.size():
		return false
	for index in range(expected.size()):
		if int(value[index]) != int(expected[index]):
			return false
	return true


static func write_new(config: SpriteAtlasCurationConfig, selection_path: String, target_path: String) -> bool:
	if FileAccess.file_exists(target_path) or FileAccess.file_exists(target_path + ".tmp"):
		push_error("%s: refused overwrite: %s" % [ERROR_ORIGIN, target_path])
		return false
	var selection = JSON.parse_string(FileAccess.get_file_as_string(selection_path))
	var payload := build_payload(config, selection)
	if not bool(payload.get("valid", false)):
		push_error("%s: %s" % [ERROR_ORIGIN, payload.get("error", "validation failed")])
		return false
	payload.erase("valid")
	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target_path.get_base_dir()))
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		push_error("%s: could not create target directory" % ERROR_ORIGIN)
		return false
	var temporary := target_path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		push_error("%s: could not open temporary target" % ERROR_ORIGIN)
		return false
	file.store_string(JSON.stringify(payload, "\t") + "\n")
	file.close()
	var read_back = JSON.parse_string(FileAccess.get_file_as_string(temporary))
	if not read_back is Dictionary or int(read_back.get("entry_count", -1)) != payload.entries.size():
		push_error("%s: temporary output failed read-back validation and was retained" % ERROR_ORIGIN)
		return false
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(target_path))
	if rename_error != OK:
		push_error("%s: could not finalize validated target; temporary retained" % ERROR_ORIGIN)
		return false
	return true
