extends Node2D
const ORIGIN := "Production/Tools/DecoratedDungeonPreview/decoration_generation_preview.gd"
const Generator := preload("res://Production/Systems/RapidRoomGenerationSystem/rapid_room_generator.gd")
const Layout := preload("res://Production/Systems/RoomLayoutSystem/room_layout_tagger.gd")
const Catalog := preload("res://Production/Systems/DecorationPipeline/CatalogAdapter/decoration_catalog_adapter.gd")
const Profile := preload("res://Production/Systems/DecorationPipeline/FantasyDungeonProfile/fantasy_dungeon_profile.gd")
const Renderer := preload("res://Production/Systems/DecorationPipeline/TileMapLayerAdapter/decoration_tile_map_layer_adapter.gd")
@onready var base_layer: TileMapLayer = $BaseLayer
@onready var sticker_layer: TileMapLayer = $StickerLayer
@onready var camera: Camera2D = $Camera2D
@onready var archetype_input: OptionButton = $UI/Panel/Content/Row/Archetype
@onready var size_input: SpinBox = $UI/Panel/Content/Row/Size
@onready var seed_input: SpinBox = $UI/Panel/Content/Row/Seed
@onready var status_label: Label = $UI/Panel/Content/Status
var adapter: RefCounted
func _ready() -> void:
	for name in ["Cave", "Catacomb", "Nest", "SubPassage"]: archetype_input.add_item(name)
	$UI/Panel/Content/Row/Regenerate.pressed.connect(regenerate)
	adapter = Catalog.create()
	if adapter == null: _fail("catalog adapter initialization failed"); return
	regenerate()
func regenerate() -> void:
	var size := int(size_input.value); var seed := int(seed_input.value); var archetype := archetype_input.selected
	var source: RapidRoomMapData = Generator.make_seeded_map(size, seed)
	if source == null or not Layout.tag_rooms_seeded(source, archetype, seed): return _fail("generation or Layout failed")
	var result: RefCounted = Profile.decorate(source, seed, adapter)
	if result == null or not Renderer.render(base_layer, sticker_layer, result, adapter): return _fail("Decoration or rendering failed")
	var pixels := Vector2(result.width, result.height) * 16.0
	camera.position = pixels * 0.5; camera.zoom = Vector2.ONE * clampf(minf(900.0 / pixels.x, 650.0 / pixels.y), 0.25, 2.0)
	status_label.text = "%s | size %d | seed %d | %dx%d cells" % [archetype_input.get_item_text(archetype), size, seed, result.width, result.height]
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera.zoom *= 1.15
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera.zoom /= 1.15
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_MIDDLE: camera.position -= event.relative / camera.zoom
func _fail(message: String) -> void:
	status_label.text = "FAILED: %s" % message; push_error("%s: %s" % [ORIGIN, message])
