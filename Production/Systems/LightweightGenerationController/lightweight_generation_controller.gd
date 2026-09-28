class_name LightweightGenerationController
extends Node

const ERROR_ORIGIN: String = "Production/Systems/LightweightGenerationController/lightweight_generation_controller.gd"

@export_range(4, 100, 1) var size: int = 5
@export_enum("Cave:0", "Catacomb:1", "Nest:2", "SubPassage:3") var archetype: int = RoomLayoutSemantics.Archetype.CAVE


func generate_map() -> RapidRoomMapData:
	var map_data: RapidRoomMapData = RapidRoomGenerator.make_map(size)
	if map_data == null:
		push_error("%s: Rapid generation failed for size %d." % [ERROR_ORIGIN, size])
		return null
	if not RoomLayoutTagger.tag_rooms(map_data, archetype as RoomLayoutSemantics.Archetype):
		push_error("%s: Layout tagging failed for Archetype %d." % [ERROR_ORIGIN, archetype])
		return null
	return map_data
