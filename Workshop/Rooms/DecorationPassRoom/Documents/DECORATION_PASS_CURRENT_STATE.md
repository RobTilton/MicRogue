# Decoration Pass Current State
Updated: 2026-10-01
Checkpoint: `[DecorationPassRoom]+[DecorationPassTable]+[RoomSetupAndContracts]`
Implementation baseline/evidence: Setup-only execution established the Room from inspected current contracts; no Decoration implementation or runtime behavior exists.

## Rapid Shape

DecorationPassRoom will own the boundary between Layout-completed logical map data and catalog-backed visual cell assignments. It will not own physical generation, room semantics, artwork identity, or final pipeline orchestration.

The intended composition is:

```text
RapidRoomMapData after RoomLayoutTagger
    → Decoration catalog adapter
    → topology-aware Decoration pass
    → detached DecoratedMapData
    → TileMapLayer adapter
```

Only the Room contract and empty Table structure currently exist. Implementation requires a new Alignment Check beginning with the catalog adapter.

## Current Locations And Structure

```text
Workshop/Rooms/DecorationPassRoom/
├── DOTS.md
├── Documents/
│   └── DECORATION_PASS_CURRENT_STATE.md
└── Tables/
    └── DecorationPassTable/
```

`DOTS.md` owns authorization, Box dependencies, completion conditions, and traversal. This document owns concise recovery context.

## Dependency Contracts

### Rapid Room Generation

Production authority: `Production/Systems/RapidRoomGenerationSystem/`.

Decoration receives `RapidRoomMapData.cells`, ordered rooms, explicit room count, and doorway records. Cells are row-major `FLOOR = 1` or `WALL = 2`. The square side length is `(12 × requested_size) + 3`, but Decoration must derive and validate dimensions from the returned cell count rather than depend on generator internals.

Rapid owns geometry. Decoration must not change cells, room IDs, panel counts, floor coordinates, or doorways.

### Room Layout

Production authority: `Production/Systems/RoomLayoutSystem/`.

Layout mutates each room's `room_type` and ordered duplicate-preserving `tags`. It leaves physical cells, floor coordinates, and doorways unchanged. `floor_coordinates` is the authoritative room-owned safe-floor channel; doorway footprints and erosion-created floor may remain unowned.

Decoration may consume room types, weighted tags, and floor coordinates. It must not deduplicate tags or rediscover room ownership geometrically when Layout already supplies it.

### Fantasy Sprite Catalog

Workshop authority: `Workshop/WorkshopAssets/FantasySpriteCatalog/`.

The package provides a `784×352` transparent atlas, 486 exact 16-by-16 catalog entries, 486 semantic records, and a typed coordinate-ID lookup. Stable coordinate IDs remain lossless artwork identity; semantic aliases provide human-readable selection vocabulary.

The package does not define terrain topology or Decoration behavior. This Room must express those decisions in a profile rather than mutate the catalog.

### Lightweight Generation Controller

Production authority: `Production/Systems/LightweightGenerationController/`.

The controller currently composes Rapid and Layout and returns the same tagged `RapidRoomMapData`. It does not call Decoration. Controller changes and Production integration are outside the current Room scope.

## Ownership And Required Behavior

- Decoration owns complete logical-cell-to-sprite assignment.
- A detached result owns Decoration output; source generator data remains unchanged.
- A profile owns art-role choices; the painter owns topology and role classification.
- A rendering adapter owns TileMapLayer mutation; it does not decide which tile is correct.
- Seeded behavior must be reproducible.
- Required input is validated before result or TileMap mutation.
- Every emitted sprite must exist in the durable catalog.

## Current Limits And Next Action

No code, scene, profile, TileSet, or preview has been created. No tile has been selected, no topology convention has been established, and no visual result is claimed.

The next eligible action is an Alignment Check for `[DecorationPassRoom]+[DecorationPassTable]+[DecorationCatalogAdapter]`.
