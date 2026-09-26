class_name LayoutPurposeDefinition
extends RefCounted

var purpose: LayoutInterpretationSemantics.Purpose
var geometry_archetype: LayoutInterpretationSemantics.GeometryArchetype
var requirements: Array[LayoutAreaRequirement]


func _init(
	defined_purpose: LayoutInterpretationSemantics.Purpose,
	compatible_geometry_archetype: LayoutInterpretationSemantics.GeometryArchetype,
	ordered_requirements: Array[LayoutAreaRequirement]
) -> void:
	purpose = defined_purpose
	geometry_archetype = compatible_geometry_archetype
	requirements = []
	for requirement: LayoutAreaRequirement in ordered_requirements:
		requirements.append(requirement.duplicate_requirement())


func duplicate_definition() -> LayoutPurposeDefinition:
	return LayoutPurposeDefinition.new(purpose, geometry_archetype, requirements)
