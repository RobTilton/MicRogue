class_name MapGenerationResult
extends RefCounted

var map_data: MapData
var error_message: String

var is_success: bool:
	get:
		return map_data != null and error_message.is_empty()


static func success(data: MapData) -> MapGenerationResult:
	var result := MapGenerationResult.new()
	result.map_data = data
	return result


static func failure(message: String) -> MapGenerationResult:
	var result := MapGenerationResult.new()
	result.error_message = message
	return result
