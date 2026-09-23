class_name DungenGeneratorFrontier

extends RefCounted

# Cell values
const VOID: int = 0
const FLOOR: int = 1
const WALL: int = 2

const CROSS_SHAPE: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]


static func generate_dungeon(
	width: int,
	height: int,
	rooms_per_run: int,
	room_min_radius_x: int,
	room_max_radius_x: int,
	room_min_radius_y: int,
	room_max_radius_y: int,
	seed_value: int
) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var cells := PackedInt32Array()
	cells.resize(width * height)
	cells.fill(VOID)

	for iteration: int in range(rooms_per_run):
		var max_radius_x: int = max(
			room_min_radius_x,
			room_max_radius_x - iteration
		)
		var max_radius_y: int = max(
			room_min_radius_y,
			room_max_radius_y - iteration
		)

		var radius_x: int = rng.randi_range(
			room_min_radius_x,
			max_radius_x
		)
		var radius_y: int = rng.randi_range(
			room_min_radius_y,
			max_radius_y
		)

		var origin_x: int = rng.randi_range(
			radius_x,
			width - radius_x - 1
		)
		var origin_y: int = rng.randi_range(
			radius_y,
			height - radius_y - 1
		)

		_generate_room(
			cells,
			width,
			height,
			origin_x,
			origin_y,
			radius_x,
			radius_y
		)

	var raw_dungeon: Dictionary = {
	"width": width,
	"height": height,
	"cells": cells,
	"seed": seed_value,
}

	var repaired_result: Dictionary = repair_with_cross(raw_dungeon)

	return repaired_result["field"]


static func crop_window(
	source: Dictionary,
	origin: Vector2i,
	size: Vector2i
) -> Dictionary:
	var source_width: int = source["width"]
	var source_height: int = source["height"]
	var source_cells: PackedInt32Array = source["cells"]

	assert(origin.x >= 0)
	assert(origin.y >= 0)
	assert(origin.x + size.x <= source_width)
	assert(origin.y + size.y <= source_height)

	var cells := PackedInt32Array()
	cells.resize(size.x * size.y)
	cells.fill(VOID)

	for y: int in range(size.y):
		for x: int in range(size.x):
			var source_x := origin.x + x
			var source_y := origin.y + y

			cells[_index(x, y, size.x)] = source_cells[
				_index(source_x, source_y, source_width)
			]

	return {
		"width": size.x,
		"height": size.y,
		"cells": cells,
		"source_origin": origin,
		"source_seed": source.get("seed", 0),
	}


static func seal_boundary(field: Dictionary) -> void:
	var width: int = field["width"]
	var height: int = field["height"]
	var cells: PackedInt32Array = field["cells"]

	for x: int in range(width):
		cells[_index(x, 0, width)] = WALL
		cells[_index(x, height - 1, width)] = WALL

	for y: int in range(height):
		cells[_index(0, y, width)] = WALL
		cells[_index(width - 1, y, width)] = WALL


static func repair_with_cross(field: Dictionary) -> Dictionary:
	return repair_with_shape(field, CROSS_SHAPE)


static func repair_with_shape(
	field: Dictionary,
	shape: Array[Vector2i]
) -> Dictionary:
	var repaired := _copy_field(field)
	var original_regions: Array = find_floor_regions(field)
	var labels: PackedInt32Array = _build_region_labels(
		field,
		original_regions
	)

	var chosen_centers := {}
	var stamps: int = 0
	var mutated_cells: int = 0
	var regions_with_candidate: int = 0

	for region_id: int in range(original_regions.size()):
		var region: Array = original_regions[region_id]
		var choice: Dictionary = _choose_stamp_for_region(
			field,
			labels,
			region_id,
			region,
			shape
		)

		if choice.is_empty():
			continue

		regions_with_candidate += 1
		var center: Vector2i = choice["center"]

		if chosen_centers.has(center):
			continue

		chosen_centers[center] = true
		stamps += 1
		mutated_cells += _apply_stamp(
			repaired,
			center,
			shape
		)

	return {
		"field": repaired,
		"stamps": stamps,
		"mutated_cells": mutated_cells,
		"regions_with_candidate": regions_with_candidate,
		"regions_without_candidate": (
			original_regions.size() - regions_with_candidate
		),
	}


