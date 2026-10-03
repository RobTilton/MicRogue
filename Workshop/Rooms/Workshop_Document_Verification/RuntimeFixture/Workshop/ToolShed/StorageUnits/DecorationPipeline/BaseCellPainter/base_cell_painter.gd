class_name BaseCellPainter
extends RefCounted

const ORIGIN := "res://Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/base_cell_painter.gd"
const MapData := preload("res://Production/Systems/RapidRoomGenerationSystem/rapid_room_map_data.gd")
const Result := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/ResultContract/decorated_map_data.gd")
const Context := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/decoration_cell_context.gd")
const Plan := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/decoration_paint_plan.gd")
const CARDINAL := [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const DIAGONAL := [Vector2i(-1,-1), Vector2i(1,-1), Vector2i(1,1), Vector2i(-1,1)]

static func paint(source: MapData, seed: int) -> RefCounted:
	var error := Result.validate_source(source)
	if not error.is_empty(): push_error("%s: %s" % [ORIGIN, error]); return null
	var side := int(sqrt(float(source.cells.size())))
	var owners: Dictionary = {}; var doors: Dictionary = {}; var footprints: Dictionary = {}
	for room: RapidRoom in source.rooms:
		for coordinate: Vector2i in room.floor_coordinates: owners[coordinate] = room
	for doorway: RapidRoomDoorway in source.doorways:
		doors[doorway.position] = true
		for y in range(doorway.footprint_center.y - 1, doorway.footprint_center.y + 2):
			for x in range(doorway.footprint_center.x - 1, doorway.footprint_center.x + 2): footprints[Vector2i(x,y)] = true
	var planned: Array[Context] = []
	for index in range(source.cells.size()):
		var coordinate := Vector2i(index % side, index / side); var physical: int = source.cells[index]
		var cardinal := _mask(source.cells, side, coordinate, physical, CARDINAL)
		var diagonal := _mask(source.cells, side, coordinate, physical, DIAGONAL)
		var topology := _topology(cardinal, diagonal)
		var owner: RapidRoom = owners.get(coordinate)
		var door := doors.has(coordinate); var footprint := footprints.has(coordinate)
		var role := &"door_position" if door else (&"doorway_floor" if footprint and physical == MapData.FLOOR else StringName(("floor_" if physical == MapData.FLOOR else "wall_") + Context.Topology.keys()[topology].to_lower()))
		planned.append(Context.new({"coordinate":coordinate,"physical_cell":physical,"role":role,"topology":topology,"cardinal_mask":cardinal,"diagonal_mask":diagonal,"room_id":owner.id if owner != null else -1,"room_type":owner.room_type if owner != null else &"","room_tags":owner.tags if owner != null else [],"is_door_position":door,"is_doorway_footprint":footprint,"variant_key":hash([seed,index,role]) & 0x7fffffff}))
	return Plan.new(side, planned)

static func _mask(cells: PackedInt32Array, side: int, at: Vector2i, physical: int, offsets: Array) -> int:
	var mask := 0
	for index in range(offsets.size()):
		var point: Vector2i = at + offsets[index]
		if point.x >= 0 and point.y >= 0 and point.x < side and point.y < side and cells[point.y * side + point.x] == physical: mask |= 1 << index
	return mask

static func _topology(cardinal: int, diagonal: int) -> Context.Topology:
	var count := 0
	for bit in range(4): count += 1 if cardinal & (1 << bit) else 0
	if cardinal == 15:
		if diagonal == 15: return Context.Topology.INTERIOR
		if count == 4 and [14,13,11,7].has(diagonal): return Context.Topology.INNER_CORNER
		return Context.Topology.SURROUNDED
	if count == 0: return Context.Topology.ISOLATED
	if count == 3: return Context.Topology.EDGE
	if count == 2 and cardinal in [3,6,12,9]: return Context.Topology.OUTER_CORNER
	return Context.Topology.IRREGULAR
