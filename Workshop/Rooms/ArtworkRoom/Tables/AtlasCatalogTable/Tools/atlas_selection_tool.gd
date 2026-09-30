extends Control

const TOOL_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Tools/atlas_selection_tool.gd"
const SOURCE_PATH := "res://Workshop/Rooms/ArtworkRoom/Assets/Possible_Artwork/colored-transparent_packed.png"
const EXPECTED_SOURCE_SHA256 := "801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74"
const SELECTION_DIRECTORY := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Selections"
const CELL_SIZE := 16
const COLUMN_COUNT := 49
const ROW_COUNT := 22
const ATLAS_SIZE := Vector2i(COLUMN_COUNT * CELL_SIZE, ROW_COUNT * CELL_SIZE)
const ZOOM_LEVELS: Array[int] = [1, 2, 4, 8]
const INITIAL_ORIGIN := Vector2(24.0, 96.0)
const STATE_KEEP := "keep"
const STATE_UNCERTAIN := "uncertain"

@onready var help_label: Label = %HelpLabel
@onready var status_label: Label = %StatusLabel
@onready var hover_label: Label = %HoverLabel

var atlas_texture: Texture2D
var atlas_hash := ""
var atlas_origin := INITIAL_ORIGIN
var zoom_index := 1
var selected_cells: Dictionary = {}
var atlas_is_valid := false
var is_panning := false
var loaded_snapshot_filename := "none"


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process_unhandled_key_input(true)
	atlas_is_valid = _validate_atlas()
	if OS.get_cmdline_user_args().has("--self-test"):
		call_deferred("_run_self_test")
	elif atlas_is_valid:
		_load_latest_snapshot()
		_update_status("Ready")
	else:
		_update_status("Atlas validation failed; saving disabled")
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("171a20"))
	if atlas_texture == null:
		return
	var zoom := _zoom()
	var destination := Rect2(atlas_origin, Vector2(ATLAS_SIZE) * zoom)
	draw_texture_rect(atlas_texture, destination, false)
	if zoom >= 2:
		var grid_color := Color(0.65, 0.72, 0.8, 0.32)
		for x in range(COLUMN_COUNT + 1):
			var line_x := atlas_origin.x + x * CELL_SIZE * zoom
			draw_line(Vector2(line_x, atlas_origin.y), Vector2(line_x, destination.end.y), grid_color, 1.0)
		for y in range(ROW_COUNT + 1):
			var line_y := atlas_origin.y + y * CELL_SIZE * zoom
			draw_line(Vector2(atlas_origin.x, line_y), Vector2(destination.end.x, line_y), grid_color, 1.0)
	for coordinate: Vector2i in selected_cells:
		var selection_rect := Rect2(
			atlas_origin + Vector2(coordinate * CELL_SIZE) * zoom,
			Vector2(CELL_SIZE, CELL_SIZE) * zoom
		)
		var is_uncertain: bool = selected_cells[coordinate] == STATE_UNCERTAIN
		var fill_color := Color(1.0, 0.72, 0.05, 0.48) if is_uncertain else Color(0.05, 0.85, 1.0, 0.42)
		var border_color := Color(1.0, 0.9, 0.2, 1.0) if is_uncertain else Color(0.2, 0.95, 1.0, 1.0)
		draw_rect(selection_rect, fill_color, true)
		draw_rect(selection_rect.grow(-1.0), border_color, false, 2.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_toggle_cell_at(mouse_event.position)
			accept_event()
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
			_toggle_uncertain_at(mouse_event.position)
			accept_event()
		elif mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = mouse_event.pressed
			accept_event()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_change_zoom(1, mouse_event.position)
			accept_event()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_change_zoom(-1, mouse_event.position)
			accept_event()
	elif event is InputEventMouseMotion:
		var motion_event := event as InputEventMouseMotion
		if is_panning:
			atlas_origin += motion_event.relative
			queue_redraw()
		_update_hover(motion_event.position)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_SPACE:
			_save_selection_snapshot()
			get_viewport().set_input_as_handled()


func _validate_atlas() -> bool:
	if not FileAccess.file_exists(SOURCE_PATH):
		_report_error("source atlas does not exist: %s" % SOURCE_PATH)
		return false
	atlas_hash = FileAccess.get_sha256(SOURCE_PATH)
	if atlas_hash != EXPECTED_SOURCE_SHA256:
		_report_error("source hash is %s; expected %s" % [atlas_hash, EXPECTED_SOURCE_SHA256])
		return false
	atlas_texture = load(SOURCE_PATH) as Texture2D
	if atlas_texture == null:
		_report_error("could not load source atlas as Texture2D: %s" % SOURCE_PATH)
		return false
	if atlas_texture.get_size() != Vector2(ATLAS_SIZE):
		_report_error("source atlas is %s; expected %s" % [atlas_texture.get_size(), ATLAS_SIZE])
		return false
	return true


func _latest_snapshot_path() -> String:
	var highest_sequence := -1
	var highest_path := ""
	for filename in DirAccess.get_files_at(SELECTION_DIRECTORY):
		if not filename.begins_with("atlas_selection_") or not filename.ends_with(".json"):
			continue
		var sequence_text := filename.trim_prefix("atlas_selection_").trim_suffix(".json")
		if not sequence_text.is_valid_int():
			continue
		var sequence := sequence_text.to_int()
		if sequence > highest_sequence:
			highest_sequence = sequence
			highest_path = SELECTION_DIRECTORY.path_join(filename)
	return highest_path


func _load_latest_snapshot() -> void:
	var snapshot_path := _latest_snapshot_path()
	if snapshot_path.is_empty():
		loaded_snapshot_filename = "none"
		return
	var snapshot_text := FileAccess.get_file_as_string(snapshot_path)
	var payload = JSON.parse_string(snapshot_text)
	var validation := _validate_payload(payload)
	if not validation.valid:
		selected_cells.clear()
		atlas_is_valid = false
		loaded_snapshot_filename = "INVALID"
		_report_error("newest snapshot was rejected without fallback: %s: %s" % [snapshot_path, validation.error])
		return
	selected_cells = validation.cells.duplicate()
	loaded_snapshot_filename = snapshot_path.get_file()
	print("%s: loaded %d cells from %s" % [TOOL_ORIGIN, selected_cells.size(), snapshot_path])


func _toggle_cell_at(screen_position: Vector2) -> void:
	if not atlas_is_valid:
		return
	var coordinate := _coordinate_for_screen(screen_position)
	if not _coordinate_is_valid(coordinate):
		return
	if selected_cells.has(coordinate):
		selected_cells.erase(coordinate)
	else:
		selected_cells[coordinate] = STATE_KEEP
	_update_status("Selection changed")
	_update_hover(screen_position)
	queue_redraw()


func _toggle_uncertain_at(screen_position: Vector2) -> void:
	if not atlas_is_valid:
		return
	var coordinate := _coordinate_for_screen(screen_position)
	if not _coordinate_is_valid(coordinate):
		return
	if not selected_cells.has(coordinate) or selected_cells[coordinate] == STATE_KEEP:
		selected_cells[coordinate] = STATE_UNCERTAIN
	else:
		selected_cells[coordinate] = STATE_KEEP
	_update_status("Review state changed")
	_update_hover(screen_position)
	queue_redraw()


func _change_zoom(direction: int, pivot: Vector2) -> void:
	var previous_zoom := _zoom()
	var next_index: int = clampi(zoom_index + direction, 0, ZOOM_LEVELS.size() - 1)
	if next_index == zoom_index:
		return
	var atlas_position := (pivot - atlas_origin) / previous_zoom
	zoom_index = next_index
	atlas_origin = pivot - atlas_position * _zoom()
	_update_status("Zoom changed")
	_update_hover(pivot)
	queue_redraw()


func _coordinate_for_screen(screen_position: Vector2) -> Vector2i:
	var local_position := (screen_position - atlas_origin) / _zoom()
	return Vector2i(floori(local_position.x / CELL_SIZE), floori(local_position.y / CELL_SIZE))


func _coordinate_is_valid(coordinate: Vector2i) -> bool:
	return coordinate.x >= 0 and coordinate.x < COLUMN_COUNT and coordinate.y >= 0 and coordinate.y < ROW_COUNT


func _update_hover(screen_position: Vector2) -> void:
	var coordinate := _coordinate_for_screen(screen_position)
	if not _coordinate_is_valid(coordinate):
		hover_label.text = "Hover: outside atlas"
		return
	var frame := coordinate.y * COLUMN_COUNT + coordinate.x
	var state: String = selected_cells.get(coordinate, "not selected")
	hover_label.text = "Hover: (%d, %d)    frame %d    %s" % [coordinate.x, coordinate.y, frame, state]


func _update_status(prefix: String) -> void:
	var uncertain_count := 0
	for review_state: String in selected_cells.values():
		if review_state == STATE_UNCERTAIN:
			uncertain_count += 1
	var keep_count := selected_cells.size() - uncertain_count
	status_label.text = "%s    Total: %d    Keep: %d    Uncertain: %d    Zoom: %dx    Loaded: %s" % [
		prefix, selected_cells.size(), keep_count, uncertain_count, _zoom(), loaded_snapshot_filename,
	]


func _zoom() -> int:
	return ZOOM_LEVELS[zoom_index]


func _sorted_coordinates() -> Array[Vector2i]:
	var coordinates: Array[Vector2i] = []
	for coordinate: Vector2i in selected_cells:
		coordinates.append(coordinate)
	coordinates.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		if left.y == right.y:
			return left.x < right.x
		return left.y < right.y
	)
	return coordinates


