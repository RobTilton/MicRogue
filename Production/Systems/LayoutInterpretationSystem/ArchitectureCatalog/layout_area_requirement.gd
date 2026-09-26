class_name LayoutAreaRequirement
extends RefCounted

var id: StringName
var area_role: LayoutInterpretationSemantics.AreaRole
var minimum_count: int
var maximum_count: int
var relationship_kind: LayoutInterpretationSemantics.RelationshipKind
var relationship_strength: LayoutInterpretationSemantics.RelationshipStrength
var target_area_role: LayoutInterpretationSemantics.AreaRole
var target_requirement_id: StringName
var progression_targets_percent: PackedInt32Array


func _init(
	requirement_id: StringName,
	required_area_role: LayoutInterpretationSemantics.AreaRole,
	required_minimum_count: int = 1,
	required_maximum_count: int = 1,
	required_relationship_kind: LayoutInterpretationSemantics.RelationshipKind = LayoutInterpretationSemantics.RelationshipKind.NONE,
	required_relationship_strength: LayoutInterpretationSemantics.RelationshipStrength = LayoutInterpretationSemantics.RelationshipStrength.NONE,
	required_target_area_role: LayoutInterpretationSemantics.AreaRole = LayoutInterpretationSemantics.AreaRole.INVALID,
	required_target_requirement_id: StringName = &"",
	required_progression_targets_percent: PackedInt32Array = PackedInt32Array()
) -> void:
	id = requirement_id
	area_role = required_area_role
	minimum_count = required_minimum_count
	maximum_count = required_maximum_count
	relationship_kind = required_relationship_kind
	relationship_strength = required_relationship_strength
	target_area_role = required_target_area_role
	target_requirement_id = required_target_requirement_id
	progression_targets_percent = required_progression_targets_percent.duplicate()


func duplicate_requirement() -> LayoutAreaRequirement:
	return LayoutAreaRequirement.new(
		id,
		area_role,
		minimum_count,
		maximum_count,
		relationship_kind,
		relationship_strength,
		target_area_role,
		target_requirement_id,
		progression_targets_percent
	)
