class_name CaveBoundaryPlan
extends RefCounted

var centers: Array[Vector2i] = []
var circle_radius: int
var requested_circle_count: int
var starts_from_positive_side: bool
var primary_axis_is_horizontal: bool
var completed: bool
var noise_offsets: PackedInt32Array
var minimum_overlap_cells: int


func _init(
	resolved_centers: Array[Vector2i],
	resolved_circle_radius: int,
	resolved_requested_circle_count: int,
	resolved_starts_from_positive_side: bool,
	resolved_primary_axis_is_horizontal: bool,
	resolved_noise_offsets: PackedInt32Array = PackedInt32Array(),
	resolved_minimum_overlap_cells: int = 0
) -> void:
	centers = resolved_centers
	circle_radius = resolved_circle_radius
	requested_circle_count = resolved_requested_circle_count
	starts_from_positive_side = resolved_starts_from_positive_side
	primary_axis_is_horizontal = resolved_primary_axis_is_horizontal
	noise_offsets = resolved_noise_offsets
	minimum_overlap_cells = resolved_minimum_overlap_cells
	completed = centers.size() == requested_circle_count
