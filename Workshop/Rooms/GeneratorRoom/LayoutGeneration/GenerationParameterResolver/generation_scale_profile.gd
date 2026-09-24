class_name GenerationScaleProfile
extends Resource

@export var scale: GenerationSemantics.Scale = GenerationSemantics.Scale.INVALID
@export var raw_field_size: Vector2i = Vector2i.ZERO
@export_range(1, 1024, 1) var cut_window_radius: int = 1
@export_range(1, 100000, 1) var room_count: int = 1
@export_range(-256, 256, 1) var max_radius_adjustment: int = 0
@export_range(0.001, 100.0, 0.001) var tax_interval_multiplier: float = 1.0
@export var room_count_is_provisional: bool = false
