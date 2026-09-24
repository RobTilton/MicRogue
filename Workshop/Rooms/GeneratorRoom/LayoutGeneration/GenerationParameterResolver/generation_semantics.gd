class_name GenerationSemantics
extends RefCounted

enum Archetype {
	INVALID = -1,
	DUNGEON,
	TOWER,
	CAVE,
}

enum Scale {
	INVALID = -1,
	SMALL,
	MEDIUM,
	LARGE,
}

enum GeometryModifier {
	INVALID = -1,
	EXPOSED,
	STANDARD,
	CONFINED,
}

enum GeometryStrategy {
	INVALID = -1,
	RECTANGULAR_ROOMS,
	CIRCULAR_TOWER,
	CIRCLE_CLUSTER_WITH_NOISE,
}


static func required_archetypes() -> Array[Archetype]:
	return [Archetype.DUNGEON, Archetype.TOWER, Archetype.CAVE]


static func required_scales() -> Array[Scale]:
	return [Scale.SMALL, Scale.MEDIUM, Scale.LARGE]


static func required_modifiers() -> Array[GeometryModifier]:
	return [
		GeometryModifier.EXPOSED,
		GeometryModifier.STANDARD,
		GeometryModifier.CONFINED,
	]
