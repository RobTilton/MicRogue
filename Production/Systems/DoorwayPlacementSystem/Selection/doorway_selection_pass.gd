class_name DoorwaySelectionPass
extends RefCounted

const SNAPSHOT_RADIUS: int = 3
const SNAPSHOT_WIDTH: int = SNAPSHOT_RADIUS * 2 + 1
const MINIMUM_DOOR_DISTANCE: int = 3

# Canonical required-wall offsets normalized around each reference shape's floor opening.
# Matching derives every unique rotation and reflection. Unlisted snapshot cells are
# wildcards; passage floors are established by the gate.
const CANONICAL_VALID_GEOMETRY: Array[Array] = [
	[
		Vector2i(-2, -2), Vector2i(2, -2),
		Vector2i(-2, -1), Vector2i(2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0),
	],
	[
		Vector2i(-2, -2), Vector2i(-2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0),
	],
	[
		Vector2i(2, -2), Vector2i(2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-2, 1), Vector2i(-2, 2),
	],
	[
		Vector2i(3, -2), Vector2i(3, -1),
		Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-1, 1), Vector2i(-1, 2),
	],
	[
		Vector2i(1, -2), Vector2i(1, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0),
		Vector2i(-3, 1), Vector2i(-3, 2),
	],
	[
		Vector2i(-3, -2), Vector2i(1, -2),
		Vector2i(-3, -1), Vector2i(1, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0),
	],
	[
		Vector2i(-1, -2), Vector2i(3, -2),
		Vector2i(-1, -1), Vector2i(3, -1),
		Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
	],
	[
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0),
	],
	[
		Vector2i(-2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-2, 1),
	],
]

static var _valid_geometry_variants: Array[Array] = []


static func run(map_data: MapData) -> Array[DoorwayPlacement]:
	var selected: Array[DoorwayPlacement] = []
	var last_door := Vector2i.ZERO
	var has_last_door: bool = false
	for y: int in range(SNAPSHOT_RADIUS, map_data.height - SNAPSHOT_RADIUS):
		for x: int in range(SNAPSHOT_RADIUS, map_data.width - SNAPSHOT_RADIUS):
			var coordinate := Vector2i(x, y)
			if map_data.get_cell(coordinate) != MapData.FLOOR:
				continue
			var orientation: int = _gate_orientation(map_data, coordinate)
			if orientation < 0:
				continue
			if has_last_door and _manhattan_distance(coordinate, last_door) < MINIMUM_DOOR_DISTANCE:
				continue
			var snapshot: PackedInt32Array = _capture_snapshot(map_data, coordinate)
			if not _matches_valid_geometry(snapshot):
				continue
			selected.append(DoorwayPlacement.new(coordinate, orientation))
			last_door = coordinate
			has_last_door = true
	return selected


static func _gate_orientation(map_data: MapData, coordinate: Vector2i) -> int:
	var left: int = map_data.get_cell(coordinate + Vector2i.LEFT)
	var right: int = map_data.get_cell(coordinate + Vector2i.RIGHT)
	var up: int = map_data.get_cell(coordinate + Vector2i.UP)
	var down: int = map_data.get_cell(coordinate + Vector2i.DOWN)
	if left != right or up != down or left == up:
		return -1
	if left == MapData.WALL and up == MapData.FLOOR:
		return DoorwayPlacement.WallOrientation.HORIZONTAL
	if left == MapData.FLOOR and up == MapData.WALL:
		return DoorwayPlacement.WallOrientation.VERTICAL
	return -1


static func _capture_snapshot(
	map_data: MapData,
	center: Vector2i
) -> PackedInt32Array:
	var snapshot := PackedInt32Array()
	snapshot.resize(SNAPSHOT_WIDTH * SNAPSHOT_WIDTH)
	var write_index: int = 0
	for offset_y: int in range(-SNAPSHOT_RADIUS, SNAPSHOT_RADIUS + 1):
		for offset_x: int in range(-SNAPSHOT_RADIUS, SNAPSHOT_RADIUS + 1):
			snapshot[write_index] = map_data.get_cell(center + Vector2i(offset_x, offset_y))
			write_index += 1
	return snapshot


static func _matches_valid_geometry(snapshot: PackedInt32Array) -> bool:
	for required_walls: Array in _get_valid_geometry_variants():
		var matches: bool = true
		for offset: Vector2i in required_walls:
			if _snapshot_cell(snapshot, offset) != MapData.WALL:
				matches = false
				break
		if matches:
			return true
	return false


static func _get_valid_geometry_variants() -> Array[Array]:
	if not _valid_geometry_variants.is_empty():
		return _valid_geometry_variants
	var seen: Dictionary = {}
	for canonical_pattern: Array in CANONICAL_VALID_GEOMETRY:
		for mirror_index: int in range(2):
			var transformed: Array[Vector2i] = []
			for canonical_offset: Vector2i in canonical_pattern:
				var offset: Vector2i = canonical_offset
				if mirror_index == 1:
					offset.x = -offset.x
				transformed.append(offset)
			for _rotation_index: int in range(4):
				var key: String = _geometry_key(transformed)
				if not seen.has(key):
					seen[key] = true
					_valid_geometry_variants.append(transformed.duplicate())
				for offset_index: int in range(transformed.size()):
					var offset: Vector2i = transformed[offset_index]
					transformed[offset_index] = Vector2i(-offset.y, offset.x)
	return _valid_geometry_variants


static func _geometry_key(offsets: Array[Vector2i]) -> String:
	var ordered: Array[Vector2i] = offsets.duplicate()
	ordered.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y < b.y or (a.y == b.y and a.x < b.x)
	)
	var key: String = ""
	for offset: Vector2i in ordered:
		key += "%d,%d;" % [offset.x, offset.y]
	return key


static func _snapshot_cell(snapshot: PackedInt32Array, offset: Vector2i) -> int:
	var x: int = offset.x + SNAPSHOT_RADIUS
	var y: int = offset.y + SNAPSHOT_RADIUS
	return snapshot[y * SNAPSHOT_WIDTH + x]


static func _manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
