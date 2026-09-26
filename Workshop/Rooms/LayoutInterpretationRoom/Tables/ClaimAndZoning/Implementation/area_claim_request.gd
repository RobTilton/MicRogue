class_name AreaClaimRequest
extends RefCounted

var requirement_id: StringName
var candidate_origins: Array[Vector2i]
var relationship_kind: LayoutInterpretationSemantics.RelationshipKind
var relationship_strength: LayoutInterpretationSemantics.RelationshipStrength
var target_claim_ids: PackedInt32Array
var progression_target_percent: int


func _init(
	request_requirement_id: StringName = &"",
	request_candidate_origins: Array[Vector2i] = [],
	request_relationship_kind: LayoutInterpretationSemantics.RelationshipKind = LayoutInterpretationSemantics.RelationshipKind.NONE,
	request_relationship_strength: LayoutInterpretationSemantics.RelationshipStrength = LayoutInterpretationSemantics.RelationshipStrength.NONE,
	request_target_claim_ids: PackedInt32Array = PackedInt32Array(),
	request_progression_target_percent: int = -1
) -> void:
	requirement_id = request_requirement_id
	candidate_origins = request_candidate_origins.duplicate()
	relationship_kind = request_relationship_kind
	relationship_strength = request_relationship_strength
	target_claim_ids = request_target_claim_ids.duplicate()
	progression_target_percent = request_progression_target_percent
