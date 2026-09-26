extends Node3D

const ORIGIN: String = "Workshop/WorkshopAssets/visualization_tool.gd"
const UNZONED_ROLE_KEY: int = -1

@onready var grid_map: GridMap = $GridMap

@export var layout_purpose: LayoutInterpretationSemantics.Purpose = LayoutInterpretationSemantics.Purpose.PRISON
@export var floor_mesh_id: int = 1
@export var wall_mesh_id: int = 2

var _floor_mesh_id_by_role: Dictionary = {}
var _door_floor_mesh_id: int = -1

func _ready() -> void:
	var archetype: GenerationSemantics.Archetype = _archetype_for_purpose(layout_purpose)
	if archetype == GenerationSemantics.Archetype.INVALID:
		push_error("%s: Layout Purpose %d has no compatible generator archetype." % [ORIGIN, layout_purpose])
		return

	var scale: GenerationSemantics.Scale = GenerationSemantics.Scale.LARGE
	var map_data: MapData = GeneratorCaller.make_map(
		MapParameters.new(
			archetype,
			scale,
			GenerationSemantics.GeometryModifier.STANDARD
		)
	)

	if map_data == null:
		push_error("%s: Map generation failed." % ORIGIN)
		return

	var interpretation: InterpretationData = LayoutInterpreter.interpret(
		map_data,
		layout_purpose,
		scale
	)
	if interpretation == null:
		push_error("%s: Layout interpretation failed." % ORIGIN)
		return

	var doorways: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(map_data)
	_prepare_colored_floor_meshes(interpretation)
	render_interpretation(interpretation, doorways)


func render_interpretation(
	interpretation: InterpretationData,
	doorways: Array[DoorwayPlacement] = []
) -> void:
	grid_map.clear()
	var map_data: MapData = interpretation.map_data

	for y: int in range(map_data.height):
		for x: int in range(map_data.width):
			var index: int = y * map_data.width + x
			var cell: int = map_data.cells[index]
			var grid_coordinate := Vector3i(x, 0, y)

			match cell:
				MapData.FLOOR:
					var coordinate := Vector2i(x, y)
					var zone_id: int = interpretation.get_zone_id_at(coordinate)
					var role_key: int = UNZONED_ROLE_KEY
					if zone_id > 0:
						var zone: InterpretationZone = interpretation.get_zone(zone_id)
						role_key = int(zone.area_role)
					grid_map.set_cell_item(grid_coordinate, int(_floor_mesh_id_by_role[role_key]))

				MapData.WALL:
					grid_map.set_cell_item(grid_coordinate, wall_mesh_id)

				MapData.ABYSS:
					pass

	for doorway: DoorwayPlacement in doorways:
		var coordinate: Vector2i = doorway.coordinate
		grid_map.set_cell_item(
			Vector3i(coordinate.x, 0, coordinate.y),
			_door_floor_mesh_id
		)


func _prepare_colored_floor_meshes(interpretation: InterpretationData) -> void:
	_floor_mesh_id_by_role.clear()
	grid_map.mesh_library = grid_map.mesh_library.duplicate(true)
	_create_colored_floor_mesh(UNZONED_ROLE_KEY, Color(0.28, 0.28, 0.28))

	for zone_id: int in interpretation.get_zone_ids():
		var zone: InterpretationZone = interpretation.get_zone(zone_id)
		var role_key: int = int(zone.area_role)
		if _floor_mesh_id_by_role.has(role_key):
			continue
		_create_colored_floor_mesh(role_key, _color_for_area_role(zone.area_role))
	_door_floor_mesh_id = _create_floor_mesh("Doorway", Color(1.0, 0.0, 0.0))


func _create_colored_floor_mesh(role_key: int, color: Color) -> void:
	_floor_mesh_id_by_role[role_key] = _create_floor_mesh(
		"AreaRole_%d" % role_key,
		color
	)


func _create_floor_mesh(item_name: String, color: Color) -> int:
	var source_mesh: Mesh = grid_map.mesh_library.get_item_mesh(floor_mesh_id)
	var colored_mesh: Mesh = source_mesh.duplicate(true)
	var colored_material: StandardMaterial3D = source_mesh.surface_get_material(0).duplicate(true)
	colored_material.albedo_color = color
	colored_mesh.surface_set_material(0, colored_material)

	var item_id: int = grid_map.mesh_library.get_last_unused_item_id()
	grid_map.mesh_library.create_item(item_id)
	grid_map.mesh_library.set_item_name(item_id, item_name)
	grid_map.mesh_library.set_item_mesh(item_id, colored_mesh)
	return item_id


func _color_for_area_role(area_role: LayoutInterpretationSemantics.AreaRole) -> Color:
	var hue: float = fmod(float(int(area_role)) * 0.61803398875, 1.0)
	return Color.from_hsv(hue, 0.72, 0.95)


func _archetype_for_purpose(
	purpose: LayoutInterpretationSemantics.Purpose
) -> GenerationSemantics.Archetype:
	match purpose:
		LayoutInterpretationSemantics.Purpose.PRISON, LayoutInterpretationSemantics.Purpose.CATACOMB:
			return GenerationSemantics.Archetype.DUNGEON
		LayoutInterpretationSemantics.Purpose.MAGE_TOWER, LayoutInterpretationSemantics.Purpose.GUARD_TOWER:
			return GenerationSemantics.Archetype.TOWER
		LayoutInterpretationSemantics.Purpose.BURROW_NEST, LayoutInterpretationSemantics.Purpose.MINE_SHAFT:
			return GenerationSemantics.Archetype.CAVE
	return GenerationSemantics.Archetype.INVALID
