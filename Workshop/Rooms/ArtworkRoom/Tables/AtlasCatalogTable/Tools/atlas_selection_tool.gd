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


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process_unhandled_key_input(true)
	atlas_is_valid = _validate_atlas()
	_update_status("Ready" if atlas_is_valid else "Atlas validation failed; saving disabled")
	queue_redraw()
	if OS.get_cmdline_user_args().has("--self-test"):
		call_deferred("_run_self_test")


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
		draw_rect(selection_rect, Color(0.05, 0.85, 1.0, 0.42), true)
		draw_rect(selection_rect.grow(-1.0), Color(0.2, 0.95, 1.0, 1.0), false, 2.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_toggle_cell_at(mouse_event.position)
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


func _toggle_cell_at(screen_position: Vector2) -> void:
	if not atlas_is_valid:
		return
	var coordinate := _coordinate_for_screen(screen_position)
	if not _coordinate_is_valid(coordinate):
		return
	if selected_cells.has(coordinate):
		selected_cells.erase(coordinate)
	else:
		selected_cells[coordinate] = true
	_update_status("Selection changed")
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
	var state := "selected" if selected_cells.has(coordinate) else "not selected"
	hover_label.text = "Hover: (%d, %d)    frame %d    %s" % [coordinate.x, coordinate.y, frame, state]


func _update_status(prefix: String) -> void:
	status_label.text = "%s    Selected: %d    Zoom: %dx" % [prefix, selected_cells.size(), _zoom()]


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
		})
	return {
		"schema_version": 1,
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
	if not _payload_matches(parsed, payload.selected_count):
		_report_error("refused save because in-memory JSON round-trip validation failed")
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
	if not _payload_matches(written_payload, payload.selected_count):
		_report_error("temporary snapshot failed read-back validation and was retained for inspection: %s" % temporary_path)
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


func _payload_matches(payload, expected_count: int) -> bool:
	if not payload is Dictionary:
		return false
	var atlas_size_value = payload.get("atlas_size")
	var cell_size_value = payload.get("cell_size")
	var selected_cells_value = payload.get("selected_cells")
	if not atlas_size_value is Array or atlas_size_value.size() != 2:
		return false
	if not cell_size_value is Array or cell_size_value.size() != 2:
		return false
	if not selected_cells_value is Array:
		return false
	return (
		int(payload.get("schema_version", -1)) == 1
		and payload.get("atlas_path") == SOURCE_PATH
		and payload.get("atlas_sha256") == EXPECTED_SOURCE_SHA256
		and int(atlas_size_value[0]) == ATLAS_SIZE.x
		and int(atlas_size_value[1]) == ATLAS_SIZE.y
		and int(cell_size_value[0]) == CELL_SIZE
		and int(cell_size_value[1]) == CELL_SIZE
		and int(payload.get("columns", -1)) == COLUMN_COUNT
		and int(payload.get("rows", -1)) == ROW_COUNT
		and int(payload.get("selected_count", -1)) == expected_count
		and selected_cells_value.size() == expected_count
	)


func _run_self_test() -> void:
	if not atlas_is_valid:
		_report_error("self-test cannot run because atlas validation failed")
		get_tree().quit(1)
		return
	var original_origin := atlas_origin
	var original_zoom_index := zoom_index
	atlas_origin = Vector2(100.0, 120.0)
	zoom_index = 2
	var mapped := _coordinate_for_screen(atlas_origin + Vector2(5 * CELL_SIZE * _zoom() + 1, 3 * CELL_SIZE * _zoom() + 1))
	if mapped != Vector2i(5, 3):
		_report_error("self-test click mapping failed: got %s" % mapped)
		get_tree().quit(1)
		return
	selected_cells.clear()
	selected_cells[Vector2i(48, 21)] = true
	selected_cells[Vector2i(5, 3)] = true
	selected_cells[Vector2i(1, 1)] = true
	var payload := _build_payload(42)
	var cells: Array = payload.selected_cells
	if cells.size() != 3 or cells[0].x != 1 or cells[0].y != 1 or cells[1].x != 5 or cells[1].y != 3 or cells[2].x != 48 or cells[2].y != 21:
		_report_error("self-test deterministic selection sorting failed")
		get_tree().quit(1)
		return
	if cells[1].frame != 152 or cells[1].region != [80, 48, 16, 16]:
		_report_error("self-test frame or region derivation failed: %s" % cells[1])
		get_tree().quit(1)
		return
	var round_trip = JSON.parse_string(JSON.stringify(payload, "\t", true))
	if not _payload_matches(round_trip, 3):
		_report_error("self-test JSON round-trip failed")
		get_tree().quit(1)
		return
	var target := _next_snapshot_target()
	if target.is_empty() or FileAccess.file_exists(target.path):
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