func _build_payload(sequence: int) -> Dictionary:
	var serialized_cells: Array[Dictionary] = []
	for coordinate in _sorted_coordinates():
		serialized_cells.append({
			"x": coordinate.x,
			"y": coordinate.y,
			"frame": coordinate.y * COLUMN_COUNT + coordinate.x,
			"region": [coordinate.x * CELL_SIZE, coordinate.y * CELL_SIZE, CELL_SIZE, CELL_SIZE],
			"review_state": selected_cells[coordinate],
		})
	return {
		"schema_version": 2,
		"atlas_path": SOURCE_PATH,
		"atlas_sha256": atlas_hash,
		"atlas_size": [ATLAS_SIZE.x, ATLAS_SIZE.y],
		"cell_size": [CELL_SIZE, CELL_SIZE],
		"columns": COLUMN_COUNT,
		"rows": ROW_COUNT,
		"save_sequence": sequence,
		"selected_count": serialized_cells.size(),
		"selected_cells": serialized_cells,
	}


func _next_snapshot_target() -> Dictionary:
	var sequence := 1
	while sequence <= 9999:
		var path := SELECTION_DIRECTORY.path_join("atlas_selection_%03d.json" % sequence)
		if not FileAccess.file_exists(path) and not FileAccess.file_exists(path + ".tmp"):
			return {"sequence": sequence, "path": path}
		sequence += 1
	return {}


