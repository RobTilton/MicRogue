# Rapid Room Generation System
Updated: 2026-09-28
Implementation baseline/evidence: working tree based on Git `25117b113d25deab9f46db68c75c0dd536f37b33`; expanded composed validation passed 44,057 checks and visualization painting passed 29 checks on 2026-09-28.

## Rapid Shape

Rapid Room Generation is the sole current Production system. It accepts one square layer-one board side length and returns exactly the mutable layer-three physical cells, generated room records, explicit room count, and realized doorway placement/orientation required by later systems.

The minimum effective side length is 4. Requests below 4 are silently normalized to 4 at the shared ordinary/seeded generation boundary.

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

With the same seed, requested sizes 1, 2, 3, and 4 produce identical size-4 output.

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
- `floor_coordinates: Array[Vector2i]`: exact safe layer-three floor owned by the room.
- `room_type: StringName`: initialized empty by Rapid and assigned by Layout.
- `tags: Array[StringName]`: initialized empty by Rapid; Layout assignment preserves order and duplicates.

Across one result, all panel counts sum exactly to `size × size`.

Floor coordinates are collected from room-owned middle-blueprint floor before wall erosion. They include ordinary room blocks and merged same-room divider blocks. Doorway footprints are a separate channel, and erosion-created floor remains unowned. Coordinates are detached with their room record.

### `RapidRoomDoorway`

- `position: Vector2i`: center coordinate of the final layer-three 3×3 doorway footprint.
- `axis`: horizontal or vertical traversal orientation.

Template choice and middle-blueprint coordinates remain generator-internal. Exterior requests do not create doorway records.

## Ownership And Dependencies

Rapid owns room partitioning, physical geometry, and realized doorway metadata. It carries empty mutable room-semantic fields so the owning Layout system can tag the same package without a parallel record graph. Rapid does not choose room types or tags, interpret Archetypes, decorate, populate, render, or coordinate the wider pipeline.

The package depends only on Godot core types and `RandomNumberGenerator`.

## Validation And Current Limits

The retained contract suite passed 153,922 checks across 1,250 seeded maps: 250 maps at each input size 1, 2, 3, 5, and 10. It established:

- the exact approved public property surfaces;
- successful generation and expected layer-three cell count;
- unique contiguous room IDs, one-to-four panel counts, exact layer-one panel conservation, and explicit count agreement;
- doorway placement at final-footprint centers and openings across the declared traversal axis;
- in-place cell mutation;
- complete seeded reproduction of cells, rooms, and doorways.

Expanded validation additionally established nonempty in-bounds physical floor coordinates, unique ownership across rooms, doorway-footprint exclusion, and exact preservation through Layout.

Godot's import pass registered all four Rapid classes.

Room Layout and the lightweight controller now consume this result. Rapid's generation responsibility remains unchanged.
