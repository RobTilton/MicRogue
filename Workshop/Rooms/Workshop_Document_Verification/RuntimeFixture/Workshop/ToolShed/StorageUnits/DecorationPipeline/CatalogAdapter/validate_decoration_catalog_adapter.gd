extends SceneTree

const ORIGIN := "res://Workshop/ToolShed/StorageUnits/DecorationPipeline/CatalogAdapter/validate_decoration_catalog_adapter.gd"
const Adapter := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/CatalogAdapter/decoration_catalog_adapter.gd")
const Query := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/CatalogAdapter/decoration_sprite_query.gd")


func _initialize() -> void:
	var validation_error := _validate()
	if not validation_error.is_empty():
		push_error("%s: %s" % [ORIGIN, validation_error])
		quit(1)
		return
	print("%s: passed authority, alias, family, category, tag, deterministic ordering, and unique-result checks" % ORIGIN)
	quit(0)


func _validate() -> String:
	var adapter: RefCounted = Adapter.create()
	if adapter == null:
		return "adapter refused the current accepted authority"
	if adapter.entry_count() != 486:
		return "adapter refused the current accepted authority"
	var alias_id: StringName = adapter.id_for_alias(&"dungeon_floor_pattern_000")
	if alias_id != &"atlas_x16_y00":
		return "stable alias resolved to an unexpected sprite id"
	var alias_query_ids: Array[StringName] = adapter.ids_for(Query.new(&"dungeon_floor_pattern_000"))
	if alias_query_ids != [&"atlas_x16_y00"]:
		return "typed alias query did not resolve exactly"
	var family_ids: Array[StringName] = adapter.ids_for(Query.new(&"", &"dungeon_floor_pattern"))
	if family_ids.size() < 2 or not _is_sorted(family_ids):
		return "family query was incomplete or non-deterministic"
	var terrain_ids: Array[StringName] = adapter.ids_for(Query.new(&"", &"", &"terrain", [&"dungeon", &"floor"]))
	if terrain_ids.is_empty() or not _is_sorted(terrain_ids):
		return "category/tag query did not produce deterministic matches"
	for id: StringName in terrain_ids:
		var sprite_record: RefCounted = adapter.record(id)
		if sprite_record.category != &"terrain" or not sprite_record.tags.has(&"dungeon") or not sprite_record.tags.has(&"floor"):
			return "category/tag query admitted an invalid record"
	if adapter.unique_id_for(Query.new(&"dungeon_floor_pattern_000")) != &"atlas_x16_y00":
		return "unique query did not return its exact accepted id"
	return ""


func _is_sorted(ids: Array[StringName]) -> bool:
	for index in range(1, ids.size()):
		if ids[index - 1] > ids[index]:
			return false
	return true