func _save_selection_snapshot() -> void:
	if not atlas_is_valid:
		_report_error("refused save because atlas validation has not passed")
		return
	if FileAccess.get_sha256(SOURCE_PATH) != EXPECTED_SOURCE_SHA256:
		_report_error("refused save because source atlas changed after startup")
		atlas_is_valid = false
		return
	for coordinate: Vector2i in selected_cells:
		if not _coordinate_is_valid(coordinate):
			_report_error("refused save because selection contains invalid coordinate %s" % coordinate)
			return
		if selected_cells[coordinate] != STATE_KEEP and selected_cells[coordinate] != STATE_UNCERTAIN:
			_report_error("refused save because %s has invalid review state: %s" % [coordinate, selected_cells[coordinate]])
			return
	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SELECTION_DIRECTORY))
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		_report_error("could not create selection directory (error %d): %s" % [directory_error, SELECTION_DIRECTORY])
		return
	var target := _next_snapshot_target()
	if target.is_empty():
		_report_error("could not allocate a unique snapshot name in %s" % SELECTION_DIRECTORY)
		return
	var payload := _build_payload(target.sequence)
	var serialized := JSON.stringify(payload, "\t", true)
	var parsed = JSON.parse_string(serialized)
	var parsed_validation := _validate_payload(parsed)
	if not parsed_validation.valid or parsed_validation.cells.size() != payload.selected_count:
		_report_error("refused save because in-memory JSON round-trip validation failed: %s" % parsed_validation.error)
		return
	var temporary_path: String = target.path + ".tmp"
	var output := FileAccess.open(temporary_path, FileAccess.WRITE)
	if output == null:
		_report_error("could not open temporary snapshot for writing: %s" % temporary_path)
		return
	output.store_string(serialized + "\n")
	output.flush()
	output.close()
	var written_text := FileAccess.get_file_as_string(temporary_path)
	var written_payload = JSON.parse_string(written_text)
	var written_validation := _validate_payload(written_payload)
	if not written_validation.valid or written_validation.cells.size() != payload.selected_count:
		_report_error("temporary snapshot failed read-back validation and was retained for inspection: %s: %s" % [temporary_path, written_validation.error])
		return
	var rename_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temporary_path),
		ProjectSettings.globalize_path(target.path)
	)
	if rename_error != OK:
		_report_error("validated temporary snapshot could not be finalized (error %d) and was retained: %s" % [rename_error, temporary_path])
		return
	_update_status("Saved %s" % target.path.get_file())
	print("%s: saved %d selected cells to %s" % [TOOL_ORIGIN, selected_cells.size(), target.path])


