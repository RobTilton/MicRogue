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
}

enum Preference {
	INVALID = -1,
	WALL_ADJACENCY,
	LARGEST_USABLE_CONNECTED_SPACE,
	SINGLE_OPEN_AREA,
}

enum Connectivity {
	INVALID = -1,
	CARDINAL_FOUR,
}

enum RouteSelection {
	INVALID = -1,
	LONGEST_QUALIFYING_NAVIGABLE_ROUTE,
}

enum UndersizedEndpointPolicy {
	INVALID = -1,
	MOVE_INWARD_TO_NEXT_QUALIFYING_AREA,
}

enum EndpointAssignment {
	INVALID = -1,
	SMALLER_TO_ENTRANCE_LARGER_TO_BOSS,
}

enum EqualEndpointPolicy {
	INVALID = -1,
	RANDOM_COIN_FLIP,
}


static func supported_tags() -> Array[Tag]:
	return [Tag.ENTRANCE, Tag.BOSS, Tag.NO_ENEMY, Tag.LIGHT]


static func supported_preferences() -> Array[Preference]:
	return [
		Preference.WALL_ADJACENCY,
		Preference.LARGEST_USABLE_CONNECTED_SPACE,
		Preference.SINGLE_OPEN_AREA,
	]
