# Room Layout System
Updated: 2026-09-27

This package assigns catalog-defined room types and duplicate-preserving tags to the rooms in an existing `RapidRoomMapData`. It preserves each room's authoritative `floor_coordinates` and does not generate or modify physical cells.

```gdscript
var success: bool = RoomLayoutTagger.tag_rooms(
	map_data,
	RoomLayoutSemantics.Archetype.CAVE
)
```

Assignment order is deterministic Entrance, deterministic BossRoom, one random eligible room per Archetype-specific catalog entry, then Default for every remaining room. Missing Archetype-specific entries are skipped. A missing mandatory BossRoom candidate refuses without partial mutation.

Entrance is the smallest room in the first derived-board-size rooms; lowest ID wins ties. BossRoom is the largest 2–4 panel room in the final derived-board-size rooms; highest ID wins ties. The board size is derived from the square root of the complete room-panel count.

The four Archetypes are Cave, Catacomb, Nest, and SubPassage. Catalog tags preserve order and duplicates because repeated tags are downstream integer weight.

`tag_rooms_seeded()` exists for reproducible tests. The package depends on Rapid's result types and has no scene, renderer, controller, decoration, or population dependency.
