class_name LayoutRequest
extends RefCounted

var archetype: GenerationSemantics.Archetype
var scale: GenerationSemantics.Scale
var modifier: GenerationSemantics.GeometryModifier


func _init(
	requested_archetype: GenerationSemantics.Archetype = GenerationSemantics.Archetype.INVALID,
	requested_scale: GenerationSemantics.Scale = GenerationSemantics.Scale.INVALID,
	requested_modifier: GenerationSemantics.GeometryModifier = GenerationSemantics.GeometryModifier.INVALID
) -> void:
	archetype = requested_archetype
	scale = requested_scale
	modifier = requested_modifier
