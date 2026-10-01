class_name ReusableAtlasSelectionTool
extends Control

const ERROR_ORIGIN := "Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/atlas_selection_tool.gd"
const KEEP := "keep"
const UNCERTAIN := "uncertain"

@export var config: SpriteAtlasCurationConfig

var texture: Texture2D
var selected: Dictionary = {}
var origin := Vector2(24, 88)
var zoom_levels: Array[int] = [1, 2, 4, 8]
var zoom_index := 1
var panning := false
var valid := false
var loaded_name := "none"
var status := Label.new()
var hover := Label.new()


func _ready() -> void:
	_build_ui()
	if config == null:
		_fail("configuration resource is not assigned")
		return
	var error := config.validate_for_selection()
	if not error.is_empty():
		_fail(error)
		return
	texture = load(config.atlas_path) as Texture2D
	valid = true
	_load_latest()
	_update_status("Ready")
	queue_redraw()


func _build_ui() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	status.position = Vector2(12, 8)
	status.size = Vector2(1120, 28)
	status.text = "Validating configured atlas…"
	add_child(status)
	hover.position = Vector2(12, 38)
	hover.size = Vector2(1120, 28)
	hover.text = "Left: select • Right: keep/uncertain • Middle drag: pan • Wheel: zoom • Space: save"
	add_child(hover)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("171a20"))
	if texture == null:
		return
	var scale := float(zoom_levels[zoom_index])
	var atlas_rect := Rect2(origin, Vector2(config.atlas_size()) * scale)
	draw_texture_rect(texture, atlas_rect, false)
	if scale >= 2.0:
		for x in range(config.columns + 1):
			var px := origin.x + x * config.cell_size.x * scale
			draw_line(Vector2(px, origin.y), Vector2(px, atlas_rect.end.y), Color(0.7, 0.75, 0.85, 0.3))
		for y in range(config.rows + 1):
			var py := origin.y + y * config.cell_size.y * scale
			draw_line(Vector2(origin.x, py), Vector2(atlas_rect.end.x, py), Color(0.7, 0.75, 0.85, 0.3))
	for coordinate: Vector2i in selected:
		var rect := Rect2(origin + Vector2(coordinate * config.cell_size) * scale, Vector2(config.cell_size) * scale)
		var uncertain: bool = selected[coordinate] == UNCERTAIN
		draw_rect(rect, Color(1, 0.7, 0.05, 0.48) if uncertain else Color(0.05, 0.85, 1, 0.42), true)
		draw_rect(rect.grow(-1), Color(1, 0.9, 0.2) if uncertain else Color(0.2, 0.95, 1), false, 2)


func _gui_input(event: InputEvent) -> void:
	if not valid:
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			var coordinate := _coordinate(mouse.position)
			if _in_bounds(coordinate):
				if selected.has(coordinate): selected.erase(coordinate)
				else: selected[coordinate] = KEEP
				_update_status("Selection changed")
				queue_redraw()
		elif mouse.button_index == MOUSE_BUTTON_RIGHT and mouse.pressed:
			var coordinate := _coordinate(mouse.position)
			if _in_bounds(coordinate):
				selected[coordinate] = UNCERTAIN if selected.get(coordinate, KEEP) == KEEP else KEEP
				_update_status("Review state changed")
				queue_redraw()
		elif mouse.button_index == MOUSE_BUTTON_MIDDLE:
			panning = mouse.pressed
		elif mouse.pressed and mouse.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var old_scale := float(zoom_levels[zoom_index])
			var atlas_position := (mouse.position - origin) / old_scale
			zoom_index = clampi(zoom_index + (1 if mouse.button_index == MOUSE_BUTTON_WHEEL_UP else -1), 0, zoom_levels.size() - 1)
			origin = mouse.position - atlas_position * zoom_levels[zoom_index]
			queue_redraw()
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if panning:
			origin += motion.relative
			queue_redraw()
		var coordinate := _coordinate(motion.position)
		hover.text = "%s • frame %d • %s" % [coordinate, coordinate.y * config.columns + coordinate.x, selected.get(coordinate, "not selected")] if _in_bounds(coordinate) else "Outside atlas"


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_save()
		get_viewport().set_input_as_handled()


func _coordinate(screen_position: Vector2) -> Vector2i:
	var local := (screen_position - origin) / float(zoom_levels[zoom_index])
	return Vector2i(floori(local.x / config.cell_size.x), floori(local.y / config.cell_size.y))


func _in_bounds(coordinate: Vector2i) -> bool:
	return coordinate.x >= 0 and coordinate.x < config.columns and coordinate.y >= 0 and coordinate.y < config.rows


func _latest() -> String:
	var highest := 0
	var result := ""
	for filename in DirAccess.get_files_at(config.selection_directory):
		if filename.begins_with("atlas_selection_") and filename.ends_with(".json"):
			var text := filename.trim_prefix("atlas_selection_").trim_suffix(".json")
			if text.is_valid_int() and text.to_int() > highest:
				highest = text.to_int()
				result = config.selection_directory.path_join(filename)
	return result


