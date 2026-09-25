class_name BaseGeometryGenerator
extends RefCounted

const ERROR_ORIGIN := "MapGenerationSystem/BaseGeometryGenerator"
const CAVE_OVERLAP_RATIO := 0.20
const CAVE_MAX_NOISE_OFFSET := 3
const CAVE_BOUNDING_MARGIN := 1
const CaveBoundaryPlanType = preload("cave_boundary_plan.gd")


static func generate(
	parameters: ResolvedGenerationParameters
) -> BaseGeometryResolution:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return generate_with_rng(parameters, rng)


static func generate_with_rng(
	parameters: ResolvedGenerationParameters,
	rng: RandomNumberGenerator
) -> BaseGeometryResolution:
	var validation_error := _validate_input(parameters, rng)
	if not validation_error.is_empty():
		return BaseGeometryResolution.failure(validation_error)

	var raw_field := _create_empty_field(parameters.raw_field_size)
	_generate_rectangular_rooms(raw_field, parameters, rng)
	return _cut_and_wrap(raw_field, parameters, rng)


static func _generate_rectangular_rooms(
	field: GeometryField,
	parameters: ResolvedGenerationParameters,
	rng: RandomNumberGenerator
) -> void:
	for room_index in range(parameters.room_count):
		var current_max_radius: int = taxed_max_radius_for_room(
			parameters,
			room_index
		)
		var radius_x: int = rng.randi_range(
			parameters.min_radius,
			current_max_radius
		)
		var radius_y: int = rng.randi_range(
			parameters.min_radius,
			current_max_radius
		)
		_stamp_rectangular_room(field, radius_x, radius_y, rng)


static func taxed_max_radius_for_room(
	parameters: ResolvedGenerationParameters,
	room_index: int
) -> int:
	var completed_tax_intervals: int = room_index / parameters.tax_interval
	return max(
		parameters.min_radius,
		parameters.max_radius - completed_tax_intervals
	)


static func _stamp_rectangular_room(
	field: GeometryField,
	radius_x: int,
	radius_y: int,
	rng: RandomNumberGenerator
) -> void:
	var extent_x: int = radius_x - 1
	var extent_y: int = radius_y - 1
	var origin := Vector2i(
		rng.randi_range(extent_x, field.size.x - extent_x - 1),
		rng.randi_range(extent_y, field.size.y - extent_y - 1)
	)

	for y in range(origin.y - extent_y, origin.y + extent_y + 1):
		for x in range(origin.x - extent_x, origin.x + extent_x + 1):
			var is_wall: bool = (
			x == origin.x - extent_x
			or x == origin.x + extent_x
			or y == origin.y - extent_y
			or y == origin.y + extent_y
			)
			field.set_cell(
				Vector2i(x, y),
				GeometryField.WALL if is_wall else GeometryField.FLOOR
			)


static func _cut_and_wrap(
	raw_field: GeometryField,
	parameters: ResolvedGenerationParameters,
	rng: RandomNumberGenerator
) -> BaseGeometryResolution:
	if parameters.boundary_strategy == GenerationSemantics.BoundaryStrategy.COMPOUND_CIRCLES:
		return _cut_and_wrap_cave(raw_field, parameters, rng)

	var radius: int = parameters.cut_window_radius
	var minimum_center := Vector2i(radius + 1, radius + 1)
	var maximum_center := Vector2i(
		raw_field.size.x - radius - 2,
		raw_field.size.y - radius - 2
	)
	if minimum_center.x > maximum_center.x or minimum_center.y > maximum_center.y:
		return _failure("Cut window and required margin do not fit the raw field.")

	var center := Vector2i(
		rng.randi_range(minimum_center.x, maximum_center.x),
		rng.randi_range(minimum_center.y, maximum_center.y)
	)
	var output_size := parameters.output_size
	var output_cells := PackedInt32Array()
	output_cells.resize(output_size.x * output_size.y)
	output_cells.fill(GeometryField.VOID)
	var output := GeometryField.new(output_size, output_cells)

	for y in range(output_size.y):
		for x in range(output_size.x):
			var source_position := Vector2i(
				center.x - radius + x,
				center.y - radius + y
			)
			output.set_cell(Vector2i(x, y), raw_field.get_cell(source_position))

	match parameters.boundary_strategy:
		GenerationSemantics.BoundaryStrategy.SQUARE:
			_wrap_square(output)
		GenerationSemantics.BoundaryStrategy.CIRCLE:
			_wrap_circle(output, radius)
		_:
			return _failure("Unsupported boundary strategy: %s." % parameters.boundary_strategy)

	return BaseGeometryResolution.success(output)


