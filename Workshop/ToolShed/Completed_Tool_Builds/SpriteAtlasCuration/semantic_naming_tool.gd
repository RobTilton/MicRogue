class_name ReusableSemanticNamingTool
extends Control

const ERROR_ORIGIN := "Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/semantic_naming_tool.gd"

@export var config: SpriteAtlasCurationConfig

var entries: Array[Dictionary] = []
var records: Dictionary = {}
var visible_indices: Array[int] = []
var current := -1
var valid := false
var loaded := "none"
var texture: Texture2D
var list := ItemList.new()
var filter := LineEdit.new()
var identity := Label.new()
var alias: LineEdit
var category: LineEdit
var family: LineEdit
var tags: LineEdit
var note := TextEdit.new()
var remove := CheckBox.new()
var status := Label.new()


func _ready() -> void:
	_build_ui()
	if config == null:
		_fail("configuration resource is not assigned")
		return
	var error := config.validate_for_naming()
	if not error.is_empty():
		_fail(error)
		return
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(config.catalog_path))
	var checked := _validate_catalog(catalog)
	if not checked.valid:
		_fail(checked.error)
		return
	entries = checked.entries
	texture = load(config.atlas_path) as Texture2D
	valid = true
	_load_latest()
	_rebuild()
	if not entries.is_empty(): _select(0)
	_set_status("Ready • Ctrl+S saves a new append-only snapshot")


func _build_ui() -> void:
	custom_minimum_size = Vector2(1200, 700)
	status.position = Vector2(16, 10); status.size = Vector2(1160, 28); status.text = "Validating configured catalog…"; add_child(status)
	filter.position = Vector2(16, 52); filter.size = Vector2(360, 32); filter.placeholder_text = "Filter address, alias, category, family, tag, or note"; filter.text_changed.connect(func(_text: String) -> void: _commit(); _rebuild()); add_child(filter)
	list.position = Vector2(16, 94); list.size = Vector2(360, 568); list.item_selected.connect(func(index: int) -> void: if index >= 0 and index < visible_indices.size(): _select(visible_indices[index])); add_child(list)
	identity.position = Vector2(402, 390); identity.size = Vector2(772, 28); add_child(identity)
	alias = _line("Alias", 426); category = _line("Category", 486); family = _line("Family", 546); tags = _line("Tags (comma-separated)", 606)
	var note_label := Label.new(); note_label.position = Vector2(704, 426); note_label.text = "Note"; add_child(note_label)
	note.position = Vector2(704, 450); note.size = Vector2(470, 132); add_child(note)
	remove.position = Vector2(704, 590); remove.text = "Request Remove"; remove.toggled.connect(func(_pressed: bool) -> void: _commit(); _rebuild()); add_child(remove)
	var previous := Button.new(); previous.position = Vector2(704, 640); previous.size = Vector2(100, 36); previous.text = "Previous"; previous.pressed.connect(func() -> void: _navigate(-1)); add_child(previous)
	var next := Button.new(); next.position = Vector2(812, 640); next.size = Vector2(100, 36); next.text = "Next"; next.pressed.connect(func() -> void: _navigate(1)); add_child(next)
	var save := Button.new(); save.position = Vector2(920, 640); save.size = Vector2(170, 36); save.text = "Save Snapshot"; save.pressed.connect(_save); add_child(save)


func _line(title: String, y: float) -> LineEdit:
	var label := Label.new(); label.position = Vector2(402, y); label.text = title; add_child(label)
	var edit := LineEdit.new(); edit.position = Vector2(402, y + 22); edit.size = Vector2(276, 32); add_child(edit)
	return edit


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("151922"))
	if texture == null or current < 0 or current >= entries.size(): return
	var entry := entries[current]
	var source := Rect2(entry.x * config.cell_size.x, entry.y * config.cell_size.y, config.cell_size.x, config.cell_size.y)
	draw_texture_rect_region(texture, Rect2(412, 94, 256, 256), source)
	draw_rect(Rect2(412, 94, 256, 256), Color("63ddff"), false, 2)
	var context := Rect2(704, 94, 470, 256)
	draw_texture_rect(texture, context, false)
	var scale := context.size / Vector2(config.atlas_size())
	var highlight := Rect2(context.position + Vector2(entry.x * config.cell_size.x, entry.y * config.cell_size.y) * scale, Vector2(config.cell_size) * scale)
	draw_rect(highlight.grow(1), Color("ffdc5c"), false, 3)