func _validate_payload(payload) -> Dictionary:
	if not payload is Dictionary:
		return {"valid": false, "error": "root is not a dictionary", "cells": {}}
	var schema_version := int(payload.get("schema_version", -1))
	if schema_version != 1 and schema_version != 2:
		return {"valid": false, "error": "unsupported schema version %d" % schema_version, "cells": {}}
	var atlas_size_value = payload.get("atlas_size")
	var cell_size_value = payload.get("cell_size")
	var selected_cells_value = payload.get("selected_cells")
	if not atlas_size_value is Array or atlas_size_value.size() != 2:
		return {"valid": false, "error": "atlas_size is invalid", "cells": {}}
	if not cell_size_value is Array or cell_size_value.size() != 2:
		return {"valid": false, "error": "cell_size is invalid", "cells": {}}
	if not selected_cells_value is Array:
		return {"valid": false, "error": "selected_cells is not an array", "cells": {}}
	if payload.get("atlas_path") != SOURCE_PATH:
		return {"valid": false, "error": "atlas_path does not match", "cells": {}}
	if payload.get("atlas_sha256") != EXPECTED_SOURCE_SHA256:
		return {"valid": false, "error": "atlas_sha256 does not match", "cells": {}}
	if int(atlas_size_value[0]) != ATLAS_SIZE.x or int(atlas_size_value[1]) != ATLAS_SIZE.y:
		return {"valid": false, "error": "atlas_size does not match", "cells": {}}
	if int(cell_size_value[0]) != CELL_SIZE or int(cell_size_value[1]) != CELL_SIZE:
		return {"valid": false, "error": "cell_size does not match", "cells": {}}
	if int(payload.get("columns", -1)) != COLUMN_COUNT or int(payload.get("rows", -1)) != ROW_COUNT:
		return {"valid": false, "error": "grid dimensions do not match", "cells": {}}
	if int(payload.get("save_sequence", -1)) < 1:
		return {"valid": false, "error": "save_sequence is invalid", "cells": {}}
	if int(payload.get("selected_count", -1)) != selected_cells_value.size():
		return {"valid": false, "error": "selected_count does not match selected_cells", "cells": {}}

	var validated_cells: Dictionary = {}
	var previous_coordinate := Vector2i(-1, -1)
	for index in range(selected_cells_value.size()):
		var cell = selected_cells_value[index]
		if not cell is Dictionary:
			return {"valid": false, "error": "cell %d is not a dictionary" % index, "cells": {}}
		var coordinate := Vector2i(int(cell.get("x", -1)), int(cell.get("y", -1)))
		if not _coordinate_is_valid(coordinate):
			return {"valid": false, "error": "cell %d is out of bounds: %s" % [index, coordinate], "cells": {}}
		if validated_cells.has(coordinate):
			return {"valid": false, "error": "cell %d duplicates %s" % [index, coordinate], "cells": {}}
		if index > 0 and (coordinate.y < previous_coordinate.y or (coordinate.y == previous_coordinate.y and coordinate.x <= previous_coordinate.x)):
			return {"valid": false, "error": "cell %d is not strictly y-then-x sorted" % index, "cells": {}}
		var expected_frame := coordinate.y * COLUMN_COUNT + coordinate.x
		if int(cell.get("frame", -1)) != expected_frame:
			return {"valid": false, "error": "cell %d frame is invalid" % index, "cells": {}}
		var region = cell.get("region")
		if not region is Array or region.size() != 4:
			return {"valid": false, "error": "cell %d region is invalid" % index, "cells": {}}
		var expected_region := [coordinate.x * CELL_SIZE, coordinate.y * CELL_SIZE, CELL_SIZE, CELL_SIZE]
		for region_index in range(4):
			if int(region[region_index]) != expected_region[region_index]:
				return {"valid": false, "error": "cell %d region values are invalid" % index, "cells": {}}
		var review_state := STATE_KEEP if schema_version == 1 else str(cell.get("review_state", ""))
		if review_state != STATE_KEEP and review_state != STATE_UNCERTAIN:
			return {"valid": false, "error": "cell %d review_state is invalid" % index, "cells": {}}
		validated_cells[coordinate] = review_state
		previous_coordinate = coordinate
	return {"valid": true, "error": "", "cells": validated_cells, "schema_version": schema_version}


