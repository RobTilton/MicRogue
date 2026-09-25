class_name GeneratorCaller
extends RefCounted

const ERROR_ORIGIN := "MapGenerationSystem/GeneratorCaller"


static func make_map(parameters: MapParameters) -> MapData:
	var result := GenerationController.generate(StarterGenerationCatalog.create(), parameters)
	if result.is_success:
		return result.map_data
	push_error("%s: %s" % [ERROR_ORIGIN, result.error_message])
	return null
