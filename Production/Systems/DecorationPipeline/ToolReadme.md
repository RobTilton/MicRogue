# Decoration Pipeline Components
Updated: 2026-10-03

## Purpose And Status

Status: Proven within the documented Godot 4.4.1 validation scope. Keywords: Godot, Decoration, topology, catalog, detached map, TileMapLayer, deterministic stickers.

These independently owned components turn Layout-completed Rapid geometry into detached visual assignments and render them through separate base and sticker layers. This directory is their durable implementation owner; the composed preview lives in Production/Tools/DecoratedDungeonPreview.

## Components And Interfaces

| Component | Entry point | Responsibility / mutation |
|---|---|---|
| [CatalogAdapter](CatalogAdapter/decoration_catalog_adapter.gd) | `DecorationCatalogAdapter.create()` | Validate exact catalog/semantic authority; resolve aliases and typed queries. Parses semantic data once; does not modify source data. |
| [ResultContract](ResultContract/decorated_map_data.gd) | `DecoratedMapData.create(source, assignments, adapter)` | Validate complete source and assignments before allocating detached cells, rooms, doorways and sticker IDs. |
| [BaseCellPainter](BaseCellPainter/base_cell_painter.gd) | `BaseCellPainter.paint(source, seed)` | Classify topology, authoritative room ownership and doorway context without artwork choices or source mutation. |
| [FantasyDungeonProfile](FantasyDungeonProfile/fantasy_dungeon_profile.gd) | `FantasyDungeonProfile.decorate(source, seed, adapter)` | Resolve painter roles to catalog aliases and choose deterministic floor stickers. Returns the detached result. |
| [TileMapLayerAdapter](TileMapLayerAdapter/decoration_tile_map_layer_adapter.gd) | `DecorationTileMapLayerAdapter.render(base, stickers, result, adapter)` | Validate targets, coverage and catalog membership before modifying the two distinct layers. |

The profile composes painter, catalog and result; the renderer consumes the result independently. Catalog parsing and atlas coordinates remain contained in their owning adapters. The generic painter never chooses aliases or edits Rapid geometry.

## Required Assumptions And Key Rules

Inputs are Layout-completed `RapidRoomMapData` from [Rapid](../RapidRoomGenerationSystem/README.md) and [Layout](../RoomLayoutSystem/README.md). Cells form a nonempty square row-major map with FLOOR=1 and WALL=2. Room IDs are contiguous; `floor_coordinates` owns safe floor, and ordered tags preserve duplicates. Doorways retain both traversal and local door-item axes.

The [FantasySpriteCatalog](../../Assets/FantasySpriteCatalog/README.md) owns atlas pixels, stable IDs, aliases and semantic authority. The adapter binds exact SHA-256 values and 486 records. A changed package requires deliberate authority reconciliation, not bypassed checks.

Every physical cell receives a base tile: earth for floor and abyss for wall. Every wall and realized door position receives a sticker. Eligible floor excludes doorway footprints; `round(eligible_count × 0.03)` floor cells receive deterministic grass/bone stickers. Map north is negative Y; cardinal bits are N/E/S/W and diagonal bits NW/NE/SE/SW. Seeds reproduce assignments for the same input and Godot behavior.

## Usage And Validation

Create the adapter, pass the tagged map and seed to the profile, then render the returned result into distinct base/sticker TileMapLayers. Refusal returns null/false with errors; callers must stop dependent work. Directly constructed catalog adapters refuse lookup.

Each component directory retains its focused `validate_*.gd` SceneTree script. Run with Godot 4.4.1: `godot --headless --path <project> --script res://Production/Systems/DecorationPipeline/<Component>/validate_<name>.gd`.

Validation scope: the focused validators exercise authority, detached results and source non-mutation, deterministic topology/profile assignments, and composed layer rendering across all four archetypes at sizes 4 and 5. Current system contract: [Decoration pipeline](../../../Workshop/AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/FRAGILE_DECORATION_PIPELINE.md).

## Boundaries

This is Production-owned implementation. It does not own generation, Layout semantics, controller orchestration, population, collision, navigation, lighting, persistence or artwork authority. The TileMap renderer expects a compatible result from the owning result/profile boundary; it is not a validator for arbitrary hostile objects. Human judgment owns artwork meaning and appearance.
