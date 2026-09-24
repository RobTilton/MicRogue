class_name BaseGeometryGenerator
extends RefCounted

const ERROR_ORIGIN := (
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "BaseGeometryGenerator/base_geometry_generator.gd"
)


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
			return _failure(
				"Unsupported boundary strategy: %s. Cave compound-circle generation is pinned."
				% parameters.boundary_strategy
			)

	return BaseGeometryResolution.success(output)


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
	if parameters.boundary_strategy == GenerationSemantics.BoundaryStrategy.COMPOUND_CIRCLES:
		return _error("Cave compound-circle boundary generation is pinned and unsupported.")
	if parameters.boundary_strategy not in [
		GenerationSemantics.BoundaryStrategy.SQUARE,
		GenerationSemantics.BoundaryStrategy.CIRCLE,
	]:
		return _error("Unsupported boundary strategy: %s." % parameters.boundary_strategy)
	if parameters.raw_field_size.x <= 0 or parameters.raw_field_size.y <= 0:
		return _error("Raw field dimensions must be positive.")
	if parameters.output_size != Vector2i.ONE * (parameters.cut_window_radius * 2 + 1):
		return _error("Output size does not match cut-window radius.")
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
