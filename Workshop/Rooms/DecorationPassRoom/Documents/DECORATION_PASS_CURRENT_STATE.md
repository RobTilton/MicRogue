# Decoration Pass Current State
Updated: 2026-10-01
Checkpoint: `[DecorationPassRoom]+[DecorationPassTable]+[DecorationResultContract]`
Implementation baseline/evidence: The catalog adapter and detached result contract are implemented; focused seeded size-4 and size-5 result validation passed on 2026-10-01. No painting implementation exists.

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

The catalog adapter and result contract are complete. Semantic authority is validated before lookup, and a Decoration result cannot be created until its complete source context and all cell assignments validate together. Further implementation requires a new Alignment Check for the base-cell painter.

## Current Locations And Structure

```text
Workshop/Rooms/DecorationPassRoom/
├── DOTS.md
├── Documents/
│   └── DECORATION_PASS_CURRENT_STATE.md
└── Tables/
    └── DecorationPassTable/
        ├── CatalogAdapter/
            ├── decoration_catalog_adapter.gd
            ├── decoration_sprite_query.gd
            ├── decoration_sprite_record.gd
            └── validate_decoration_catalog_adapter.gd
        └── ResultContract/
            ├── decorated_map_data.gd
            └── validate_decorated_map_data.gd
```

`DOTS.md` owns authorization, Box dependencies, completion conditions, and traversal. This document owns concise recovery context.

## Catalog Adapter Contract

Create an adapter through `DecorationCatalogAdapter.create()`. Creation verifies the exact accepted catalog and semantic SHA-256 values, both 486-record counts, semantic-to-catalog authority linkage, catalog/Godot API membership parity, unique IDs and aliases, required family/category/tags, and absence of removal requests. Failed authority returns `null`; directly constructed adapters refuse lookup because they have not passed initialization.

`DecorationSpriteQuery` supports an exact alias plus optional family, category, and all-required-tag filters. `ids_for()` returns matching stable coordinate IDs in deterministic sorted order. `id_for_alias()` resolves the unique alias index directly. `unique_id_for()` refuses zero or multiple matches. `record()` exposes immutable-by-convention Decoration-owned semantic values without leaking parsed JSON dictionaries to consumers.

The adapter parses semantic JSON once at creation because the source package does not provide generated semantic GDScript. That parsing and all source-specific validation remain contained at this boundary; later painters consume typed records and IDs.

## Decoration Result Contract

`DecoratedMapData.create(source, assignments, catalog_adapter)` validates the complete input before allocating its result. It derives square dimensions from physical cell count; accepts only Rapid `FLOOR` and `WALL` values; requires one accepted catalog sprite ID per row-major physical cell; and validates Layout-completed ordered rooms, contiguous IDs, panel counts, tags, owned-floor coordinates, doorway positions, axes, and traversal neighbors.

A successful result owns detached copies of physical cells, sprite assignments, rooms, and doorways. Room type, ordered duplicate-preserving tags, safe-floor ownership, and doorway context survive unchanged. Mutating the caller's assignment array or the returned result cannot mutate the source `RapidRoomMapData`.

`validate_inputs()` exposes the same non-mutating refusal contract for callers that need to inspect validity without creating output. Failed `create()` calls return `null` and emit an origin-qualified error.

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

The completed components have no topology or tile-role policy. No painter, scene, profile, TileSet, or preview has been created. No tile has been selected, no topology convention has been established, and no visual result is claimed.

Validation evidence:

- Focused adapter validator passed authority, alias, family, category, tag, deterministic ordering, and unique-result checks.
- The source catalog's own validator passed all 486 entries, semantics, generated lookup, atlas regions, and cached textures.
- Seeded Layout-completed size-4 and size-5 maps passed exact coverage, invalid-input refusal, detached ownership, preserved context, and source non-mutation checks.
- A headless Godot editor load completed after both implemented Boxes without parse errors.

The next eligible action is an Alignment Check for `[DecorationPassRoom]+[DecorationPassTable]+[BaseCellPainter]`.