static func keep_largest_region(field: Dictionary) -> Dictionary:
	var result := _copy_field(field)
	var regions: Array = find_floor_regions(result)

	if regions.is_empty():
		return result

	var largest_region: Array = regions[0]

	for region: Array in regions:
		if region.size() > largest_region.size():
			largest_region = region

	var keep := {}
	for cell: Vector2i in largest_region:
		keep[cell] = true

	var width: int = result["width"]
	var height: int = result["height"]
	var cells: PackedInt32Array = result["cells"]

	for y: int in range(height):
		for x: int in range(width):
			var idx := _index(x, y, width)

			if cells[idx] == FLOOR and not keep.has(Vector2i(x, y)):
				cells[idx] = WALL

	return result


static func find_floor_regions(field: Dictionary) -> Array:
	var width: int = field["width"]
	var height: int = field["height"]
	var cells: PackedInt32Array = field["cells"]

	var visited := PackedByteArray()
	visited.resize(width * height)
	visited.fill(0)

	var regions: Array = []

	for y: int in range(height):
		for x: int in range(width):
			var idx := _index(x, y, width)

			if cells[idx] != FLOOR:
				continue
			if visited[idx] == 1:
				continue

			regions.append(
				_flood_fill(
					field,
					Vector2i(x, y),
					visited
				)
			)

	return regions


static func field_to_ascii(field: Dictionary) -> String:
	var width: int = field["width"]
	var height: int = field["height"]
	var cells: PackedInt32Array = field["cells"]

	var lines: PackedStringArray = []

	for y: int in range(height):
		var line := ""

		for x: int in range(width):
			match cells[_index(x, y, width)]:
				VOID:
					line += "0"
				FLOOR:
					line += "."
				WALL:
					line += "#"
				_:
					line += "?"

		lines.append(line)

	return "\n".join(lines)


static func _generate_room(
	cells: PackedInt32Array,
	width: int,
	height: int,
	origin_x: int,
	origin_y: int,
	radius_x: int,
	radius_y: int
) -> void:
	for y: int in range(
		origin_y - radius_y,
		origin_y + radius_y + 1
	):
		for x: int in range(
			origin_x - radius_x,
			origin_x + radius_x + 1
		):
			if x < 0 or x >= width:
				continue
			if y < 0 or y >= height:
				continue
				
			var distance_x: int = absi(x - origin_x)
			var distance_y: int = absi(y - origin_y)
			
			if distance_x == radius_x or distance_y == radius_y:
				cells[_index(x, y, width)] = WALL
			else:
				cells[_index(x, y, width)] = FLOOR


static func _flood_fill(
	field: Dictionary,
	start: Vector2i,
	visited: PackedByteArray
) -> Array:
	var width: int = field["width"]
	var height: int = field["height"]
	var cells: PackedInt32Array = field["cells"]

	var region: Array[Vector2i] = []
	var queue: Array[Vector2i] = [start]
	var head: int = 0

	visited[_index(start.x, start.y, width)] = 1

	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		region.append(current)

		for neighbor: Vector2i in _cardinal_neighbors(current):
			if neighbor.x < 0 or neighbor.x >= width:
				continue
			if neighbor.y < 0 or neighbor.y >= height:
				continue

			var idx := _index(neighbor.x, neighbor.y, width)

			if cells[idx] != FLOOR:
				continue
			if visited[idx] == 1:
				continue

			visited[idx] = 1
			queue.append(neighbor)

	return region


static func _build_region_labels(
	field: Dictionary,
	regions: Array
) -> PackedInt32Array:
	var width: int = field["width"]
	var height: int = field["height"]

	var labels := PackedInt32Array()
	labels.resize(width * height)
	labels.fill(-1)

	for region_id: int in range(regions.size()):
		var region: Array = regions[region_id]

		for cell: Vector2i in region:
			labels[_index(cell.x, cell.y, width)] = region_id

	return labels


static func _region_frontier_walls(
	field: Dictionary,
	region: Array
) -> Array[Vector2i]:
	var width: int = field["width"]
	var height: int = field["height"]
	var cells: PackedInt32Array = field["cells"]

	var walls := {}

	for cell: Vector2i in region:
		for neighbor: Vector2i in _cardinal_neighbors(cell):
			if neighbor.x < 0 or neighbor.x >= width:
				continue
			if neighbor.y < 0 or neighbor.y >= height:
				continue

			if cells[_index(neighbor.x, neighbor.y, width)] == WALL:
				walls[neighbor] = true

	var result: Array[Vector2i] = []
	for wall: Vector2i in walls.keys():
		result.append(wall)

	return result