static func plan_cave_boundary(
	parameters: ResolvedGenerationParameters,
	rng: RandomNumberGenerator
):
	var circle_radius: int = parameters.cut_window_radius / 2
	var requested_count: int = _cave_circle_count(parameters.cut_window_radius)
	var horizontal: bool = parameters.raw_field_size.x >= parameters.raw_field_size.y
	var positive_side: bool = rng.randi_range(0, 1) == 1
	var safe_min := Vector2i(circle_radius + CAVE_BOUNDING_MARGIN, circle_radius + CAVE_BOUNDING_MARGIN)
	var safe_max := parameters.raw_field_size - safe_min - Vector2i.ONE
	var start := Vector2i.ZERO
	if horizontal:
		start.x = safe_max.x if positive_side else safe_min.x
		start.y = rng.randi_range(safe_min.y, safe_max.y)
	else:
		start.x = rng.randi_range(safe_min.x, safe_max.x)
		start.y = safe_max.y if positive_side else safe_min.y

	var field_center := Vector2(parameters.raw_field_size - Vector2i.ONE) * 0.5
	var travel := field_center - Vector2(start)
	if travel.is_zero_approx():
		travel = Vector2.LEFT if horizontal else Vector2.UP
	travel = travel.normalized()
	var perpendicular := Vector2(-travel.y, travel.x)
	var overlap_cells: int = ceili(float(circle_radius * 2 + 1) * CAVE_OVERLAP_RATIO)
	var maximum_center_distance: int = circle_radius * 2 + 1 - overlap_cells
	# Reserve one cell of longitudinal distance for each perpendicular noise step.
	var center_step: int = max(1, maximum_center_distance - 1)
	var centers: Array[Vector2i] = [start]
	var noise_offset: int = 0
	var noise_offsets := PackedInt32Array([0])

	for circle_index in range(1, requested_count):
		var base_center := Vector2(start) + travel * float(center_step * circle_index)
		var proposed_offset: int = clampi(
			noise_offset + rng.randi_range(-1, 1),
			-CAVE_MAX_NOISE_OFFSET,
			CAVE_MAX_NOISE_OFFSET
		)
		var placed := false
		for candidate_offset: int in [proposed_offset, noise_offset]:
			var noisy_center := base_center + perpendicular * float(candidate_offset)
			var candidate := Vector2i(roundi(noisy_center.x), roundi(noisy_center.y))
			if not _cave_center_is_safe(candidate, safe_min, safe_max):
				continue
			if not _cave_centers_overlap(centers[-1], candidate, maximum_center_distance):
				continue
			centers.append(candidate)
			noise_offset = candidate_offset
			noise_offsets.append(candidate_offset)
			placed = true
			break
		if not placed:
			break

	return CaveBoundaryPlanType.new(
		centers,
		circle_radius,
		requested_count,
		positive_side,
		horizontal,
		noise_offsets,
		overlap_cells
	)


static func _cut_and_wrap_cave(
	raw_field: GeometryField,
	parameters: ResolvedGenerationParameters,
	rng: RandomNumberGenerator
) -> BaseGeometryResolution:
	var plan: RefCounted = plan_cave_boundary(parameters, rng)
	if plan.centers.is_empty():
		return _failure("Cave boundary planning produced no valid circles.")
	return cut_and_wrap_cave_from_plan(raw_field, plan)


static func cut_and_wrap_cave_from_plan(
	raw_field: GeometryField,
	plan
) -> BaseGeometryResolution:
	if raw_field == null or plan == null or plan.centers.is_empty():
		return _failure("Cave wrapping requires a raw field and at least one valid circle.")

	var minimum: Vector2i = plan.centers[0] - Vector2i.ONE * plan.circle_radius
	var maximum: Vector2i = plan.centers[0] + Vector2i.ONE * plan.circle_radius
	for center in plan.centers:
		minimum.x = mini(minimum.x, center.x - plan.circle_radius)
		minimum.y = mini(minimum.y, center.y - plan.circle_radius)
		maximum.x = maxi(maximum.x, center.x + plan.circle_radius)
		maximum.y = maxi(maximum.y, center.y + plan.circle_radius)
	minimum -= Vector2i.ONE * CAVE_BOUNDING_MARGIN
	maximum += Vector2i.ONE * CAVE_BOUNDING_MARGIN

	var output := _create_empty_field(maximum - minimum + Vector2i.ONE)
	for y in range(output.size.y):
		for x in range(output.size.x):
			var output_position := Vector2i(x, y)
			var source_position: Vector2i = minimum + output_position
			if not _inside_cave_union(source_position, plan):
				output.set_cell(output_position, GeometryField.WALL)
			elif _touches_outside_cave_union(source_position, plan):
				output.set_cell(output_position, GeometryField.WALL)
			else:
				var source_value: int = raw_field.get_cell(source_position)
				output.set_cell(
					output_position,
					GeometryField.WALL if source_value == GeometryField.VOID else source_value
				)
	return BaseGeometryResolution.success(output)


