extends SceneTree

const TOOL_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Tools/generate_atlas_intake.gd"
const SOURCE_PATH := "res://Workshop/Rooms/ArtworkRoom/Assets/Possible_Artwork/colored-transparent_packed.png"
const OUTPUT_DIRECTORY := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Evidence/ContactSheets"
const MANIFEST_PATH := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/Evidence/atlas_cells.csv"
const CELL_SIZE := 16
const COLUMN_COUNT := 49
const ROW_COUNT := 22
const DISPLAY_SCALE := 4
const DISPLAY_CELL_SIZE := CELL_SIZE * DISPLAY_SCALE
const LABEL_HEIGHT := 9

const DIGIT_PATTERNS := {
	"0": ["111", "101", "101", "101", "111"],
	"1": ["010", "110", "010", "010", "111"],
	"2": ["111", "001", "111", "100", "111"],
	"3": ["111", "001", "111", "001", "111"],
	"4": ["101", "101", "111", "001", "001"],
	"5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"],
	"7": ["111", "001", "010", "010", "010"],
	"8": ["111", "101", "111", "101", "111"],
	"9": ["111", "101", "111", "001", "111"],
	",": ["000", "000", "000", "010", "100"],
}


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		_fail("could not load source atlas: %s" % SOURCE_PATH)
		return
	if source.get_width() != COLUMN_COUNT * CELL_SIZE or source.get_height() != ROW_COUNT * CELL_SIZE:
		_fail(
			"source atlas is %dx%d; expected %dx%d for a %dx%d grid of %dx%d cells"
			% [
				source.get_width(), source.get_height(),
				COLUMN_COUNT * CELL_SIZE, ROW_COUNT * CELL_SIZE,
				COLUMN_COUNT, ROW_COUNT, CELL_SIZE, CELL_SIZE,
			]
		)
		return

	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		_fail("could not create output directory %s (error %d)" % [OUTPUT_DIRECTORY, directory_error])
		return

	if not _write_manifest(source):
		return

	var page_ranges: Array[Rect2i] = [
		Rect2i(0, 0, 25, 11),
		Rect2i(25, 0, 24, 11),
		Rect2i(0, 11, 25, 11),
		Rect2i(25, 11, 24, 11),
	]
	for page_range in page_ranges:
		if not _write_contact_sheet(source, page_range):
			return

	print("%s: generated atlas manifest and %d contact sheets" % [TOOL_ORIGIN, page_ranges.size()])
	quit(0)


func _write_manifest(source: Image) -> bool:
	var manifest := FileAccess.open(MANIFEST_PATH, FileAccess.WRITE)
	if manifest == null:
		_fail("could not open manifest for writing: %s" % MANIFEST_PATH)
		return false
	manifest.store_line("x,y,frame,nontransparent_pixels,bbox_x,bbox_y,bbox_width,bbox_height")
	for y in range(ROW_COUNT):
		for x in range(COLUMN_COUNT):
			var occupied := 0
			var minimum := Vector2i(CELL_SIZE, CELL_SIZE)
			var maximum := Vector2i(-1, -1)
			for local_y in range(CELL_SIZE):
				for local_x in range(CELL_SIZE):
					if source.get_pixel(x * CELL_SIZE + local_x, y * CELL_SIZE + local_y).a > 0.0:
						occupied += 1
						minimum.x = mini(minimum.x, local_x)
						minimum.y = mini(minimum.y, local_y)
						maximum.x = maxi(maximum.x, local_x)
						maximum.y = maxi(maximum.y, local_y)
			var frame := y * COLUMN_COUNT + x
			if occupied == 0:
				manifest.store_csv_line(PackedStringArray([str(x), str(y), str(frame), "0", "-1", "-1", "0", "0"]))
			else:
				manifest.store_csv_line(PackedStringArray([
					str(x), str(y), str(frame), str(occupied),
					str(minimum.x), str(minimum.y),
					str(maximum.x - minimum.x + 1), str(maximum.y - minimum.y + 1),
				]))
	manifest.close()
	return true


