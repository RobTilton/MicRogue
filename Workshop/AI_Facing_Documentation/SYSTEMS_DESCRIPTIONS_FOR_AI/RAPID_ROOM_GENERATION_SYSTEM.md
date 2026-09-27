# Rapid Room Generation System
Updated: 2026-09-27
Checkpoint: `[OneOffRapidRnDRoom]+[ProductionPromotion]+[AdoptSystem]`
Implementation baseline/evidence: Git `6d933948c8dca290cab4321def786179c5bc28d4`; promoted Production files are uncommitted.

## Rapid Shape

The Rapid Room Generation System is Production authority for Microgue's fast, catalog-driven room geometry. It accepts one square top-board side length and returns detached `RapidRoomMapData` containing final floor/wall geometry and explicit doorway tags.

The system owns its full pipeline and trusts every intermediate structure it creates. Its room walk and four-sided shared-doorway rules produce one cardinally connected floor network by construction; it performs no connectivity repair, retry, or rejection sampling. It also performs no Layout Interpretation, rendering, or gameplay work. Ordinary runtime randomness is internal; a separate seeded entry exists for reproducible tests.

## Current Locations And Structure

Runtime authority is [`Production/Systems/RapidRoomGenerationSystem/`](../../../Production/Systems/RapidRoomGenerationSystem/):

- `rapid_room_generator.gd`: public boundary, complete generation pipeline, catalogs, and internal working state.
- `rapid_room_map_data.gd`: detached result contract and ASCII representation.
- `rapid_room_doorway.gd`: detached realized-doorway metadata.
- `README.md`: portable package usage contract.

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

1. Partition the open `size × size` top board in row-major order. Each unassigned cell seeds a room and receives zero through three self-avoiding Manhattan steps through unassigned cells.
2. Expand every top cell into a 3×3 middle-layer floor block carrying its room ID. One unowned wall cell separates neighboring blocks.
3. From an immutable pre-merge state, open ordinary dividers whose opposing room IDs match. Open a divider intersection only when all four cardinal neighbors are walls and all four diagonal room IDs match.
4. Process rooms sequentially. Existing shared doorway tags satisfy the neighbor's corresponding side; every missing cardinal side authors one eligible non-corner extreme request. Real neighboring structures are updated immediately, so no room can remain isolated. Exterior requests are allowed and later sealed without invalidating the room network.
5. Add the unconditional exterior wall ring.
6. Expand every middle cell into final 3×3 geometry. Room-owned cells are empty floor, ordinary walls are solid, and realized doors choose one of seven legal seeded-random templates rotated to their traversal axis.
7. Apply one immutable-snapshot wall-noise pass. Each outer tile of an ordinary non-door wall block that touches floor by Manhattan adjacency independently has a 40% chance to become floor. Wall-block centers remain wall and erosion does not cascade.
8. Return detached map geometry and doorway records.

The final square side length is `(12 × size) + 3`; `size = 5` returns `63 × 63` geometry.

## Component Contracts

### `RapidRoomGenerator`

Owns generation order, internal randomness, top-room assignment, middle blueprint, doorway authorship, template selection, and wall noise. `make_map(size)` is the ordinary public boundary. `make_seeded_map(size, seed)` exists only to reproduce output. `size < 1` fails loudly and returns null.

Every top-board cell belongs to one connected room. Every room authors doorway intent at all four cardinal extremes, and realized shared walls propagate the connection to both rooms. Requests into the exterior are sealed only after shared connections are resolved. Consequently every room participates in one cardinally connected final floor network without a flood fill or repair pass.

The generator has no phase-validation mode. Because it is the sole producer of its intermediate state, each phase trusts the guarantees of the preceding phase. Unexpected absence of an eligible doorway or opposite floor fails loudly rather than returning partial data.

### `RapidRoomMapData`

Owns detached final output. `cells` is row-major with `FLOOR = 1` and `WALL = 2`. Width and height match the final grid. Diagnostics describe the completed request and do not control generation.

The doorway collection is a separate semantic channel because a doorway template contains both floor and wall pixels. Consumers must use doorway records rather than attempting to rediscover doorway ownership from cell values.

### `RapidRoomDoorway`

Represents one realized shared doorway. It exposes:

- `blueprint_position`: coordinate of the owning middle-layer doorway cell after the exterior ring is added;
- `final_origin`: top-left coordinate of its final 3×3 footprint;
- `axis`: horizontal or vertical traversal;
- `template_index`: selected catalog entry.

Requests into the exterior are deliberately sealed and do not produce doorway records.

## Required Outside Data

The only required input is an integer square-board side length. The package uses Godot core types and `RandomNumberGenerator`; it has no project-specific runtime dependency outside its own directory.

The package is self-contained. It neither calls nor depends on the existing `MapGenerationSystem` or another Production system.

## Validation And Current Limits

Production validation passed:

- Godot editor import registered `RapidRoomGenerator`, `RapidRoomMapData`, and `RapidRoomDoorway` from the Production package without script errors.
- The retained external suite passed 1,000 size-5 results and 100 results each at sizes 1, 2, and 10. The size-5 set averaged 5.860 ms and 19.705 realized doorways; its observed maximum was 25.530 ms.
- Seed-42 size-3 ASCII evidence preserved the accepted 39 × 39 geometry, 4 rooms, 5 realized doorways, 9 sealed outward requests, and 98 eroded tiles.
- The final uncontended Production benchmark, after 100 warmups, passed 2,000 size-5 samples: mean 6.230 ms, median 5.915 ms, p95 9.301 ms, p99 12.871 ms, and maximum 16.254 ms. Engine startup and ASCII printing were excluded.

The system guarantees global cardinal floor connectivity within each returned map. It does not interpret architectural purpose, paint a GridMap, render, populate gameplay objects, or integrate itself with a controller. Those are separate systems or future authority boundaries.