static func _cave_circle_count(cut_window_radius: int) -> int:
	match cut_window_radius:
		10:
			return 4
		15:
			return 5
		20:
			return 6
		_:
			return 0


static func _cave_center_is_safe(
	center: Vector2i,
	safe_min: Vector2i,
	safe_max: Vector2i
) -> bool:
	return (
		center.x >= safe_min.x
		and center.y >= safe_min.y
		and center.x <= safe_max.x
		and center.y <= safe_max.y
	)


static func _cave_centers_overlap(
	first: Vector2i,
	second: Vector2i,
	maximum_center_distance: int
) -> bool:
	return first.distance_squared_to(second) <= maximum_center_distance * maximum_center_distance


static func _inside_cave_union(position: Vector2i, plan) -> bool:
	for center in plan.centers:
		if position.distance_squared_to(center) <= plan.circle_radius * plan.circle_radius:
			return true
	return false


static func _touches_outside_cave_union(position: Vector2i, plan) -> bool:
	for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if not _inside_cave_union(position + offset, plan):
			return true
	return false


static func _wrap_square(field: GeometryField) -> void:
	for x in range(field.size.x):
		field.set_cell(Vector2i(x, 0), GeometryField.WALL)
		field.set_cell(Vector2i(x, field.size.y - 1), GeometryField.WALL)
	for y in range(field.size.y):
		field.set_cell(Vector2i(0, y), GeometryField.WALL)
		field.set_cell(Vector2i(field.size.x - 1, y), GeometryField.WALL)


static func _wrap_circle(field: GeometryField, radius: int) -> void:
	var center := Vector2i(radius, radius)
	for y in range(field.size.y):
		for x in range(field.size.x):
			var position := Vector2i(x, y)
			var offset := position - center
			if offset.length_squared() > radius * radius:
				field.set_cell(position, GeometryField.VOID)
			elif _touches_outside_circle(offset, radius):
				field.set_cell(position, GeometryField.WALL)


static func _touches_outside_circle(offset: Vector2i, radius: int) -> bool:
	for neighbor_offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var neighbor: Vector2i = offset + neighbor_offset
		if neighbor.length_squared() > radius * radius:
			return true
	return false


static func _create_empty_field(size: Vector2i) -> GeometryField:
	var cells := PackedInt32Array()
	cells.resize(size.x * size.y)
	cells.fill(GeometryField.VOID)
	return GeometryField.new(size, cells)


static func _validate_input(
	parameters: ResolvedGenerationParameters,
	rng: RandomNumberGenerator
) -> String:
	if parameters == null:
		return _error("Resolved generation parameters are required.")
	if rng == null:
		return _error("Random number generator is required.")
	if parameters.geometry_strategy != GenerationSemantics.GeometryStrategy.RECTANGULAR_ROOMS:
		return _error("Unsupported geometry strategy: %s." % parameters.geometry_strategy)
	if parameters.boundary_strategy not in [
		GenerationSemantics.BoundaryStrategy.SQUARE,
		GenerationSemantics.BoundaryStrategy.CIRCLE,
		GenerationSemantics.BoundaryStrategy.COMPOUND_CIRCLES,
	]:
		return _error("Unsupported boundary strategy: %s." % parameters.boundary_strategy)
	if parameters.raw_field_size.x <= 0 or parameters.raw_field_size.y <= 0:
		return _error("Raw field dimensions must be positive.")
	if parameters.output_size != Vector2i.ONE * (parameters.cut_window_radius * 2 + 1):
		return _error("Output size does not match cut-window radius.")
	if (
		parameters.boundary_strategy == GenerationSemantics.BoundaryStrategy.COMPOUND_CIRCLES
		and _cave_circle_count(parameters.cut_window_radius) == 0
	):
		return _error("Cave boundary has no circle-count contract for this cut-window radius.")
	if parameters.room_count <= 0:
		return _error("Room count must be positive.")
	if parameters.min_radius < 3:
		return _error("Minimum room radius must be at least 3.")
	if parameters.max_radius < parameters.min_radius:
		return _error("Maximum room radius is below minimum room radius.")
	if parameters.tax_interval <= 0:
		return _error("Tax interval must be positive.")
	var maximum_extent: int = parameters.max_radius - 1
	if maximum_extent * 2 + 1 > parameters.raw_field_size.x:
		return _error("Maximum room width does not fit the raw field.")
	if maximum_extent * 2 + 1 > parameters.raw_field_size.y:
		return _error("Maximum room height does not fit the raw field.")
	return ""


static func _failure(message: String) -> BaseGeometryResolution:
	return BaseGeometryResolution.failure(_error(message))


static func _error(message: String) -> String:
	return "%s: %s" % [ERROR_ORIGIN, message]
