class_name DecorationSpriteRecord
extends RefCounted

var id: StringName
var alias: StringName
var family: StringName
var category: StringName
var tags: Array[StringName]


func _init(
	record_id: StringName,
	record_alias: StringName,
	record_family: StringName,
	record_category: StringName,
	record_tags: Array[StringName]
) -> void:
	id = record_id
	alias = record_alias
	family = record_family
	category = record_category
	tags = record_tags.duplicate()
