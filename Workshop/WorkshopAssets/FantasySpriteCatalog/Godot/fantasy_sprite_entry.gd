class_name FantasySpriteEntry
extends RefCounted

var id: StringName
var category: StringName
var atlas_coords: Vector2i
var frame: int
var region: Rect2i


func _init(
	entry_id: StringName,
	entry_category: StringName,
	entry_atlas_coords: Vector2i,
	entry_frame: int,
	entry_region: Rect2i
) -> void:
	id = entry_id
	category = entry_category
	atlas_coords = entry_atlas_coords
	frame = entry_frame
	region = entry_region
