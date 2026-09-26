class_name UniversalPassResult
extends RefCounted

var geometry: GeometryAnalysisResult
var claim_state: AreaClaimState
var entrance_claim: AreaClaim
var boss_claim: AreaClaim
var entrance_distances: Dictionary
var maximum_entrance_distance: int


func _init(
	result_geometry: GeometryAnalysisResult,
	result_claim_state: AreaClaimState,
	result_entrance_claim: AreaClaim,
	result_boss_claim: AreaClaim,
	result_entrance_distances: Dictionary,
	result_maximum_entrance_distance: int
) -> void:
	geometry = result_geometry.duplicate_result()
	claim_state = result_claim_state.duplicate_state()
	entrance_claim = result_entrance_claim.duplicate_claim()
	boss_claim = result_boss_claim.duplicate_claim()
	entrance_distances = result_entrance_distances.duplicate()
	maximum_entrance_distance = result_maximum_entrance_distance


func duplicate_result() -> UniversalPassResult:
	return UniversalPassResult.new(
		geometry,
		claim_state,
		entrance_claim,
		boss_claim,
		entrance_distances,
		maximum_entrance_distance
	)
