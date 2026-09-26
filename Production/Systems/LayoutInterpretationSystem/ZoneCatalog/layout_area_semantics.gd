class_name LayoutAreaSemantics
extends RefCounted

enum GrowthMode {
	NONE,
	FLOOD,
}

enum Tag {
	INVALID = -1,
	ENTRANCE,
	BOSS,
	NO_ENEMY,
	LIGHT,
	ENEMY,
	LOCKABLE,
	LOOTABLE,
	TRAPPED,
	SWARM,
	ARCANE,
	DIVINITY,
	NO_LIGHT,
	CROSS_FAMILY_ABERRATION,
	CROSS_FAMILY_ELEMENTAL,
}

enum Preference {
	INVALID = -1,
	WALL_ADJACENCY,
	LARGEST_USABLE_CONNECTED_SPACE,
	SINGLE_OPEN_AREA,
	CENTRAL_PATH,
	LONG_WALLS,
	OPEN_AREA,
	MINIMIZE_WALL_CONTACT,
	LONG_SHAPE,
	SPRAWLING,
	BALANCED_RECTANGLE,
	COMPACT,
	MIDDLE_PROGRESSION,
}

static func supported_tags() -> Array[Tag]:
	return [
		Tag.ENTRANCE,
		Tag.BOSS,
		Tag.NO_ENEMY,
		Tag.LIGHT,
		Tag.ENEMY,
		Tag.LOCKABLE,
		Tag.LOOTABLE,
		Tag.TRAPPED,
		Tag.SWARM,
		Tag.ARCANE,
		Tag.DIVINITY,
		Tag.NO_LIGHT,
		Tag.CROSS_FAMILY_ABERRATION,
		Tag.CROSS_FAMILY_ELEMENTAL,
	]


static func supported_preferences() -> Array[Preference]:
	return [
		Preference.WALL_ADJACENCY,
		Preference.LARGEST_USABLE_CONNECTED_SPACE,
		Preference.SINGLE_OPEN_AREA,
		Preference.CENTRAL_PATH,
		Preference.LONG_WALLS,
		Preference.OPEN_AREA,
		Preference.MINIMIZE_WALL_CONTACT,
		Preference.LONG_SHAPE,
		Preference.SPRAWLING,
		Preference.BALANCED_RECTANGLE,
		Preference.COMPACT,
		Preference.MIDDLE_PROGRESSION,
	]