func _validate_catalog(payload: Variant) -> Dictionary:
	if not payload is Dictionary or not payload.get("entries") is Array or int(payload.get("entry_count", -1)) != payload.entries.size(): return {"valid": false, "error": "catalog root/count is invalid", "entries": []}
	if payload.get("atlas_path") != config.atlas_path or payload.get("atlas_sha256") != config.expected_atlas_sha256: return {"valid": false, "error": "catalog atlas authority differs", "entries": []}
	var parsed: Array[Dictionary] = []
	var seen: Dictionary = {}
	var previous := Vector2i(-1, -1)
	for raw in payload.entries:
		if not raw is Dictionary: return {"valid": false, "error": "catalog contains non-dictionary entry", "entries": []}
		var entry: Dictionary = raw
		var coordinate := Vector2i(int(entry.get("x", -1)), int(entry.get("y", -1)))
		var address := config.address_for(coordinate)
		var region := [coordinate.x * config.cell_size.x, coordinate.y * config.cell_size.y, config.cell_size.x, config.cell_size.y]
		if entry.get("id") != address or seen.has(address) or coordinate.x < 0 or coordinate.x >= config.columns or coordinate.y < 0 or coordinate.y >= config.rows: return {"valid": false, "error": "catalog identity/bounds/uniqueness failed", "entries": []}
		if not parsed.is_empty() and (coordinate.y < previous.y or (coordinate.y == previous.y and coordinate.x <= previous.x)): return {"valid": false, "error": "catalog order failed", "entries": []}
		if int(entry.get("frame", -1)) != coordinate.y * config.columns + coordinate.x or not _array_matches_ints(entry.get("region"), region): return {"valid": false, "error": "catalog geometry failed at %s" % address, "entries": []}
		parsed.append(entry.duplicate(true)); seen[address] = true; previous = coordinate
	return {"valid": true, "error": "", "entries": parsed}


func _array_matches_ints(value: Variant, expected: Array) -> bool:
	if not value is Array or value.size() != expected.size(): return false
	for index in range(expected.size()):
		if int(value[index]) != int(expected[index]): return false
	return true


func _latest() -> String:
	var highest := 0; var result := ""
	for filename in DirAccess.get_files_at(config.semantic_directory):
		if filename.begins_with("semantic_aliases_") and filename.ends_with(".json"):
			var text := filename.trim_prefix("semantic_aliases_").trim_suffix(".json")
			if text.is_valid_int() and text.to_int() > highest: highest = text.to_int(); result = config.semantic_directory.path_join(filename)
	return result


func _load_latest() -> void:
	var path := _latest()
	if path.is_empty(): return
	var checked := _validate_semantics(JSON.parse_string(FileAccess.get_file_as_string(path)))
	if not checked.valid: valid = false; _fail("newest semantic snapshot rejected without fallback: %s" % checked.error); return
	records = checked.records; loaded = path.get_file()


func _validate_semantics(payload: Variant) -> Dictionary:
	if not payload is Dictionary or not payload.get("aliases") is Array: return {"valid": false, "error": "semantic root/aliases invalid", "records": {}}
	if int(payload.get("schema_version", -1)) != 1 or payload.get("naming_contract") != "semantic_aliases_v1": return {"valid": false, "error": "semantic contract unsupported", "records": {}}
	if payload.get("catalog_path") != config.catalog_path or payload.get("catalog_sha256") != config.expected_catalog_sha256 or int(payload.get("catalog_entry_count", -1)) != entries.size(): return {"valid": false, "error": "semantic catalog authority differs", "records": {}}
	var valid_addresses: Dictionary = {}; for entry in entries: valid_addresses[entry.id] = true
	var parsed: Dictionary = {}; var names: Dictionary = {}; var named := 0
	for raw in payload.aliases:
		if not raw is Dictionary: return {"valid": false, "error": "semantic entry is not a dictionary", "records": {}}
		var record: Dictionary = raw; var address := str(record.get("address", "")); var name := str(record.get("alias", ""))
		if not valid_addresses.has(address) or parsed.has(address): return {"valid": false, "error": "unknown or duplicate address: %s" % address, "records": {}}
		if not name.is_empty() and (not _alias_valid(name) or names.has(name)): return {"valid": false, "error": "invalid or duplicate alias: %s" % name, "records": {}}
		if not record.get("tags") is Array or (record.has("remove_requested") and typeof(record.remove_requested) != TYPE_BOOL): return {"valid": false, "error": "tag/remove type invalid at %s" % address, "records": {}}
		if not name.is_empty(): names[name] = true; named += 1
		parsed[address] = record.duplicate(true)
	if int(payload.get("alias_count", -1)) != named or int(payload.get("record_count", parsed.size())) != parsed.size(): return {"valid": false, "error": "semantic declared counts differ", "records": {}}
	return {"valid": true, "error": "", "records": parsed}


