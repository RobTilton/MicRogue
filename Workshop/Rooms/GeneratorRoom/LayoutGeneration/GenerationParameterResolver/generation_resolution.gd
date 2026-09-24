class_name GenerationResolution
extends RefCounted

var parameters: ResolvedGenerationParameters
var error_message: String


var is_success: bool:
	get:
		return parameters != null and error_message.is_empty()


static func success(result: ResolvedGenerationParameters) -> GenerationResolution:
	var resolution := GenerationResolution.new()
	resolution.parameters = result
	return resolution


static func failure(message: String) -> GenerationResolution:
	var resolution := GenerationResolution.new()
	resolution.error_message = message
	return resolution
