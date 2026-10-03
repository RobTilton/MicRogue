extends Node3D

const ORIGIN: String = "Workshop/ToolShed/Completed_Tool_Builds/RapidGenerationInspection/visualization_tool.gd"

@onready var grid_map: GridMap = $GridMap
@onready var camera: Camera3D = $Camera3D

@export_range(4, 100, 1) var size: int = 5
@export_enum("Cave:0", "Catacomb:1", "Nest:2", "SubPassage:3") var archetype: int = RoomLayoutSemantics.Archetype.CAVE
@export var seed: int = 8105
@export var floor_mesh_id: int = 1
@export var wall_mesh_id: int = 2
@export var door_mesh_id: int = 3

var _floor_mesh_id_by_room_type: Dictionary = {}
var _unowned_floor_mesh_id: int = -1
var rendered_map_data: RapidRoomMapData


func _ready() -> void:
	var map_data: RapidRoomMapData = RapidRoomGenerator.make_seeded_map(size, seed)
	if map_data == null or not RoomLayoutTagger.tag_rooms_seeded(map_data, archetype, seed):
		push_error("%s: seeded Rapid/Layout generation failed for size %d, archetype %d, seed %d." % [ORIGIN, size, archetype, seed])
		return
	render_map_data(map_data)


func render_map_data(map_data: RapidRoomMapData) -> bool:
	var map_side: int = int(round(sqrt(float(map_data.cells.size()))))
	if map_side < 1 or map_side * map_side != map_data.cells.size():
		push_error("%s: layer-three cells do not form a square map." % ORIGIN)
		return false
	rendered_map_data = map_data
	_prepare_colored_floor_meshes(map_data.rooms)
	grid_map.clear()
	for y: int in range(map_side):
		for x: int in range(map_side):
			var index: int = y * map_side + x
			var grid_coordinate := Vector3i(x, 0, y)
			if map_data.cells[index] == RapidRoomMapData.WALL:
				grid_map.set_cell_item(grid_coordinate, wall_mesh_id)
			else:
				grid_map.set_cell_item(grid_coordinate, _unowned_floor_mesh_id)
	for room: RapidRoom in map_data.rooms:
		var room_mesh_id: int = int(_floor_mesh_id_by_room_type[room.room_type])
		for coordinate: Vector2i in room.floor_coordinates:
			grid_map.set_cell_item(Vector3i(coordinate.x, 0, coordinate.y), room_mesh_id)
	for doorway: RapidRoomDoorway in map_data.doorways:
		var orientation: int = 0
		if doorway.door_item_axis == RapidRoomDoorway.Axis.VERTICAL:
			orientation = grid_map.get_orthogonal_index_from_basis(Basis(Vector3.UP, PI * 0.5))
		grid_map.set_cell_item(
			Vector3i(doorway.position.x, 0, doorway.position.y),
			door_mesh_id,
			orientation
		)
	_frame_camera(map_side)
	return true


func _prepare_colored_floor_meshes(rooms: Array[RapidRoom]) -> void:
	_floor_mesh_id_by_room_type.clear()
	grid_map.mesh_library = grid_map.mesh_library.duplicate(true)
	_unowned_floor_mesh_id = _create_floor_mesh("UnownedFloor", Color(0.28, 0.28, 0.28))
	var color_index: int = 0
	for room: RapidRoom in rooms:
		if _floor_mesh_id_by_room_type.has(room.room_type):
			continue
		var hue: float = fmod(float(color_index) * 0.61803398875, 1.0)
		_floor_mesh_id_by_room_type[room.room_type] = _create_floor_mesh(
			"RoomType_%s" % room.room_type,
			Color.from_hsv(hue, 0.72, 0.95)
		)
		color_index += 1


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


func _frame_camera(map_side: int) -> void:
	var center: float = float(map_side - 1) * 0.5
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = float(map_side) * 1.1
	camera.position = Vector3(center, float(map_side), center)
	camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
