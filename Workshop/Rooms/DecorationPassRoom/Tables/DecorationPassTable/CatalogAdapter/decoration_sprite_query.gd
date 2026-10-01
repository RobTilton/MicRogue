class_name DecorationSpriteQuery
extends RefCounted

var alias: StringName
var family: StringName
var category: StringName
var required_tags: Array[StringName]


func _init(
	query_alias: StringName = &"",
	query_family: StringName = &"",
	query_category: StringName = &"",
	query_required_tags: Array[StringName] = []
) -> void:
	alias = query_alias
	family = query_family
	category = query_category
	required_tags = query_required_tags.duplicate()


func is_empty() -> bool:
	return alias.is_empty() and family.is_empty() and category.is_empty() and required_tags.is_empty()


func validation_error() -> String:
	if is_empty():
		return "sprite query must contain an alias, family, category, or required tag"
	var seen_tags: Dictionary = {}
	for tag: StringName in required_tags:
		if tag.is_empty():
			return "sprite query contains an empty required tag"
		if seen_tags.has(tag):
			return "sprite query contains a duplicate required tag: %s" % tag
		seen_tags[tag] = true
	return ""