func _rebuild() -> void:
	list.clear(); visible_indices.clear(); var query := filter.text.strip_edges().to_lower()
	for index in range(entries.size()):
		var address := str(entries[index].id); var record: Dictionary = records.get(address, {}); var name := str(record.get("alias", "")); var searchable := " ".join([address, name, str(record.get("category", "")), str(record.get("family", "")), ",".join(record.get("tags", [])), str(record.get("note", ""))]).to_lower()
		if not query.is_empty() and not searchable.contains(query): continue
		visible_indices.append(index); list.add_item("%03d  %s%s%s" % [int(entries[index].frame), address, " • " + name if not name.is_empty() else "", " [REMOVE]" if bool(record.get("remove_requested", false)) else ""])


func _select(index: int) -> void:
	if index < 0 or index >= entries.size(): return
	_commit(); current = index; var entry := entries[index]; var record: Dictionary = records.get(entry.id, {})
	identity.text = "%d / %d • %s • frame %d • (%d, %d)" % [index + 1, entries.size(), entry.id, entry.frame, entry.x, entry.y]
	alias.text = str(record.get("alias", "")); category.text = str(record.get("category", "")); family.text = str(record.get("family", "")); tags.text = ", ".join(record.get("tags", [])); note.text = str(record.get("note", "")); remove.set_pressed_no_signal(bool(record.get("remove_requested", false))); queue_redraw()


func _commit() -> void:
	if current < 0 or current >= entries.size(): return
	var address := str(entries[current].id); var name := alias.text.strip_edges(); var tag_list: Array[String] = []
	for raw in tags.text.split(","):
		var tag := raw.strip_edges(); if not tag.is_empty() and not tag_list.has(tag): tag_list.append(tag)
	var record := {"address": address, "alias": name, "category": category.text.strip_edges(), "family": family.text.strip_edges(), "tags": tag_list, "note": note.text.strip_edges(), "remove_requested": remove.button_pressed}
	if name.is_empty() and record.category.is_empty() and record.family.is_empty() and tag_list.is_empty() and record.note.is_empty() and not record.remove_requested: records.erase(address)
	else: records[address] = record


func _navigate(offset: int) -> void:
	if visible_indices.is_empty(): return
	var position := visible_indices.find(current); position = clampi((0 if position < 0 else position) + offset, 0, visible_indices.size() - 1); _select(visible_indices[position])


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.keycode == KEY_S: _save(); get_viewport().set_input_as_handled()


func _save() -> void:
	if not valid or FileAccess.get_sha256(config.catalog_path) != config.expected_catalog_sha256: _fail("save refused because source authority differs"); return
	_commit(); var names: Dictionary = {}
	for address in records:
		var record: Dictionary = records[address]; var name := str(record.alias)
		if not name.is_empty() and (not _alias_valid(name) or names.has(name) or str(record.category).is_empty() or str(record.family).is_empty()): _fail("save refused by alias uniqueness/syntax/metadata contract at %s" % address); return
		if not name.is_empty(): names[name] = true
	var sequence := 1; while FileAccess.file_exists(config.semantic_directory.path_join("semantic_aliases_%03d.json" % sequence)): sequence += 1
	var serialized: Array[Dictionary] = []; for entry in entries: if records.has(entry.id): serialized.append(records[entry.id].duplicate(true))
	var payload := {"schema_version": 1, "naming_contract": "semantic_aliases_v1", "catalog_path": config.catalog_path, "catalog_sha256": config.expected_catalog_sha256, "catalog_entry_count": entries.size(), "save_sequence": sequence, "alias_count": names.size(), "record_count": serialized.size(), "aliases": serialized}
	var path := config.semantic_directory.path_join("semantic_aliases_%03d.json" % sequence)
	var target_error: String = SpriteAtlasCatalogBuilder.write_target_error(path)
	if not target_error.is_empty(): _fail(target_error); return
	var temporary := path + ".tmp"; var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null: _fail("could not open temporary snapshot"); return
	file.store_string(JSON.stringify(payload, "\t") + "\n"); file.close()
	var checked := _validate_semantics(JSON.parse_string(FileAccess.get_file_as_string(temporary)))
	if not checked.valid: _fail("temporary snapshot failed read-back validation and was retained: %s" % checked.error); return
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(path))
	if rename_error != OK: _fail("validated snapshot could not be finalized; temporary retained"); return
	loaded = path.get_file(); _set_status("Saved %d aliases / %d records to %s" % [names.size(), serialized.size(), loaded]); _rebuild()


func _alias_valid(value: String) -> bool:
	var regex := RegEx.new(); regex.compile("^[a-z0-9]+(?:_[a-z0-9]+)*$"); return regex.search(value) != null


func _set_status(message: String) -> void: status.text = message


func _fail(message: String) -> void: valid = false; push_error("%s: %s" % [ERROR_ORIGIN, message]); status.text = "ERROR: " + message
