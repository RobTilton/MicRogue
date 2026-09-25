class_name BaseGeometryResolution
extends RefCounted

var field: GeometryField
var error_message: String


var is_success: bool:
	get:
		return field != null and error_message.is_empty()


static func success(result: GeometryField) -> BaseGeometryResolution:
	var resolution := BaseGeometryResolution.new()
	resolution.field = result
	return resolution


static func failure(message: String) -> BaseGeometryResolution:
	var resolution := BaseGeometryResolution.new()
	resolution.error_message = message
	return resolution
