class_name PreJudgementCullResult
extends RefCounted

var field: GeometryField
var surviving_rooms: Array[DiscoveredRoom] = []
var culled_rooms: Array[DiscoveredRoom] = []
var culled_floor_count: int
var requires_judgement: bool
var error_message: String

var is_success: bool:
	get:
		return field != null and error_message.is_empty()

