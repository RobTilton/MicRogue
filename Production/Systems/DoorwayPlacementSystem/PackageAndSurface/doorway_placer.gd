class_name DoorwayPlacer
extends RefCounted


static func place_doors(map_data: MapData) -> Array[DoorwayPlacement]:
	return DoorwaySelectionPass.run(map_data)
