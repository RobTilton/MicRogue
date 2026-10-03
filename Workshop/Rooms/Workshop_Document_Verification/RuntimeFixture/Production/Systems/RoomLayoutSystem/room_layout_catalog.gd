class_name RoomLayoutCatalog
extends RefCounted


static func entries_for(archetype: RoomLayoutSemantics.Archetype) -> Array[RoomLayoutEntry]:
	match archetype:
		RoomLayoutSemantics.Archetype.CATACOMB:
			return [
				_entry(&"Shrine", 1, 1, [&"HOLY", &"DEMON", &"ALTAR", &"DIVINITY"]),
				_entry(&"Tomb", 2, 4, [&"SWARM", &"ENEMY", &"LOOT"]),
				_entry(&"RitualRoom", 4, 4, [&"ENEMY", &"TRAP", &"SWARM"]),
			]
		RoomLayoutSemantics.Archetype.CAVE:
			return [
				_entry(&"Camp", 1, 1, [&"ENEMY", &"LOOT", &"LIGHT"]),
				_entry(&"Pit", 1, 2, [&"TRAP", &"ENEMY", &"NO_LIGHT"]),
				_entry(&"Shrine", 1, 1, [&"HOLY", &"DEMON", &"ALTAR", &"DIVINITY", &"LIGHT"]),
				_entry(&"Hidden", 1, 4, [&"LOOT", &"LOOT", &"TRAP", &"SWARM", &"ENEMY", &"NO_LIGHT"]),
			]
		RoomLayoutSemantics.Archetype.NEST:
			return [
				_entry(&"Hatchery", 2, 4, [&"SWARM", &"ENEMY", &"NO_LIGHT", &"TRAP"]),
				_entry(&"FoodStorage", 1, 4, [&"LOOT", &"ENEMY", &"NO_LIGHT"]),
				_entry(&"RoyalChamber", 3, 3, [&"ENEMY", &"LIGHT", &"LOOT"]),
			]
		RoomLayoutSemantics.Archetype.SUB_PASSAGE:
			return [
				_entry(&"Prison_Cell", 1, 2, [&"LOOT", &"LIGHT", &"TRAP"]),
				_entry(&"Guard_Post", 1, 3, [&"ENEMY", &"SWARM", &"LOOT", &"LIGHT"]),
				_entry(&"Bedding", 1, 4, [&"LOOT", &"SWARM", &"NO_LIGHT", &"TRAP"]),
				_entry(&"ThePit", 2, 2, [&"TRAP", &"NO_LIGHT", &"ENEMY"]),
			]
	return []


static func entrance_entry() -> RoomLayoutEntry:
	return _entry(RoomLayoutSemantics.ENTRANCE, 1, 4, [&"LIGHT"])


static func boss_entry() -> RoomLayoutEntry:
	return _entry(
		RoomLayoutSemantics.BOSS_ROOM,
		2,
		4,
		[&"ENEMY", &"BOSS", &"LOOT", &"LIGHT", &"SWARM", &"TRAP"]
	)


static func default_entry() -> RoomLayoutEntry:
	return _entry(
		RoomLayoutSemantics.DEFAULT,
		1,
		4,
		[&"ENEMY", &"LOOT", &"TRAP", &"LIGHT", &"NO_LIGHT", &"SWARM"]
	)


static func _entry(
	room_type: StringName,
	minimum_panels: int,
	maximum_panels: int,
	tags: Array[StringName]
) -> RoomLayoutEntry:
	return RoomLayoutEntry.new(room_type, minimum_panels, maximum_panels, tags)
