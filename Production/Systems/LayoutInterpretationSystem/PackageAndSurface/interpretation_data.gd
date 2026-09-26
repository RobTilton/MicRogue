class_name InterpretationData
extends RefCounted

const ORIGIN: String = "Production/Systems/LayoutInterpretationSystem/PackageAndSurface/interpretation_data.gd"

var map_data: MapData
var purpose: LayoutInterpretationSemantics.Purpose
var entrance_zone_id: int
var boss_zone_id: int
var coverage_ratio: float
var unzoned_floor: Array[Vector2i]

var _zone_id_by_cell: PackedInt32Array
var _zones_by_id: Dictionary = {}
var _unzoned_lookup: Dictionary = {}
var _claimed_floor_count: int = 0
var _floor_count: int = 0


static func create(source_map_data: MapData, result: PurposeCoverageResult) -> InterpretationData:
	var data := InterpretationData.new()
	data.map_data = source_map_data
	data.purpose = result.purpose
	data.entrance_zone_id = result.entrance_claim.id
	data.boss_zone_id = result.boss_claim.id
	data._floor_count = result.geometry.floor_coordinates.size()
	data._zone_id_by_cell.resize(source_map_data.cells.size())
	data._zone_id_by_cell.fill(0)
	for claim: AreaClaim in result.claim_state.get_claims():
		var zone := InterpretationZone.new(claim)
		data._zones_by_id[zone.id] = zone
		for coordinate: Vector2i in claim.cells:
			data._zone_id_by_cell[data._index_of(coordinate)] = zone.id
			data._claimed_floor_count += 1
	for coordinate: Vector2i in result.unzoned_floor:
		data._unzoned_lookup[coordinate] = true
	data._refresh_unzoned_floor()
	data._refresh_coverage()
	return data


func get_zone_id_at(coordinate: Vector2i) -> int:
	return _zone_id_by_cell[_index_of(coordinate)]


func get_zone_overlay() -> PackedInt32Array:
	return _zone_id_by_cell.duplicate()


func get_zone(zone_id: int) -> InterpretationZone:
	return _zones_by_id.get(zone_id)


func get_zone_ids() -> PackedInt32Array:
	var ids := PackedInt32Array()
	for zone_id: Variant in _zones_by_id:
		ids.append(int(zone_id))
	ids.sort()
	return ids


func reassign_cells(coordinates: Array[Vector2i], destination_zone_id: int) -> bool:
	if destination_zone_id != 0 and not _zones_by_id.has(destination_zone_id):
		push_error("%s: destination Zone %d does not exist." % [ORIGIN, destination_zone_id])
		return false
	var requested: Dictionary = {}
	for coordinate: Vector2i in coordinates:
		if requested.has(coordinate):
			continue
		if coordinate.x < 0 or coordinate.y < 0 or coordinate.x >= map_data.width or coordinate.y >= map_data.height:
			push_error("%s: reassignment coordinate %s is outside MapData." % [ORIGIN, coordinate])
			return false
		if map_data.cells[_index_of(coordinate)] != MapData.FLOOR:
			push_error("%s: reassignment coordinate %s is not floor." % [ORIGIN, coordinate])
			return false
		requested[coordinate] = true
	if requested.is_empty():
		return true
	var affected_zone_ids: Dictionary = {}
	var coordinates_by_zone: Dictionary = {}
	for coordinate: Variant in requested:
		var current_zone_id: int = get_zone_id_at(coordinate)
		if current_zone_id > 0:
			affected_zone_ids[current_zone_id] = true
	if destination_zone_id > 0:
		affected_zone_ids[destination_zone_id] = true
	for zone_id: Variant in affected_zone_ids:
		var lookup: Dictionary = {}
		var zone: InterpretationZone = _zones_by_id[int(zone_id)]
		for coordinate: Vector2i in zone.get_coordinates():
			lookup[coordinate] = true
		coordinates_by_zone[int(zone_id)] = lookup
	for coordinate: Variant in requested:
		var current_zone_id: int = get_zone_id_at(coordinate)
		if current_zone_id == destination_zone_id:
			continue
		if current_zone_id > 0:
			coordinates_by_zone[current_zone_id].erase(coordinate)
		else:
			_unzoned_lookup.erase(coordinate)
			_claimed_floor_count += 1
		if destination_zone_id > 0:
			coordinates_by_zone[destination_zone_id][coordinate] = true
		else:
			_unzoned_lookup[coordinate] = true
			_claimed_floor_count -= 1
		_zone_id_by_cell[_index_of(coordinate)] = destination_zone_id
	for zone_id: Variant in affected_zone_ids:
		var updated_coordinates: Array[Vector2i] = []
		for coordinate: Variant in coordinates_by_zone[int(zone_id)]:
			updated_coordinates.append(coordinate)
		var zone: InterpretationZone = _zones_by_id[int(zone_id)]
		zone._replace_coordinates(updated_coordinates)
	_refresh_unzoned_floor()
	_refresh_coverage()
	return true


func _index_of(coordinate: Vector2i) -> int:
	return coordinate.y * map_data.width + coordinate.x


func _refresh_unzoned_floor() -> void:
	unzoned_floor.clear()
	for coordinate: Variant in _unzoned_lookup:
		unzoned_floor.append(coordinate)
	unzoned_floor.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y < b.y or (a.y == b.y and a.x < b.x)
	)


func _refresh_coverage() -> void:
	coverage_ratio = float(_claimed_floor_count) / float(_floor_count) if _floor_count > 0 else 0.0
