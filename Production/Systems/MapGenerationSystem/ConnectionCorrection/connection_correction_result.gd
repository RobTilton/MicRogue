class_name ConnectionCorrectionResult
extends RefCounted

var field: GeometryField
var rooms: Array[DiscoveredRoom] = []
var punches: Array[AppliedHolePunch] = []
var candidate_evaluations: int
var mutated_cell_count: int
var pattern_usage: Dictionary[StringName, int] = {}
var error_message: String


var is_success: bool:
	get:
		return field != null and error_message.is_empty()


static func success(
	corrected_field: GeometryField,
	corrected_rooms: Array[DiscoveredRoom],
	applied_punches: Array[AppliedHolePunch],
	evaluated_candidates: int,
	mutated_cells: int,
	usage: Dictionary[StringName, int]
) -> ConnectionCorrectionResult:
	var result := ConnectionCorrectionResult.new()
	result.field = corrected_field
	result.rooms = corrected_rooms
	result.punches = applied_punches
	result.candidate_evaluations = evaluated_candidates
	result.mutated_cell_count = mutated_cells
	result.pattern_usage = usage
	return result


static func failure(message: String) -> ConnectionCorrectionResult:
	var result := ConnectionCorrectionResult.new()
	result.error_message = message
	return result