func _run_self_test() -> void:
	if not atlas_is_valid:
		_report_error("self-test cannot run because atlas validation failed")
		get_tree().quit(1)
		return
	var schema_one_path := SELECTION_DIRECTORY.path_join("atlas_selection_001.json")
	if not FileAccess.file_exists(schema_one_path):
		_report_error("self-test requires protected schema-1 snapshot: %s" % schema_one_path)
		get_tree().quit(1)
		return
	var schema_one_payload = JSON.parse_string(FileAccess.get_file_as_string(schema_one_path))
	var schema_one_validation := _validate_payload(schema_one_payload)
	if not schema_one_validation.valid or schema_one_validation.schema_version != 1 or schema_one_validation.cells.size() != 497:
		_report_error("self-test schema-1 loading failed: %s" % schema_one_validation.error)
		get_tree().quit(1)
		return
	for loaded_state: String in schema_one_validation.cells.values():
		if loaded_state != STATE_KEEP:
			_report_error("self-test schema-1 conversion did not produce keep state")
			get_tree().quit(1)
			return
	var latest_path := _latest_snapshot_path()
	var latest_payload = JSON.parse_string(FileAccess.get_file_as_string(latest_path))
	var latest_validation := _validate_payload(latest_payload)
	if not latest_validation.valid:
		_report_error("self-test newest-snapshot validation failed: %s" % latest_validation.error)
		get_tree().quit(1)
		return
	var original_origin := atlas_origin
	var original_zoom_index := zoom_index
	atlas_origin = Vector2(100.0, 120.0)
	zoom_index = 2
	var test_screen_position := atlas_origin + Vector2(5 * CELL_SIZE * _zoom() + 1, 3 * CELL_SIZE * _zoom() + 1)
	var mapped := _coordinate_for_screen(test_screen_position)
	if mapped != Vector2i(5, 3):
		_report_error("self-test click mapping failed: got %s" % mapped)
		get_tree().quit(1)
		return
	selected_cells.clear()
	selected_cells[Vector2i(48, 21)] = STATE_KEEP
	selected_cells[Vector2i(5, 3)] = STATE_KEEP
	selected_cells[Vector2i(1, 1)] = STATE_KEEP
	_toggle_uncertain_at(test_screen_position)
	if selected_cells[Vector2i(5, 3)] != STATE_UNCERTAIN:
		_report_error("self-test keep-to-uncertain transition failed")
		get_tree().quit(1)
		return
	_toggle_uncertain_at(test_screen_position)
	if selected_cells[Vector2i(5, 3)] != STATE_KEEP:
		_report_error("self-test uncertain-to-keep transition failed")
		get_tree().quit(1)
		return
	_toggle_uncertain_at(test_screen_position)
	var payload := _build_payload(42)
	var cells: Array = payload.selected_cells
	if cells.size() != 3 or cells[0].x != 1 or cells[0].y != 1 or cells[1].x != 5 or cells[1].y != 3 or cells[2].x != 48 or cells[2].y != 21:
		_report_error("self-test deterministic selection sorting failed")
		get_tree().quit(1)
		return
	if payload.schema_version != 2 or cells[1].frame != 152 or cells[1].region != [80, 48, 16, 16] or cells[1].review_state != STATE_UNCERTAIN:
		_report_error("self-test schema-2 state, frame, or region derivation failed: %s" % cells[1])
		get_tree().quit(1)
		return
	var round_trip = JSON.parse_string(JSON.stringify(payload, "\t", true))
	var round_trip_validation := _validate_payload(round_trip)
	if not round_trip_validation.valid or round_trip_validation.cells.size() != 3 or round_trip_validation.cells[Vector2i(5, 3)] != STATE_UNCERTAIN:
		_report_error("self-test schema-2 JSON round-trip failed: %s" % round_trip_validation.error)
		get_tree().quit(1)
		return
	var invalid_payload: Dictionary = payload.duplicate(true)
	invalid_payload.selected_cells.append(invalid_payload.selected_cells[0].duplicate(true))
	invalid_payload.selected_count = 4
	var invalid_validation := _validate_payload(invalid_payload)
	if invalid_validation.valid:
		_report_error("self-test invalid duplicate snapshot was not refused")
		get_tree().quit(1)
		return
	var target := _next_snapshot_target()
	var expected_next_sequence := int(latest_payload.save_sequence) + 1
	var expected_next_filename := "atlas_selection_%03d.json" % expected_next_sequence
	if target.is_empty() or target.sequence != expected_next_sequence or target.path.get_file() != expected_next_filename or FileAccess.file_exists(target.path):
		_report_error("self-test unique snapshot target allocation failed")
		get_tree().quit(1)
		return
	selected_cells.clear()
	atlas_origin = original_origin
	zoom_index = original_zoom_index
	print("%s: self-test passed" % TOOL_ORIGIN)
	get_tree().quit(0)


func _report_error(message: String) -> void:
	push_error("%s: %s" % [TOOL_ORIGIN, message])
	if is_instance_valid(status_label):
		status_label.text = "ERROR: %s" % message
