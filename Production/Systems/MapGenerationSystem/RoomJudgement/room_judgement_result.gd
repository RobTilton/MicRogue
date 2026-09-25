class_name RoomJudgementResult
extends RefCounted

var field: GeometryField
var rooms: Array[DiscoveredRoom] = []
var saved_room_count: int
var sundered_room_count: int
var punch_count: int
var error_message: String

var is_success: bool:
	get: return field != null and error_message.is_empty()