func _load_latest() -> void:
	var path := _latest()
	if path.is_empty(): return
	var checked := _validate_payload(JSON.parse_string(FileAccess.get_file_as_string(path)))
	if not checked.valid:
		valid = false
		_fail("newest snapshot rejected without fallback: %s" % checked.error)
		return
	selected = checked.cells
	loaded_name = path.get_file()


func _payload(sequence: int) -> Dictionary:
	var coordinates: Array[Vector2i] = []
	for coordinate: Vector2i in selected: coordinates.append(coordinate)
	coordinates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x if a.y == b.y else a.y < b.y)
	var cells: Array[Dictionary] = []
	for coordinate in coordinates:
		cells.append({"x": coordinate.x, "y": coordinate.y, "frame": coordinate.y * config.columns + coordinate.x, "region": [coordinate.x * config.cell_size.x, coordinate.y * config.cell_size.y, config.cell_size.x, config.cell_size.y], "review_state": selected[coordinate]})
	return {"schema_version": 2, "atlas_path": config.atlas_path, "atlas_sha256": config.expected_atlas_sha256, "atlas_size": [config.atlas_size().x, config.atlas_size().y], "cell_size": [config.cell_size.x, config.cell_size.y], "columns": config.columns, "rows": config.rows, "save_sequence": sequence, "selected_count": cells.size(), "selected_cells": cells}


func _validate_payload(payload: Variant) -> Dictionary:
	if not payload is Dictionary or not payload.get("selected_cells") is Array:
		return {"valid": false, "error": "invalid root or selected_cells", "cells": {}}
	if payload.get("atlas_path") != config.atlas_path or payload.get("atlas_sha256") != config.expected_atlas_sha256:
		return {"valid": false, "error": "atlas authority differs", "cells": {}}
	var cell_size_value = payload.get("cell_size")
	if int(payload.get("columns", -1)) != config.columns or int(payload.get("rows", -1)) != config.rows or not _array_matches_ints(cell_size_value, [config.cell_size.x, config.cell_size.y]):
		return {"valid": false, "error": "grid contract differs", "cells": {}}
	if int(payload.get("selected_count", -1)) != payload.selected_cells.size():
		return {"valid": false, "error": "selected_count differs", "cells": {}}
	var result: Dictionary = {}
	var previous := Vector2i(-1, -1)
	for raw in payload.selected_cells:
		if not raw is Dictionary: return {"valid": false, "error": "non-dictionary cell", "cells": {}}
		var coordinate := Vector2i(int(raw.get("x", -1)), int(raw.get("y", -1)))
		var state := str(raw.get("review_state", KEEP))
		var region := [coordinate.x * config.cell_size.x, coordinate.y * config.cell_size.y, config.cell_size.x, config.cell_size.y]
		if not _in_bounds(coordinate) or result.has(coordinate) or (not result.is_empty() and (coordinate.y < previous.y or (coordinate.y == previous.y and coordinate.x <= previous.x))): return {"valid": false, "error": "cell bounds/order/uniqueness failed", "cells": {}}
		if state not in [KEEP, UNCERTAIN] or int(raw.get("frame", -1)) != coordinate.y * config.columns + coordinate.x or not _array_matches_ints(raw.get("region"), region): return {"valid": false, "error": "cell state or geometry failed", "cells": {}}
		result[coordinate] = state
		previous = coordinate
	return {"valid": true, "error": "", "cells": result}


func _array_matches_ints(value: Variant, expected: Array) -> bool:
	if not value is Array or value.size() != expected.size(): return false
	for index in range(expected.size()):
		if int(value[index]) != int(expected[index]): return false
	return true


func _save() -> void:
	if not valid or FileAccess.get_sha256(config.atlas_path) != config.expected_atlas_sha256:
		_fail("save refused because source validation differs")
		return
	var sequence := 1
	while FileAccess.file_exists(config.selection_directory.path_join("atlas_selection_%03d.json" % sequence)): sequence += 1
	var path := config.selection_directory.path_join("atlas_selection_%03d.json" % sequence)
	var payload := _payload(sequence)
	var checked := _validate_payload(JSON.parse_string(JSON.stringify(payload)))
	if not checked.valid:
		_fail("save refused: %s" % checked.error)
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_fail("could not open snapshot target")
		return
	file.store_string(JSON.stringify(payload, "\t") + "\n")
	file.close()
	loaded_name = path.get_file()
	_update_status("Saved %s" % loaded_name)


func _update_status(prefix: String) -> void:
	var uncertain := selected.values().count(UNCERTAIN)
	status.text = "%s • Total %d • Keep %d • Uncertain %d • Loaded %s" % [prefix, selected.size(), selected.size() - uncertain, uncertain, loaded_name]


func _fail(message: String) -> void:
	push_error("%s: %s" % [ERROR_ORIGIN, message])
	status.text = "ERROR: " + message