static func _regions_touched_by_stamp(
	field: Dictionary,
	labels: PackedInt32Array,
	center: Vector2i,
	shape: Array[Vector2i]
) -> Dictionary:
	var width: int = field["width"]
	var height: int = field["height"]
	var touched := {}

	for offset: Vector2i in shape:
		var cell := center + offset

		if cell.x < 0 or cell.x >= width:
			continue
		if cell.y < 0 or cell.y >= height:
			continue

		var region_id := labels[_index(cell.x, cell.y, width)]

		if region_id != -1:
			touched[region_id] = true

		for neighbor: Vector2i in _cardinal_neighbors(cell):
			if neighbor.x < 0 or neighbor.x >= width:
				continue
			if neighbor.y < 0 or neighbor.y >= height:
				continue

			region_id = labels[_index(neighbor.x, neighbor.y, width)]

			if region_id != -1:
				touched[region_id] = true

	return touched


static func _choose_stamp_for_region(
	field: Dictionary,
	labels: PackedInt32Array,
	region_id: int,
	region: Array,
	shape: Array[Vector2i]
) -> Dictionary:
	var width: int = field["width"]
	var height: int = field["height"]
	var cells: PackedInt32Array = field["cells"]

	var best: Dictionary = {}

	for center: Vector2i in _region_frontier_walls(field, region):
		var touched := _regions_touched_by_stamp(
			field,
			labels,
			center,
			shape
		)

		if not touched.has(region_id) or touched.size() < 2:
			continue

		var destroyed: int = 0
		var void_destroyed: int = 0

		for offset: Vector2i in shape:
			var cell := center + offset

			if cell.x < 0 or cell.x >= width:
				continue
			if cell.y < 0 or cell.y >= height:
				continue

			var value := cells[_index(cell.x, cell.y, width)]

			if value != FLOOR:
				destroyed += 1
			if value == VOID:
				void_destroyed += 1

		var score := Vector4i(
			-touched.size(),
			void_destroyed,
			destroyed,
			center.y
		)

		if best.is_empty():
			best = {
				"score": score,
				"center_x": center.x,
				"center": center,
			}
			continue

		var best_score: Vector4i = best["score"]

		if _score_is_better(
			score,
			center.x,
			best_score,
			best["center_x"]
		):
			best = {
				"score": score,
				"center_x": center.x,
				"center": center,
			}

	return best


static func _score_is_better(
	score: Vector4i,
	score_x: int,
	best_score: Vector4i,
	best_x: int
) -> bool:
	if score.x != best_score.x:
		return score.x < best_score.x
	if score.y != best_score.y:
		return score.y < best_score.y
	if score.z != best_score.z:
		return score.z < best_score.z
	if score.w != best_score.w:
		return score.w < best_score.w

	return score_x < best_x


static func _apply_stamp(
	field: Dictionary,
	center: Vector2i,
	shape: Array[Vector2i]
) -> int:
	var width: int = field["width"]
	var height: int = field["height"]
	var cells: PackedInt32Array = field["cells"]

	var mutated: int = 0

	for offset: Vector2i in shape:
		var cell := center + offset

		if cell.x < 0 or cell.x >= width:
			continue
		if cell.y < 0 or cell.y >= height:
			continue

		var idx := _index(cell.x, cell.y, width)

		if cells[idx] != FLOOR:
			mutated += 1
			cells[idx] = FLOOR

	return mutated


static func _copy_field(field: Dictionary) -> Dictionary:
	return {
		"width": field["width"],
		"height": field["height"],
		"cells": field["cells"].duplicate(),
		"seed": field.get("seed", 0),
	}


static func _cardinal_neighbors(cell: Vector2i) -> Array[Vector2i]:
	return [
		cell + Vector2i.RIGHT,
		cell + Vector2i.LEFT,
		cell + Vector2i.DOWN,
		cell + Vector2i.UP,
	]


static func _index(x: int, y: int, width: int) -> int:
	return y * width + x
