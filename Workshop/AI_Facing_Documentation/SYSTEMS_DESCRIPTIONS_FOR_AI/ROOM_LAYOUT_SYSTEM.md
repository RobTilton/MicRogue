# Room Layout System
Updated: 2026-09-28
Implementation baseline/evidence: working tree based on Git `25117b113d25deab9f46db68c75c0dd536f37b33`; expanded focused suite passed 44,057 checks on 2026-09-28.

## Rapid Shape

Room Layout assigns one catalog room type and an ordered, duplicate-preserving tag list to every room in an existing `RapidRoomMapData`. Each completed room record therefore carries identity, panel count, exact safe floor coordinates, semantic type, and weighted tags. Layout uses stable Rapid room order and panel count; it performs no geometric analysis and does not modify physical cells or room coordinates.

## Location And Entry Points

Runtime authority is [`Production/Systems/RoomLayoutSystem/`](../../../Production/Systems/RoomLayoutSystem/).

```gdscript
var success: bool = RoomLayoutTagger.tag_rooms(map_data, archetype)
```

`tag_rooms_seeded(map_data, archetype, seed)` exists for reproducible tests. Both calls mutate the exact supplied package and return success/failure only.

## Archetypes And Assignment

`RoomLayoutSemantics.Archetype` contains Cave, Catacomb, Nest, and SubPassage.

Assignment order:

1. Derive the layer-one board size from `sqrt(sum(room.panel_count))`; refuse a non-square result.
2. Entrance: smallest panel count among the first `size` rooms; lowest ID wins ties.
3. BossRoom: largest eligible 2–4 panel room among the last `size` rooms, excluding Entrance; highest ID wins ties. Absence refuses before mutation.
4. Process the selected Archetype's named entries in catalog order. Each chooses one random eligible unassigned room; unavailable entries are skipped.
5. Assign Default to every remaining room.
6. Apply the complete assignment plan to the original room records.

Catalog authority is `room_layout_catalog.gd`. Repeated tags are deliberate integer weight and must not be deduplicated; Cave Hidden therefore retains two `LOOT` entries.

## Ownership And Limits

Layout owns Archetypes, room-type vocabulary, catalog entries, selection, and tag assignment. Rapid owns room creation and panel count. The controller owns orchestration. Decoration and SpawnPointPopulation are later consumers.

Mandatory validation occurs before mutation. Layout does not modify physical cells, floor coordinates, doorways, room IDs, or panel counts. Decoration and SpawnPointPopulation may consume `floor_coordinates` directly instead of rediscovering room boundaries.

## Validation

The expanded focused suite passed 44,057 checks across all four Archetypes. It covered exact catalog content, duplicate weight, deterministic Entrance/Boss rules, panel eligibility, named-entry uniqueness, complete tagging and Default coverage, same-package mutation, physical-cell preservation, exact coordinate preservation, and composition after minimum-size normalization.
