class_name InterpretationZone
extends RefCounted

var id: int
var area_role: LayoutInterpretationSemantics.AreaRole
var requirement_id: StringName
var origin: Vector2i
var bounds: Rect2i
var tags: Array[LayoutAreaSemantics.Tag]
var relationship_kind: LayoutInterpretationSemantics.RelationshipKind
var relationship_strength: LayoutInterpretationSemantics.RelationshipStrength
var target_zone_ids: PackedInt32Array
var progression_target_percent: int

var _coordinates: Array[Vector2i]


func _init(claim: AreaClaim) -> void:
	id = claim.id
	area_role = claim.area_role
	requirement_id = claim.requirement_id
	origin = claim.origin
	tags = claim.tags.duplicate()
	relationship_kind = claim.relationship_kind
	relationship_strength = claim.relationship_strength
	target_zone_ids = claim.target_claim_ids.duplicate()
	progression_target_percent = claim.progression_target_percent
	_replace_coordinates(claim.cells)


func get_coordinates() -> Array[Vector2i]:
	return _coordinates.duplicate()


func has_coordinate(coordinate: Vector2i) -> bool:
	return coordinate in _coordinates


func coordinate_count() -> int:
	return _coordinates.size()


func _replace_coordinates(coordinates: Array[Vector2i]) -> void:
	_coordinates = coordinates.duplicate()
	_coordinates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y < b.y or (a.y == b.y and a.x < b.x)
	)
	bounds = _calculate_bounds(_coordinates)


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
