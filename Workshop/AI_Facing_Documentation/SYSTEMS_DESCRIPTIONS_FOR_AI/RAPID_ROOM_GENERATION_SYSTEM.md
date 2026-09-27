# Rapid Room Generation System
Updated: 2026-09-27
Implementation baseline/evidence: post-cleanup working tree based on Git `9a4f60b71fcf34e961c23b9c5449b6a68e6028e9`; focused contract suite passed 153,922 checks across 1,250 generated maps on 2026-09-27.

## Rapid Shape

Rapid Room Generation is the sole current Production system. It accepts one square layer-one board side length and returns exactly the mutable layer-three physical cells, generated room records, explicit room count, and realized doorway placement/orientation required by later systems.

The generator owns its complete geometry pipeline. Internal template choice, sealed exterior requests, wall-edge erosion accounting, dimensions, and timing are not part of the returned Production contract. Future tagging, decoration, and population systems are separate consumers.

## Current Locations And Structure

Runtime authority is [`Production/Systems/RapidRoomGenerationSystem/`](../../../Production/Systems/RapidRoomGenerationSystem/):

- `rapid_room_generator.gd`: public entry points and complete generation pipeline.
- `rapid_room_map_data.gd`: exact mutable result package.
- `rapid_room.gd`: detached room ID and panel-count record.
- `rapid_room_doorway.gd`: detached final placement and traversal-axis record.
- `README.md`: portable package contract.

## Entry Points And Flow

Ordinary consumers call:

```gdscript
var map_data: RapidRoomMapData = RapidRoomGenerator.make_map(size)
```

Tests may call:

```gdscript
var map_data: RapidRoomMapData = RapidRoomGenerator.make_seeded_map(size, seed)
```

Generation proceeds in this order:

1. Partition the square layer-one board. Each unassigned panel seeds a stable room ID and receives zero through three successful self-avoiding cardinal walk steps. The room's panel count increments with each successful assignment.
2. Expand each panel into the internal middle blueprint and merge dividers belonging to the same room.
3. Author shared doorway cells at missing room sides; requests reaching the exterior are sealed internally.
4. Add the exterior wall ring.
5. Resolve the mutable layer-three floor/wall cells and realized doorway templates.
6. Apply the internal immutable-snapshot wall-edge erosion pass.
7. Return detached room and doorway records with the mutable layer-three cells.

## Result Contract

### `RapidRoomMapData`

- `cells: PackedInt32Array`: mutable row-major layer-three physical data; `FLOOR = 1`, `WALL = 2`.
- `rooms: Array[RapidRoom]`: detached records ordered by stable contiguous room ID.
- `room_count: int`: exact explicit count equal to `rooms.size()`.
- `doorways: Array[RapidRoomDoorway]`: detached realized shared doorways.

It exposes no width, height, generation time, sealed-request count, erosion count, or other diagnostics. The internal final map remains square with side length `(12 × size) + 3`.

### `RapidRoom`

- `id: int`: stable contiguous ID beginning at zero.
- `panel_count: int`: number of layer-one panels assigned to the room, always one through four.

Across one result, all panel counts sum exactly to `size × size`.

### `RapidRoomDoorway`

- `position: Vector2i`: center coordinate of the final layer-three 3×3 doorway footprint.
- `axis`: horizontal or vertical traversal orientation.

Template choice and middle-blueprint coordinates remain generator-internal. Exterior requests do not create doorway records.

## Ownership And Dependencies

Rapid owns room partitioning, physical geometry, and realized doorway metadata. Downstream systems may mutate `cells` in the same returned package and may add their own room semantics in later approved contracts. Rapid does not tag rooms, interpret archetypes, decorate, populate, render, or coordinate the wider pipeline.

The package depends only on Godot core types and `RandomNumberGenerator`.

## Validation And Current Limits

The retained contract suite passed 153,922 checks across 1,250 seeded maps: 250 maps at each input size 1, 2, 3, 5, and 10. It established:

- the exact approved public property surfaces;
- successful generation and expected layer-three cell count;
- unique contiguous room IDs, one-to-four panel counts, exact layer-one panel conservation, and explicit count agreement;
- doorway placement at final-footprint centers and openings across the declared traversal axis;
- in-place cell mutation;
- complete seeded reproduction of cells, rooms, and doorways.

Godot's import pass registered all four Rapid classes.

No tagging system or controller exists yet. Their contracts must consume this result without expanding Rapid's responsibility implicitly.
