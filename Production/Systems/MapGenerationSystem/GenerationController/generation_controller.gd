class_name GenerationController
extends RefCounted

const ERROR_ORIGIN := "MapGenerationSystem/GenerationController"


static func generate(
	catalog: GenerationCatalog,
	parameters: MapParameters
) -> MapGenerationResult:
	var resolution := GenerationParameterResolver.resolve(
		catalog,
		parameters.to_layout_request() if parameters != null else null
	)
	if not resolution.is_success:
		return _failure(resolution.error_message)

	var geometry := BaseGeometryGenerator.generate(resolution.parameters)
	if not geometry.is_success:
		return _failure(geometry.error_message)

	var discovery := RoomDiscoveryFill.discover(geometry.field, true)
	if not discovery.is_success:
		return _failure(discovery.error_message)

	var correction := ConnectionCorrection.correct(
		geometry.field,
		discovery,
		ConnectionCorrection.standard_patterns()
	)
	if not correction.is_success:
		return _failure(correction.error_message)

	var cull := PreJudgementCull.apply(correction.field, correction.rooms)
	if not cull.is_success:
		return _failure(cull.error_message)

	var final_field: GeometryField = cull.field
	if cull.requires_judgement:
		var judgement := RoomJudgement.judge(final_field, cull.surviving_rooms)
		if not judgement.is_success:
			return _failure(judgement.error_message)
		final_field = judgement.field

	return MapGenerationResult.success(
		MapData.new(final_field.size.x, final_field.size.y, final_field.cells)
	)


static func _failure(cause: String) -> MapGenerationResult:
	return MapGenerationResult.failure("%s: %s" % [ERROR_ORIGIN, cause])
