class_name GenerationModifierProfile
extends Resource

@export var modifier: GenerationSemantics.GeometryModifier = GenerationSemantics.GeometryModifier.INVALID
@export_range(-256, 256, 1) var radius_adjustment: int = 0
@export_range(0.001, 100.0, 0.001) var tax_interval_multiplier: float = 1.0
