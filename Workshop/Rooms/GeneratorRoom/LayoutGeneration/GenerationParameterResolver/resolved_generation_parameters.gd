class_name ResolvedGenerationParameters
extends RefCounted

var raw_field_size: Vector2i
var cut_window_radius: int
var output_size: Vector2i
var room_count: int
var geometry_strategy: GenerationSemantics.GeometryStrategy
var min_radius: int
var max_radius: int
var tax_interval: int
var room_count_is_provisional: bool


func _init(
	resolved_raw_field_size: Vector2i,
	resolved_cut_window_radius: int,
	resolved_room_count: int,
	resolved_geometry_strategy: GenerationSemantics.GeometryStrategy,
	resolved_min_radius: int,
	resolved_max_radius: int,
	resolved_tax_interval: int,
	resolved_room_count_is_provisional: bool
) -> void:
	raw_field_size = resolved_raw_field_size
	cut_window_radius = resolved_cut_window_radius
	var output_diameter: int = cut_window_radius * 2 + 1
	output_size = Vector2i(output_diameter, output_diameter)
	room_count = resolved_room_count
	geometry_strategy = resolved_geometry_strategy
	min_radius = resolved_min_radius
	max_radius = resolved_max_radius
	tax_interval = resolved_tax_interval
	room_count_is_provisional = resolved_room_count_is_provisional
