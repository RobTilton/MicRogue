extends Control

const TOOL_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Tools/semantic_naming_tool.gd"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json"
const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const EXPECTED_CATALOG_COUNT := 499
const ATLAS_PATH := "res://Workshop/Rooms/ArtworkRoom/Assets/Possible_Artwork/colored-transparent_packed.png"
const EXPECTED_ATLAS_SHA256 := "801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74"
const ALIAS_DIRECTORY := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/SemanticAliases"
const CELL_SIZE := 16
const COLUMN_COUNT := 49
const ROW_COUNT := 22
const ATLAS_SIZE := Vector2i(784, 352)

var catalog_entries: Array[Dictionary] = []
var aliases_by_address: Dictionary = {}
var atlas_texture: Texture2D
var current_index := -1
var visible_indices: Array[int] = []
var loaded_snapshot := "none"
var input_is_valid := false

var item_list: ItemList
var filter_edit: LineEdit
var identity_label: Label
var alias_edit: LineEdit
var category_edit: LineEdit
var family_edit: LineEdit
var tags_edit: LineEdit
var note_edit: TextEdit
var status_label: Label
var named_label: Label


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_ui()
	input_is_valid = _load_and_validate_inputs()
	if not input_is_valid:
		_set_editor_enabled(false)
		return
	_load_latest_alias_snapshot()
	_rebuild_list()
	if not catalog_entries.is_empty():
		_select_catalog_index(0)
	_update_named_count()
	_set_status("Ready — Ctrl+S saves a new append-only snapshot")
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("151922"), true)
	if atlas_texture == null or current_index < 0 or current_index >= catalog_entries.size():
		return
	var entry := catalog_entries[current_index]
	var region := Rect2(float(entry.x * CELL_SIZE), float(entry.y * CELL_SIZE), CELL_SIZE, CELL_SIZE)
	draw_rect(Rect2(402, 84, 276, 292), Color("242936"), true)
	draw_texture_rect_region(atlas_texture, Rect2(412, 94, 256, 256), region)
	draw_rect(Rect2(412, 94, 256, 256), Color("63ddff"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(412, 370), "Active sprite • 16×16 shown at 16×", HORIZONTAL_ALIGNMENT_LEFT, 256, 16, Color("aeb8c8"))
	var context_rect := Rect2(704, 94, 470.4, 211.2)
	draw_rect(context_rect.grow(8), Color("242936"), true)
	draw_texture_rect(atlas_texture, context_rect, false)
	var scale := context_rect.size / Vector2(ATLAS_SIZE)
	var highlight := Rect2(context_rect.position + Vector2(entry.x * CELL_SIZE, entry.y * CELL_SIZE) * scale, Vector2(CELL_SIZE, CELL_SIZE) * scale)
	draw_rect(highlight.grow(1.0), Color("ffdc5c"), false, 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(704, 330), "Atlas context • selected cell outlined", HORIZONTAL_ALIGNMENT_LEFT, 470, 16, Color("aeb8c8"))


func _build_ui() -> void:
	var title := Label.new()
	title.position = Vector2(16, 10)
	title.size = Vector2(1160, 28)
	title.add_theme_font_size_override("font_size", 20)
	title.text = "ArtworkRoom • Semantic Naming Tool"
	add_child(title)

	status_label = Label.new()
	status_label.position = Vector2(16, 42)
	status_label.size = Vector2(1160, 24)
	status_label.add_theme_color_override("font_color", Color("6de0ff"))
	status_label.text = "Validating accepted catalog…"
	add_child(status_label)

	filter_edit = LineEdit.new()
	filter_edit.position = Vector2(16, 82)
	filter_edit.size = Vector2(360, 32)
	filter_edit.placeholder_text = "Filter address, alias, category, family, or tag"
	filter_edit.text_changed.connect(_on_filter_changed)
	add_child(filter_edit)

	item_list = ItemList.new()
	item_list.position = Vector2(16, 122)
	item_list.size = Vector2(360, 520)
	item_list.allow_reselect = true
	item_list.item_selected.connect(_on_item_selected)
	add_child(item_list)

	named_label = Label.new()
	named_label.position = Vector2(16, 650)
	named_label.size = Vector2(360, 24)
	add_child(named_label)

	identity_label = Label.new()
	identity_label.position = Vector2(402, 390)
	identity_label.size = Vector2(772, 24)
	identity_label.add_theme_color_override("font_color", Color("ffdc5c"))
	add_child(identity_label)

	alias_edit = _add_labeled_line("Alias", 422)
	category_edit = _add_labeled_line("Category", 480)
	family_edit = _add_labeled_line("Family", 538)
	tags_edit = _add_labeled_line("Tags (comma-separated)", 596)

	var note_label := Label.new()
	note_label.position = Vector2(704, 422)
	note_label.size = Vector2(470, 22)
	note_label.text = "Note"
	add_child(note_label)
	note_edit = TextEdit.new()
	note_edit.position = Vector2(704, 446)
	note_edit.size = Vector2(470, 136)
	note_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	add_child(note_edit)

	var previous_button := Button.new()
	previous_button.position = Vector2(402, 660)
	previous_button.size = Vector2(110, 36)
	previous_button.text = "Previous"
	previous_button.pressed.connect(func() -> void: _navigate(-1))
	add_child(previous_button)

	var next_button := Button.new()
	next_button.position = Vector2(520, 660)
	next_button.size = Vector2(110, 36)
	next_button.text = "Next"
	next_button.pressed.connect(func() -> void: _navigate(1))
	add_child(next_button)

	var save_button := Button.new()
	save_button.position = Vector2(704, 660)
	save_button.size = Vector2(220, 36)
	save_button.text = "Save New Snapshot (Ctrl+S)"
	save_button.pressed.connect(_save_snapshot)
	add_child(save_button)

	var clear_button := Button.new()
	clear_button.position = Vector2(934, 660)
	clear_button.size = Vector2(150, 36)
	clear_button.text = "Clear This Alias"
	clear_button.pressed.connect(_clear_current_alias)
	add_child(clear_button)


func _add_labeled_line(label_text: String, y: float) -> LineEdit:
	var label := Label.new()
	label.position = Vector2(402, y)
	label.size = Vector2(170, 24)
	label.text = label_text
	add_child(label)
	var edit := LineEdit.new()
	edit.position = Vector2(402, y + 22)
	edit.size = Vector2(276, 32)
	add_child(edit)
	return edit


func _load_and_validate_inputs() -> bool:
	if not FileAccess.file_exists(CATALOG_PATH) or FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256:
		_set_status("ERROR: accepted catalog is missing or changed")
		return false
	if not FileAccess.file_exists(ATLAS_PATH) or FileAccess.get_sha256(ATLAS_PATH) != EXPECTED_ATLAS_SHA256:
		_set_status("ERROR: packed atlas is missing or changed")
		return false
	var payload = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if not payload is Dictionary or not payload.get("entries") is Array:
		_set_status("ERROR: accepted catalog cannot be parsed")
		return false
	if payload.entries.size() != EXPECTED_CATALOG_COUNT or int(payload.get("entry_count", -1)) != EXPECTED_CATALOG_COUNT:
		_set_status("ERROR: accepted catalog must contain exactly %d entries" % EXPECTED_CATALOG_COUNT)
		return false
	var previous := Vector2i(-1, -1)
	var seen: Dictionary = {}
	for raw_entry in payload.entries:
		if not raw_entry is Dictionary:
			_set_status("ERROR: catalog contains a non-dictionary entry")
			return false
		var entry: Dictionary = raw_entry
		var coords := Vector2i(int(entry.get("x", -1)), int(entry.get("y", -1)))
		var expected_id := "atlas_x%02d_y%02d" % [coords.x, coords.y]
		if entry.get("id") != expected_id or int(entry.get("frame", -1)) != coords.y * COLUMN_COUNT + coords.x:
			_set_status("ERROR: catalog identity/geometry mismatch at %s" % expected_id)
			return false
		if seen.has(expected_id) or (not catalog_entries.is_empty() and (coords.y < previous.y or (coords.y == previous.y and coords.x <= previous.x))):
			_set_status("ERROR: catalog contains duplicate or unsorted entries")
			return false
		seen[expected_id] = true
		previous = coords
		catalog_entries.append(entry)
	atlas_texture = load(ATLAS_PATH) as Texture2D
	if atlas_texture == null or atlas_texture.get_size() != Vector2(ATLAS_SIZE):
		_set_status("ERROR: packed atlas texture failed exact dimension validation")
		return false
	return true


func _latest_alias_path() -> String:
	var highest := -1
	var result := ""
	for filename in DirAccess.get_files_at(ALIAS_DIRECTORY):
		if not filename.begins_with("semantic_aliases_") or not filename.ends_with(".json"):
			continue
		var sequence_text := filename.trim_prefix("semantic_aliases_").trim_suffix(".json")
		if sequence_text.is_valid_int() and sequence_text.to_int() > highest:
			highest = sequence_text.to_int()
			result = ALIAS_DIRECTORY.path_join(filename)
	return result


func _load_latest_alias_snapshot() -> void:
	var path := _latest_alias_path()
	if path.is_empty():
		return
	var payload = JSON.parse_string(FileAccess.get_file_as_string(path))
	var validation := _validate_alias_payload(payload)
	if not validation.valid:
		input_is_valid = false
		_set_editor_enabled(false)
		_set_status("ERROR: newest semantic snapshot rejected without fallback: %s" % validation.error)
		return
	aliases_by_address = validation.aliases
	loaded_snapshot = path.get_file()


func _validate_alias_payload(payload) -> Dictionary:
	if not payload is Dictionary or not payload.get("aliases") is Array:
		return _invalid("root or aliases array is invalid")
	if int(payload.get("schema_version", -1)) != 1 or payload.get("naming_contract") != "semantic_aliases_v1":
		return _invalid("schema or naming contract is unsupported")
	if payload.get("catalog_path") != CATALOG_PATH or payload.get("catalog_sha256") != EXPECTED_CATALOG_SHA256:
		return _invalid("catalog path or hash differs")
	if int(payload.get("catalog_entry_count", -1)) != EXPECTED_CATALOG_COUNT:
		return _invalid("catalog count differs")
	var valid_addresses: Dictionary = {}
	for entry: Dictionary in catalog_entries:
		valid_addresses[entry.id] = true
	var parsed: Dictionary = {}
	var seen_aliases: Dictionary = {}
	var parsed_alias_count := 0
	for raw_entry in payload.aliases:
		if not raw_entry is Dictionary:
			return _invalid("an alias entry is not a dictionary")
		var entry: Dictionary = raw_entry
		var address := str(entry.get("address", ""))
		var alias := str(entry.get("alias", ""))
		if not valid_addresses.has(address) or parsed.has(address):
			return _invalid("address is unknown or duplicated: %s" % address)
		if not alias.is_empty():
			if not _alias_is_valid(alias) or seen_aliases.has(alias):
				return _invalid("alias is invalid or duplicated: %s" % alias)
			seen_aliases[alias] = true
			parsed_alias_count += 1
		if not entry.get("tags") is Array:
			return _invalid("tags are not an array: %s" % address)
		if alias.is_empty() and str(entry.get("category", "")).is_empty() and str(entry.get("family", "")).is_empty() and entry.tags.is_empty() and str(entry.get("note", "")).is_empty():
			return _invalid("empty semantic record: %s" % address)
		parsed[address] = entry.duplicate(true)
	if int(payload.get("alias_count", -1)) != parsed_alias_count:
		return _invalid("declared alias count differs")
	if payload.has("record_count") and int(payload.record_count) != parsed.size():
		return _invalid("declared record count differs")
	return {"valid": true, "error": "", "aliases": parsed}


func _rebuild_list() -> void:
	item_list.clear()
	visible_indices.clear()
	var query := filter_edit.text.strip_edges().to_lower()
	for index in range(catalog_entries.size()):
		var entry := catalog_entries[index]
		var address := str(entry.id)
		var semantic: Dictionary = aliases_by_address.get(address, {})
		var alias := str(semantic.get("alias", ""))
		var searchable := " ".join([address, alias, str(semantic.get("category", "")), str(semantic.get("family", "")), ",".join(semantic.get("tags", []))]).to_lower()
		if not query.is_empty() and not searchable.contains(query):
			continue
		visible_indices.append(index)
		var suffix := ""
		if not alias.is_empty():
			suffix = "  •  " + alias
		elif not str(semantic.get("note", "")).is_empty():
			suffix = "  •  note"
		item_list.add_item("%03d  %s%s" % [int(entry.frame), address, suffix])
	if current_index >= 0:
		var visible_position := visible_indices.find(current_index)
		if visible_position >= 0:
			item_list.select(visible_position)


func _select_catalog_index(index: int) -> void:
	if index < 0 or index >= catalog_entries.size():
		return
	_commit_current_form()
	current_index = index
	var entry := catalog_entries[current_index]
	var address := str(entry.id)
	var semantic: Dictionary = aliases_by_address.get(address, {})
	identity_label.text = "%d / %d    %s    frame %d    coords (%d, %d)" % [current_index + 1, catalog_entries.size(), address, entry.frame, entry.x, entry.y]
	alias_edit.text = str(semantic.get("alias", ""))
	category_edit.text = str(semantic.get("category", ""))
	family_edit.text = str(semantic.get("family", ""))
	tags_edit.text = ", ".join(semantic.get("tags", []))
	note_edit.text = str(semantic.get("note", ""))
	var visible_position := visible_indices.find(current_index)
	if visible_position >= 0:
		item_list.select(visible_position)
		item_list.ensure_current_is_visible()
	queue_redraw()


func _commit_current_form() -> void:
	if current_index < 0 or current_index >= catalog_entries.size():
		return
	var address := str(catalog_entries[current_index].id)
	var alias := alias_edit.text.strip_edges()
	var tags: Array[String] = []
	for raw_tag in tags_edit.text.split(","):
		var tag := raw_tag.strip_edges()
		if not tag.is_empty() and not tags.has(tag):
			tags.append(tag)
	var category := category_edit.text.strip_edges()
	var family := family_edit.text.strip_edges()
	var note := note_edit.text.strip_edges()
	if alias.is_empty() and category.is_empty() and family.is_empty() and tags.is_empty() and note.is_empty():
		aliases_by_address.erase(address)
		return
	aliases_by_address[address] = {
		"address": address,
		"alias": alias,
		"category": category,
		"family": family,
		"tags": tags,
		"note": note,
	}


func _save_snapshot() -> void:
	if not input_is_valid:
		_set_status("Save refused: source validation failed")
		return
	_commit_current_form()
	var validation_error := _validate_working_aliases()
	if not validation_error.is_empty():
		_set_status("Save refused: %s" % validation_error)
		return
	var sequence := _next_sequence()
	var path := ALIAS_DIRECTORY.path_join("semantic_aliases_%03d.json" % sequence)
	if FileAccess.file_exists(path):
		_set_status("Save refused: target already exists: %s" % path.get_file())
		return
	var serialized: Array[Dictionary] = []
	for entry: Dictionary in catalog_entries:
		var address := str(entry.id)
		if aliases_by_address.has(address):
			serialized.append(aliases_by_address[address].duplicate(true))
	var named_count := _named_count()
	var payload := {
		"alias_count": named_count,
		"aliases": serialized,
		"catalog_entry_count": EXPECTED_CATALOG_COUNT,
		"catalog_path": CATALOG_PATH,
		"catalog_sha256": EXPECTED_CATALOG_SHA256,
		"naming_contract": "semantic_aliases_v1",
		"record_count": serialized.size(),
		"save_sequence": sequence,
		"schema_version": 1,
	}
	var encoded := JSON.stringify(payload, "\t") + "\n"
	var output := FileAccess.open(path, FileAccess.WRITE)
	if output == null:
		_set_status("Save failed: could not open target")
		return
	output.store_string(encoded)
	output.flush()
	output.close()
	var round_trip = JSON.parse_string(FileAccess.get_file_as_string(path))
	var round_trip_validation := _validate_alias_payload(round_trip)
	if not round_trip_validation.valid:
		_set_status("ERROR: saved snapshot failed round-trip validation: %s" % round_trip_validation.error)
		return
	loaded_snapshot = path.get_file()
	_rebuild_list()
	_update_named_count()
	_set_status("Saved %d named aliases and %d semantic records to %s" % [named_count, serialized.size(), path])
	print("%s: saved %d named aliases and %d semantic records to %s" % [TOOL_ORIGIN, named_count, serialized.size(), path])


func _validate_working_aliases() -> String:
	var seen: Dictionary = {}
	for address in aliases_by_address:
		var entry: Dictionary = aliases_by_address[address]
		var alias := str(entry.get("alias", ""))
		if not alias.is_empty() and not _alias_is_valid(alias):
			return "%s has an invalid alias: %s" % [address, alias]
		if not alias.is_empty() and seen.has(alias):
			return "duplicate alias %s at %s and %s" % [alias, seen[alias], address]
		if not alias.is_empty() and (str(entry.get("category", "")).is_empty() or str(entry.get("family", "")).is_empty()):
			return "%s requires category and family" % address
		if not alias.is_empty():
			seen[alias] = address
	return ""


func _alias_is_valid(alias: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^[a-z0-9]+(?:_[a-z0-9]+)*$")
	return regex.search(alias) != null


func _next_sequence() -> int:
	var highest := 0
	for filename in DirAccess.get_files_at(ALIAS_DIRECTORY):
		if filename.begins_with("semantic_aliases_") and filename.ends_with(".json"):
			var text := filename.trim_prefix("semantic_aliases_").trim_suffix(".json")
			if text.is_valid_int():
				highest = maxi(highest, text.to_int())
	return highest + 1


func _navigate(offset: int) -> void:
	if catalog_entries.is_empty():
		return
	_select_catalog_index(clampi(current_index + offset, 0, catalog_entries.size() - 1))


func _on_item_selected(visible_index: int) -> void:
	if visible_index >= 0 and visible_index < visible_indices.size():
		_select_catalog_index(visible_indices[visible_index])


func _on_filter_changed(_new_text: String) -> void:
	_commit_current_form()
	_rebuild_list()


func _clear_current_alias() -> void:
	alias_edit.clear()
	category_edit.clear()
	family_edit.clear()
	tags_edit.clear()
	note_edit.clear()
	_commit_current_form()
	_rebuild_list()
	_update_named_count()
	_set_status("Alias cleared in working memory; save to preserve the change")


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo and key.ctrl_pressed and key.keycode == KEY_S:
			_save_snapshot()
			get_viewport().set_input_as_handled()
		elif key.pressed and not key.echo and key.ctrl_pressed and key.keycode == KEY_LEFT:
			_navigate(-1)
			get_viewport().set_input_as_handled()
		elif key.pressed and not key.echo and key.ctrl_pressed and key.keycode == KEY_RIGHT:
			_navigate(1)
			get_viewport().set_input_as_handled()


func _update_named_count() -> void:
	named_label.text = "Named: %d / %d    Records: %d    Loaded: %s" % [_named_count(), EXPECTED_CATALOG_COUNT, aliases_by_address.size(), loaded_snapshot]


func _named_count() -> int:
	var count := 0
	for entry: Dictionary in aliases_by_address.values():
		if not str(entry.get("alias", "")).is_empty():
			count += 1
	return count


func _set_status(message: String) -> void:
	if status_label != null:
		status_label.text = message


func _set_editor_enabled(enabled: bool) -> void:
	for control in [item_list, filter_edit, alias_edit, category_edit, family_edit, tags_edit, note_edit]:
		if control != null:
			control.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE


func _invalid(message: String) -> Dictionary:
	return {"valid": false, "error": message, "aliases": {}}
