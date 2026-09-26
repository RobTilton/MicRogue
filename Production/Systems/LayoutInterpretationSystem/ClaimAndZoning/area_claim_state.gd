class_name AreaClaimState
extends RefCounted

const ORIGIN: String = "Production/Systems/LayoutInterpretationSystem/ClaimAndZoning/area_claim_state.gd"

var geometry: GeometryAnalysisResult
var _claim_id_by_coordinate: Dictionary = {}
var _claims: Array[AreaClaim] = []
var _next_claim_id: int = 1


func _init(analysis: GeometryAnalysisResult) -> void:
	geometry = analysis.duplicate_result() if analysis != null else null


func is_claimed(coordinate: Vector2i) -> bool:
	return _claim_id_by_coordinate.has(coordinate)


func claim_id_at(coordinate: Vector2i) -> int:
	return int(_claim_id_by_coordinate.get(coordinate, 0))


func claimed_tile_count() -> int:
	return _claim_id_by_coordinate.size()


func get_claims() -> Array[AreaClaim]:
	var detached: Array[AreaClaim] = []
	for claim: AreaClaim in _claims:
		detached.append(claim.duplicate_claim())
	return detached


func get_claim(claim_id: int) -> AreaClaim:
	for claim: AreaClaim in _claims:
		if claim.id == claim_id:
			return claim.duplicate_claim()
	return null


func duplicate_state() -> AreaClaimState:
	var detached := AreaClaimState.new(geometry)
	for claim: AreaClaim in _claims:
		var reapplied: AreaClaim = detached.apply_complete_claim(
			claim.area_role,
			claim.requirement_id,
			claim.origin,
			claim.cells,
			claim.tags,
			claim.relationship_kind,
			claim.relationship_strength,
			claim.target_claim_ids,
			claim.progression_target_percent
		)
		if reapplied == null:
			push_error("%s: failed to duplicate valid claim state." % ORIGIN)
			return null
	return detached


func apply_complete_claim(
	area_role: LayoutInterpretationSemantics.AreaRole,
	requirement_id: StringName,
	origin: Vector2i,
	coordinates: Array[Vector2i],
	tags: Array[LayoutAreaSemantics.Tag],
	relationship_kind: LayoutInterpretationSemantics.RelationshipKind = LayoutInterpretationSemantics.RelationshipKind.NONE,
	relationship_strength: LayoutInterpretationSemantics.RelationshipStrength = LayoutInterpretationSemantics.RelationshipStrength.NONE,
	target_claim_ids: PackedInt32Array = PackedInt32Array(),
	progression_target_percent: int = -1
) -> AreaClaim:
	if geometry == null:
		push_error("%s: cannot claim without geometry analysis." % ORIGIN)
		return null
	if coordinates.is_empty():
		push_error("%s: cannot apply an empty Area claim." % ORIGIN)
		return null
	var seen: Dictionary = {}
	for coordinate: Vector2i in coordinates:
		if seen.has(coordinate):
			push_error("%s: candidate claim repeats coordinate %s." % [ORIGIN, coordinate])
			return null
		if not geometry.is_floor(coordinate):
			push_error("%s: candidate claim includes non-floor coordinate %s." % [ORIGIN, coordinate])
			return null
		if _claim_id_by_coordinate.has(coordinate):
			push_error("%s: candidate claim overlaps existing claim at %s." % [ORIGIN, coordinate])
			return null
		seen[coordinate] = true
	var claim := AreaClaim.new(
		_next_claim_id,
		area_role,
		requirement_id,
		origin,
		coordinates,
		tags,
		relationship_kind,
		relationship_strength,
		target_claim_ids,
		progression_target_percent
	)
	for coordinate: Vector2i in coordinates:
		_claim_id_by_coordinate[coordinate] = claim.id
	_claims.append(claim)
	_next_claim_id += 1
	return claim.duplicate_claim()


func replace_claim_cells(claim_id: int, coordinates: Array[Vector2i]) -> AreaClaim:
	var claim_index: int = -1
	for index: int in range(_claims.size()):
		if _claims[index].id == claim_id:
			claim_index = index
			break
	if claim_index < 0:
		return null
	var existing: AreaClaim = _claims[claim_index]
	for coordinate: Vector2i in coordinates:
		if not geometry.is_floor(coordinate):
			return null
		var owner: int = claim_id_at(coordinate)
		if owner != 0 and owner != claim_id:
			return null
	for coordinate: Vector2i in existing.cells:
		if coordinate not in coordinates:
			_claim_id_by_coordinate.erase(coordinate)
	for coordinate: Vector2i in coordinates:
		_claim_id_by_coordinate[coordinate] = claim_id
	var replacement := AreaClaim.new(
		existing.id,
		existing.area_role,
		existing.requirement_id,
		existing.origin,
		coordinates,
		existing.tags,
		existing.relationship_kind,
		existing.relationship_strength,
		existing.target_claim_ids,
		existing.progression_target_percent
	)
	_claims[claim_index] = replacement
	return replacement.duplicate_claim()
