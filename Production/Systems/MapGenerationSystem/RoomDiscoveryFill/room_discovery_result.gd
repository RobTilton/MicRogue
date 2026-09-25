class_name RoomDiscoveryResult
extends RefCounted

var rooms: Array[DiscoveredRoom] = []
var frontier_walls_included: bool
var error_message: String


var is_success: bool:
	get:
		return error_message.is_empty()


static func success(
	discovered_rooms: Array[DiscoveredRoom],
	included_frontier_walls: bool
) -> RoomDiscoveryResult:
	var result := RoomDiscoveryResult.new()
	result.rooms = discovered_rooms
	result.frontier_walls_included = included_frontier_walls
	return result


static func failure(message: String) -> RoomDiscoveryResult:
	var result := RoomDiscoveryResult.new()
	result.error_message = message
	return result