func _write_contact_sheet(source: Image, page_range: Rect2i) -> bool:
	var stride := DISPLAY_CELL_SIZE + LABEL_HEIGHT
	var output := Image.create(page_range.size.x * DISPLAY_CELL_SIZE, page_range.size.y * stride, false, Image.FORMAT_RGBA8)
	output.fill(Color("20242a"))
	for page_y in range(page_range.size.y):
		for page_x in range(page_range.size.x):
			var atlas_x := page_range.position.x + page_x
			var atlas_y := page_range.position.y + page_y
			var destination := Vector2i(page_x * DISPLAY_CELL_SIZE, page_y * stride + LABEL_HEIGHT)
			_draw_checkerboard(output, Rect2i(destination, Vector2i(DISPLAY_CELL_SIZE, DISPLAY_CELL_SIZE)))
			var tile := source.get_region(Rect2i(atlas_x * CELL_SIZE, atlas_y * CELL_SIZE, CELL_SIZE, CELL_SIZE))
			tile.resize(DISPLAY_CELL_SIZE, DISPLAY_CELL_SIZE, Image.INTERPOLATE_NEAREST)
			output.blend_rect(tile, Rect2i(Vector2i.ZERO, tile.get_size()), destination)
			_draw_border(output, Rect2i(destination, Vector2i(DISPLAY_CELL_SIZE, DISPLAY_CELL_SIZE)), Color("59616c"))
			_draw_text(output, "%02d,%02d" % [atlas_x, atlas_y], Vector2i(page_x * DISPLAY_CELL_SIZE + 2, page_y * stride + 2), Color.WHITE)

	var last_x := page_range.end.x - 1
	var last_y := page_range.end.y - 1
	var filename := "atlas_x%02d-%02d_y%02d-%02d.png" % [page_range.position.x, last_x, page_range.position.y, last_y]
	var output_path := OUTPUT_DIRECTORY.path_join(filename)
	var save_error := output.save_png(output_path)
	if save_error != OK:
		_fail("could not save contact sheet %s (error %d)" % [output_path, save_error])
		return false
	return true


func _draw_checkerboard(image: Image, area: Rect2i) -> void:
	const CHECK_SIZE := 8
	for offset_y in range(0, area.size.y, CHECK_SIZE):
		for offset_x in range(0, area.size.x, CHECK_SIZE):
			var is_light := ((offset_x / CHECK_SIZE) + (offset_y / CHECK_SIZE)) as int % 2 == 0
			var color := Color("737983") if is_light else Color("4d535c")
			image.fill_rect(
				Rect2i(area.position + Vector2i(offset_x, offset_y), Vector2i(CHECK_SIZE, CHECK_SIZE)),
				color
			)


func _draw_border(image: Image, area: Rect2i, color: Color) -> void:
	image.fill_rect(Rect2i(area.position, Vector2i(area.size.x, 1)), color)
	image.fill_rect(Rect2i(area.position + Vector2i(0, area.size.y - 1), Vector2i(area.size.x, 1)), color)
	image.fill_rect(Rect2i(area.position, Vector2i(1, area.size.y)), color)
	image.fill_rect(Rect2i(area.position + Vector2i(area.size.x - 1, 0), Vector2i(1, area.size.y)), color)


func _draw_text(image: Image, value: String, position: Vector2i, color: Color) -> void:
	var cursor_x := position.x
	for character in value:
		var pattern: Array = DIGIT_PATTERNS.get(character, [])
		for row in range(pattern.size()):
			var bits: String = pattern[row]
			for column in range(bits.length()):
				if bits[column] == "1":
					image.set_pixel(cursor_x + column, position.y + row, color)
		cursor_x += 4


func _fail(message: String) -> void:
	push_error("%s: %s" % [TOOL_ORIGIN, message])
	quit(1)
