class_name AreaClaim
extends RefCounted

var id: int
var area_role: LayoutInterpretationSemantics.AreaRole
var requirement_id: StringName
var origin: Vector2i
var cells: Array[Vector2i]
var bounds: Rect2i
var tags: Array[LayoutAreaSemantics.Tag]
var relationship_kind: LayoutInterpretationSemantics.RelationshipKind
var relationship_strength: LayoutInterpretationSemantics.RelationshipStrength
var target_claim_ids: PackedInt32Array
var progression_target_percent: int


func _init(
	claim_id: int,
	claim_area_role: LayoutInterpretationSemantics.AreaRole,
	claim_requirement_id: StringName,
	claim_origin: Vector2i,
	claim_cells: Array[Vector2i],
	claim_tags: Array[LayoutAreaSemantics.Tag],
	claim_relationship_kind: LayoutInterpretationSemantics.RelationshipKind = LayoutInterpretationSemantics.RelationshipKind.NONE,
	claim_relationship_strength: LayoutInterpretationSemantics.RelationshipStrength = LayoutInterpretationSemantics.RelationshipStrength.NONE,
	claim_target_claim_ids: PackedInt32Array = PackedInt32Array(),
	claim_progression_target_percent: int = -1
) -> void:
	id = claim_id
	area_role = claim_area_role
	requirement_id = claim_requirement_id
	origin = claim_origin
	cells = claim_cells.duplicate()
	tags = claim_tags.duplicate()
	relationship_kind = claim_relationship_kind
	relationship_strength = claim_relationship_strength
	target_claim_ids = claim_target_claim_ids.duplicate()
	progression_target_percent = claim_progression_target_percent
	bounds = _calculate_bounds(cells)


func duplicate_claim() -> AreaClaim:
	return AreaClaim.new(
		id,
		area_role,
		requirement_id,
		origin,
		cells,
		tags,
		relationship_kind,
		relationship_strength,
		target_claim_ids,
		progression_target_percent
	)


func _calculate_bounds(coordinates: Array[Vector2i]) -> Rect2i:
	if coordinates.is_empty():
		return Rect2i()
	var minimum: Vector2i = coordinates.front()
	var maximum: Vector2i = coordinates.front()
	for coordinate: Vector2i in coordinates:
		minimum.x = min(minimum.x, coordinate.x)
		minimum.y = min(minimum.y, coordinate.y)
		maximum.x = max(maximum.x, coordinate.x)
		maximum.y = max(maximum.y, coordinate.y)
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)
