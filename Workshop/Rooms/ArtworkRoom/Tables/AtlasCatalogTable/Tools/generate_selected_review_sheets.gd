extends SceneTree

const TOOL_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Tools/generate_selected_review_sheets.gd"
const ATLAS_PATH := "res://Workshop/Rooms/ArtworkRoom/Assets/Possible_Artwork/colored-transparent_packed.png"
const EXPECTED_ATLAS_SHA256 := "801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74"
const CATALOG_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json"
const EXPECTED_CATALOG_SHA256 := "438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2"
const OUTPUT_DIRECTORY := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Evidence/SelectedReviewSheets"
const CELL_SIZE := 16
const SCALE := 6
const DISPLAY_SIZE := CELL_SIZE * SCALE
const LABEL_HEIGHT := 18
const COLUMNS := 49

const DIGITS := {
	"0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"],
	"2": ["111", "001", "111", "100", "111"], "3": ["111", "001", "111", "001", "111"],
	"4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"], "7": ["111", "001", "010", "010", "010"],
	"8": ["111", "101", "111", "101", "111"], "9": ["111", "101", "111", "001", "111"],
	",": ["000", "000", "000", "010", "100"],
}


func _initialize() -> void:
	if FileAccess.get_sha256(ATLAS_PATH) != EXPECTED_ATLAS_SHA256 or FileAccess.get_sha256(CATALOG_PATH) != EXPECTED_CATALOG_SHA256:
		_fail("atlas or accepted catalog hash differs")
		return
	var atlas := Image.load_from_file(ATLAS_PATH)
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if atlas == null or atlas.is_empty() or not catalog is Dictionary or not catalog.get("entries") is Array:
		_fail("atlas or catalog could not be loaded")
		return
	var selected: Dictionary = {}
	for entry: Dictionary in catalog.entries:
		selected[Vector2i(int(entry.x), int(entry.y))] = true
	if selected.size() != 499:
		_fail("accepted coordinate count differs")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	var ranges: Array[Rect2i] = [Rect2i(0, 0, 25, 11), Rect2i(25, 0, 24, 11), Rect2i(0, 11, 25, 11), Rect2i(25, 11, 24, 11)]
	for page: Rect2i in ranges:
		if not _write_page(atlas, selected, page):
			return
	print("%s: generated four selected-only review sheets for 499 accepted cells" % TOOL_ORIGIN)
	quit(0)


func _write_page(atlas: Image, selected: Dictionary, page: Rect2i) -> bool:
	var stride := DISPLAY_SIZE + LABEL_HEIGHT
	var output := Image.create(page.size.x * DISPLAY_SIZE, page.size.y * stride, false, Image.FORMAT_RGBA8)
	output.fill(Color("151922"))
	for py in range(page.size.y):
		for px in range(page.size.x):
			var x := page.position.x + px
			var y := page.position.y + py
			var label_origin := Vector2i(px * DISPLAY_SIZE + 3, py * stride + 2)
			_draw_text(output, "%02d,%02d" % [x, y], label_origin, Color("c6cfdb"))
			_draw_text(output, "%04d" % (y * COLUMNS + x), label_origin + Vector2i(0, 8), Color("7f8b9d"))
			var destination := Vector2i(px * DISPLAY_SIZE, py * stride + LABEL_HEIGHT)
			var area := Rect2i(destination, Vector2i(DISPLAY_SIZE, DISPLAY_SIZE))
			if not selected.has(Vector2i(x, y)):
				output.fill_rect(area, Color("0d1016"))
				_draw_border(output, area, Color("262c38"))
				continue
			_draw_checkerboard(output, area)
			var tile := atlas.get_region(Rect2i(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE))
			tile.resize(DISPLAY_SIZE, DISPLAY_SIZE, Image.INTERPOLATE_NEAREST)
			output.blend_rect(tile, Rect2i(Vector2i.ZERO, tile.get_size()), destination)
			_draw_border(output, area, Color("4ee4ff"))
	var path := OUTPUT_DIRECTORY.path_join("selected_x%02d-%02d_y%02d-%02d.png" % [page.position.x, page.end.x - 1, page.position.y, page.end.y - 1])
	var error := output.save_png(path)
	if error != OK:
		_fail("could not save %s (error %d)" % [path, error])
		return false
	return true


func _draw_checkerboard(image: Image, area: Rect2i) -> void:
	const CHECK := 12
	for oy in range(0, area.size.y, CHECK):
		for ox in range(0, area.size.x, CHECK):
			var light := int(ox / CHECK + oy / CHECK) % 2 == 0
			image.fill_rect(Rect2i(area.position + Vector2i(ox, oy), Vector2i(CHECK, CHECK)), Color("737983") if light else Color("4d535c"))


func _draw_border(image: Image, area: Rect2i, color: Color) -> void:
	image.fill_rect(Rect2i(area.position, Vector2i(area.size.x, 2)), color)
	image.fill_rect(Rect2i(area.position + Vector2i(0, area.size.y - 2), Vector2i(area.size.x, 2)), color)
	image.fill_rect(Rect2i(area.position, Vector2i(2, area.size.y)), color)
	image.fill_rect(Rect2i(area.position + Vector2i(area.size.x - 2, 0), Vector2i(2, area.size.y)), color)


func _draw_text(image: Image, value: String, position: Vector2i, color: Color) -> void:
	var cursor := position.x
	for character in value:
		var pattern: Array = DIGITS.get(character, [])
		for row in range(pattern.size()):
			var bits: String = pattern[row]
			for column in range(bits.length()):
				if bits[column] == "1":
					image.set_pixel(cursor + column, position.y + row, color)
		cursor += 4


func _fail(message: String) -> void:
	push_error("%s: %s" % [TOOL_ORIGIN, message])
	quit(1)
