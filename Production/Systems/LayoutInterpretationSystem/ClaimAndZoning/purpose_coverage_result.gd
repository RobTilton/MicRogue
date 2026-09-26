class_name PurposeCoverageResult
extends RefCounted

var purpose: LayoutInterpretationSemantics.Purpose
var geometry: GeometryAnalysisResult
var claim_state: AreaClaimState
var entrance_claim: AreaClaim
var boss_claim: AreaClaim
var unzoned_floor: Array[Vector2i]
var coverage_ratio: float


func _init(
	result_purpose: LayoutInterpretationSemantics.Purpose,
	result_geometry: GeometryAnalysisResult,
	result_claim_state: AreaClaimState,
	result_entrance_claim: AreaClaim,
	result_boss_claim: AreaClaim,
	result_unzoned_floor: Array[Vector2i]
) -> void:
	purpose = result_purpose
	geometry = result_geometry.duplicate_result()
	claim_state = result_claim_state.duplicate_state()
	entrance_claim = result_entrance_claim.duplicate_claim()
	boss_claim = result_boss_claim.duplicate_claim()
	unzoned_floor = result_unzoned_floor.duplicate()
	coverage_ratio = (
		float(claim_state.claimed_tile_count()) / float(geometry.floor_coordinates.size())
		if not geometry.floor_coordinates.is_empty()
		else 0.0
	)


func duplicate_result() -> PurposeCoverageResult:
	return PurposeCoverageResult.new(
		purpose,
		geometry,
		claim_state,
		entrance_claim,
		boss_claim,
		unzoned_floor
	)
