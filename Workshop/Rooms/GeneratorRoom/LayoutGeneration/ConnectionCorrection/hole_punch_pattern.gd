class_name HolePunchPattern
extends RefCounted

var id: StringName
var offsets: Array[Vector2i]


func _init(pattern_id: StringName, pattern_offsets: Array[Vector2i]) -> void:
	id = pattern_id
	offsets = pattern_offsets
