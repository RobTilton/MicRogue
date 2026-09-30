extends Control

const PREVIEW_ORIGIN := "res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/static_atlas_lookup_preview.gd"
const Catalog := preload("res://Workshop/Rooms/ArtworkRoom/Tables/AtlasCatalogTable/GodotConsumers/fantasy_sprite_catalog.gd")
const PREVIEW_ENTRIES: Array[Dictionary] = [
	{"id": &"atlas_x01_y00", "label": "atlas_x01_y00"},
	{"id": &"atlas_x24_y00", "label": "atlas_x24_y00"},
	{"id": &"atlas_x32_y04", "label": "atlas_x32_y04"},
	{"id": &"atlas_x48_y05", "label": "atlas_x48_y05"},
	{"id": &"atlas_x00_y12", "label": "atlas_x00_y12"},
	{"id": &"atlas_x18_y20", "label": "atlas_x18_y20"},
]

@onready var preview_grid: GridContainer = %PreviewGrid
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	for preview: Dictionary in PREVIEW_ENTRIES:
		var id: StringName = preview.id
		if not Catalog.has(id):
			push_error("%s: preview id is not accepted: %s" % [PREVIEW_ORIGIN, id])
			status_label.text = "ERROR: missing %s" % id
			return
		var panel := VBoxContainer.new()
		panel.custom_minimum_size = Vector2(192, 216)
		var texture_rect := TextureRect.new()
		texture_rect.custom_minimum_size = Vector2(192, 192)
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_rect.texture = Catalog.texture_for(id)
		var label := Label.new()
		label.text = str(preview.label)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(texture_rect)
		panel.add_child(label)
		preview_grid.add_child(panel)
	status_label.text = "6 representative lookups • 16×16 AtlasTexture regions • nearest-neighbor preview"
