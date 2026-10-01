# Decoration Pipeline
Updated: 2026-10-01

## Rapid Shape

The Workshop Decoration pipeline consumes Layout-completed Rapid map data, classifies topology, resolves fantasy catalog stickers into a detached result, and renders separate solid-color base and artwork sticker layers. Components have explicit ownership boundaries; the composed preview owns orchestration. The Production controller currently composes Rapid and Layout only.

## Current Locations And Structure

Durable component authority is [DecorationPipeline](../../ToolShed/StorageUnits/DecorationPipeline/ToolReadme.md), containing CatalogAdapter, ResultContract, BaseCellPainter, FantasyDungeonProfile and TileMapLayerAdapter. The [DecoratedDungeonPreview](../../ToolShed/Completed_Tool_Builds/DecoratedDungeonPreview/BuildReadme.md) owns the runnable scene and UI. Neither requires a temporary Room.

## Entry Points And Flow

1. Rapid returns mutable physical map data; Layout assigns types and duplicate-preserving tags.
2. `DecorationCatalogAdapter.create()` verifies catalog authority and builds typed lookup.
3. `FantasyDungeonProfile.decorate(source, seed, adapter)` calls the topology painter, selects aliases, and creates detached `DecoratedMapData`.
4. `DecorationTileMapLayerAdapter.render(base, stickers, result, adapter)` validates before mutating distinct layer targets.

`BaseCellPainter.paint()` is independently callable. `DecoratedMapData.validate_source()` and `validate_inputs()` expose non-mutating refusal. Failed creation returns null; failed rendering returns false. Consumers stop dependent work on refusal.

## Component And Coupling Contracts

| Owner | Contribution / invariant | Consequence of independent change |
|---|---|---|
| [Rapid](RAPID_ROOM_GENERATION_SYSTEM.md) | Square row-major FLOOR=1/WALL=2 geometry; realized door positions, sacred 3×3 footprints and separate local/traversal axes. | Changes to values, coordinates or doorway geometry can invalidate ownership, topology and door stickers. |
| [Layout](ROOM_LAYOUT_SYSTEM.md) | Contiguous ordered rooms, authoritative safe-floor coordinates, nonempty type and ordered duplicate-preserving tags. | Rediscovering ownership or deduplicating tags loses supplied context and weighting. |
| [Fantasy catalog](../../WorkshopAssets/FantasySpriteCatalog/README.md) | Exact 486-entry catalog and semantics, stable coordinate IDs, 16×16 cells in a 784×352 atlas. | Changed authority is refused by the adapter; changing pixels/aliases alone can invalidate visual meaning. |
| Painter | Same-type N/E/S/W cardinal and NW/NE/SE/SW diagonal masks; map north is negative Y; explicit doorway roles. | Changing mask order requires coordinated profile mapping changes. |
| Profile | White stone aliases apply to walls; seeded grass/bones apply to exactly `round(eligible_count × 0.03)` floor cells; doors have priority. | Alias or eligibility changes alter artwork and coverage; doorway footprints must stay excluded. |
| Result | Detached physical cells, IDs, room records and doorways; one assignment slot per physical cell; walls require nonempty catalog stickers. | Sharing mutable source state would violate source non-mutation and preserved Layout context. |
| Renderer | Distinct base/sticker layers, 16×16 TileSet cells; earth under floors, abyss under walls; source ID 0 and adapter-owned atlas coordinates. | Changing tile sizes or atlas mapping alone misaligns logical and visual coordinates. |

The base painter has no artwork aliases. The profile decides artwork; the renderer materializes the result without choosing art. Required input is validated by its owning boundary before output or layer mutation. Catalog JSON is parsed once per adapter creation; later consumers use typed records and stable IDs.

## Required Outside Data And Limits

Production Rapid and Layout remain external owners. FantasySpriteCatalog remains under WorkshopAssets. Atlas or semantic reconciliation must preserve exact authority linkage and coordinate conventions across the composed result.

Decoration is durable Workshop code. Production adoption, controller changes, population, lighting, collisions, navigation and persistence remain excluded. The preview is independently runnable and does not alter the project main scene.
