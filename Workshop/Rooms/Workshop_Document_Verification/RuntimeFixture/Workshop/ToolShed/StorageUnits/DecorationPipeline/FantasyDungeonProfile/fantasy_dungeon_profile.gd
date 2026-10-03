class_name FantasyDungeonProfile
extends RefCounted

const ORIGIN := "res://Workshop/ToolShed/StorageUnits/DecorationPipeline/FantasyDungeonProfile/fantasy_dungeon_profile.gd"
const Painter := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/base_cell_painter.gd")
const Context := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/decoration_cell_context.gd")
const Result := preload("res://Workshop/ToolShed/StorageUnits/DecorationPipeline/ResultContract/decorated_map_data.gd")

const WALL_CENTER := &"floor_inner_stone_a_center"
const WALL_EDGES := {14:&"floor_outer_stone_a_n", 13:&"floor_outer_stone_a_e", 11:&"floor_outer_stone_a_s", 7:&"floor_outer_stone_a_w"}
const WALL_OUTER := {6:&"floor_outer_stone_a_nw", 12:&"floor_outer_stone_a_ne", 9:&"floor_outer_stone_a_se", 3:&"floor_outer_stone_a_sw"}
const WALL_INNER := {14:&"floor_inner_stone_a_nw", 13:&"floor_inner_stone_a_ne", 11:&"floor_inner_stone_a_se", 7:&"floor_inner_stone_a_sw"}
const FLOOR_PATCHES := [&"overworld_detail_000", &"overworld_detail_001", &"overworld_detail_002", &"overworld_detail_003", &"overworld_detail_004", &"overworld_detail_005", &"overworld_detail_006", &"dungeon_deco_bone_000", &"dungeon_deco_bone_002", &"dungeon_deco_bone_003"]
const DOOR_VARIANTS := [&"deco_structure_door_003", &"deco_structure_door_004"]

static func decorate(source: RapidRoomMapData, seed: int, adapter: RefCounted) -> RefCounted:
	if adapter == null: push_error("%s: catalog adapter is null" % ORIGIN); return null
	var plan: RefCounted = Painter.paint(source, seed)
	if plan == null: return null
	var eligible_floor_indices: Array[int] = []
	for index in range(plan.cells.size()):
		var context: DecorationCellContext = plan.cells[index]
		if context.physical_cell == RapidRoomMapData.FLOOR and not context.is_door_position and not context.is_doorway_footprint: eligible_floor_indices.append(index)
	eligible_floor_indices.sort_custom(func(a: int, b: int): return plan.cells[a].variant_key < plan.cells[b].variant_key)
	var decorated_floor_indices: Dictionary = {}
	var decoration_count := int(round(float(eligible_floor_indices.size()) * 0.03))
	for selection_index in range(decoration_count): decorated_floor_indices[eligible_floor_indices[selection_index]] = true
	var ids: Array[StringName] = []
	for index in range(plan.cells.size()):
		var context: DecorationCellContext = plan.cells[index]
		var alias := _alias_for(context, decorated_floor_indices.has(index))
		if alias.is_empty(): ids.append(&""); continue
		var id: StringName = adapter.id_for_alias(alias)
		if id.is_empty(): push_error("%s: unresolved profile alias %s for role %s" % [ORIGIN, alias, context.role]); return null
		ids.append(id)
	return Result.create(source, ids, adapter)

static func aliases() -> Array[StringName]:
	var values: Array[StringName] = [WALL_CENTER]
	for value in WALL_EDGES.values(): values.append(value)
	for value in WALL_OUTER.values(): values.append(value)
	for value in WALL_INNER.values(): values.append(value)
	values.append_array(FLOOR_PATCHES); values.append_array(DOOR_VARIANTS)
	return values

static func _alias_for(context: DecorationCellContext, decorate_floor: bool) -> StringName:
	if context.is_door_position: return DOOR_VARIANTS[context.variant_key % DOOR_VARIANTS.size()]
	if context.physical_cell == RapidRoomMapData.FLOOR: return FLOOR_PATCHES[context.variant_key % FLOOR_PATCHES.size()] if decorate_floor else &""
	if context.topology == Context.Topology.EDGE and WALL_EDGES.has(context.cardinal_mask): return WALL_EDGES[context.cardinal_mask]
	if context.topology == Context.Topology.OUTER_CORNER and WALL_OUTER.has(context.cardinal_mask): return WALL_OUTER[context.cardinal_mask]
	if context.topology == Context.Topology.INNER_CORNER:
		var missing_diagonal := 15 ^ context.diagonal_mask
		if WALL_INNER.has(missing_diagonal): return WALL_INNER[missing_diagonal]
	return WALL_CENTER
