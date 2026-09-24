class_name GenerationArchetypeProfile
extends Resource

@export var archetype: GenerationSemantics.Archetype = GenerationSemantics.Archetype.INVALID
@export var geometry_strategy: GenerationSemantics.GeometryStrategy = GenerationSemantics.GeometryStrategy.INVALID
@export_range(3, 256, 1) var base_min_radius: int = 4
@export_range(3, 256, 1) var base_max_radius: int = 12
@export_range(0, 32, 1) var radius_change_buffer: int = 0
@export_range(0.001, 1.0, 0.001) var base_tax_interval_ratio: float = 0.20
