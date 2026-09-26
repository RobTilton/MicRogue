extends RefCounted

enum WallOrientation {
	HORIZONTAL,
	VERTICAL,
}

var coordinate: Vector2i
var wall_orientation: WallOrientation


func _init(
	door_coordinate: Vector2i,
	door_wall_orientation: WallOrientation
) -> void:
	coordinate = door_coordinate
	wall_orientation = door_wall_orientation
