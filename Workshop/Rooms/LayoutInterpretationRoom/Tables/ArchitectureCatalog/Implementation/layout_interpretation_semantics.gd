class_name LayoutInterpretationSemantics
extends RefCounted

enum GeometryArchetype {
	INVALID = -1,
	DUNGEON,
	TOWER,
	CAVE,
}

enum Purpose {
	INVALID = -1,
	PRISON,
	CATACOMB,
	MAGE_TOWER,
	GUARD_TOWER,
	BURROW_NEST,
	MINE_SHAFT,
}

enum AreaRole {
	INVALID = -1,
	ENTRANCE_AREA,
	BOSS_AREA,
	GUARD_POST_AREA,
	CELL_AREA,
	SHRINE_AREA,
	BURIAL_CHAMBER_AREA,
	LIBRARY_AREA,
	SCRYING_CHAMBER_AREA,
	ALCHEMY_LAB_AREA,
	ARMORY_AREA,
	BARRACKS_AREA,
	NESTING_RESTING_AREA,
	FOOD_STORAGE_AREA,
	DEPOT_AREA,
	EQUIPMENT_STORAGE_AREA,
	GENERIC_AREA,
}

enum RelationshipKind {
	NONE,
	NEAR_AREA,
	AROUND_REQUIREMENT,
	ADJACENT_REQUIREMENT,
	PROGRESSION_TARGETS,
}

enum RelationshipStrength {
	NONE,
	PREFERRED,
	REQUIRED,
}


static func required_purposes() -> Array[Purpose]:
	return [
		Purpose.PRISON,
		Purpose.CATACOMB,
		Purpose.MAGE_TOWER,
		Purpose.GUARD_TOWER,
		Purpose.BURROW_NEST,
		Purpose.MINE_SHAFT,
	]


static func required_area_roles() -> Array[AreaRole]:
	return [
		AreaRole.ENTRANCE_AREA,
		AreaRole.BOSS_AREA,
		AreaRole.GUARD_POST_AREA,
		AreaRole.CELL_AREA,
		AreaRole.SHRINE_AREA,
		AreaRole.BURIAL_CHAMBER_AREA,
		AreaRole.LIBRARY_AREA,
		AreaRole.SCRYING_CHAMBER_AREA,
		AreaRole.ALCHEMY_LAB_AREA,
		AreaRole.ARMORY_AREA,
		AreaRole.BARRACKS_AREA,
		AreaRole.NESTING_RESTING_AREA,
		AreaRole.FOOD_STORAGE_AREA,
		AreaRole.DEPOT_AREA,
		AreaRole.EQUIPMENT_STORAGE_AREA,
		AreaRole.GENERIC_AREA,
	]


static func universal_area_roles() -> Array[AreaRole]:
	return [AreaRole.ENTRANCE_AREA, AreaRole.BOSS_AREA]
