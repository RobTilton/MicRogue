# DecorationPassRoom DOTS
Updated: 2026-10-01
Checkpoint: `[DecorationPassRoom]+[DecorationPassTable]+[DecorationResultContract]`
Implementation baseline/evidence: The validated catalog adapter and detached Decoration result contract are implemented; seeded size-4 and size-5 result validation passed on 2026-10-01. No painting implementation exists.

## Room Contract

- Room: DecorationPassRoom
- Outcome: Build a modular Decoration stage that consumes Layout-completed `RapidRoomMapData`, assigns one valid fantasy-catalog sprite to every physical map cell, and exposes a separate `TileMapLayer` rendering adapter.
- Scope / prohibited territory: Decoration result contracts, catalog adaptation, topology-aware base-cell painting, one fantasy-dungeon profile, a TileMapLayer adapter, and a composed validation preview. Do not modify Production generators, Layout, WorkshopAssets, atlas pixels, catalog membership, or semantic metadata. Exclude population, loot, enemies, traps, lighting behavior, navigation, collision, persistence, and Production adoption.
- Acceptance: Decoration refuses invalid input before partial output, does not mutate `RapidRoomMapData`, preserves Layout context, assigns exactly one valid catalog sprite per physical cell, is deterministic for seeded input, renders the same assignments through a TileMapLayer adapter, validates all four Layout archetypes and multiple sizes, and receives human visual acceptance for topology and tile choice.
- Authority evidence: Robert approved the complete Room direction and setup execution, then confirmed the bounded DecorationCatalogAdapter and DecorationResultContract Alignment Checks and issued `Execute` for each on 2026-10-01.
- Starting state: No DecorationPassRoom or Decoration implementation existed. No user-supplied Git checkpoint is known. Current dependencies remain externally owned and read-only.

## Current Traversal

- Last completed checkpoint: `[DecorationPassRoom]+[DecorationPassTable]+[DecorationResultContract]`
- Active/interrupted checkpoint: none
- Next eligible action: provide a new Alignment Check for `[DecorationPassRoom]+[DecorationPassTable]+[BaseCellPainter]`; do not begin it from the result-contract approval
- Human acceptance / Git checkpoint: Room purpose and completed non-visual Boxes are approved for execution; visual acceptance has not yet occurred and is not applicable to the completed Boxes; no Git checkpoint is known

## Mandatory Box List

| Checkpoint: [Room]+[Table]+[Box] | Responsibility | Depends on | Completion condition | Status | Outputs / evidence |
|---|---|---|---|---|---|
| `[DecorationPassRoom]+[DecorationPassTable]+[RoomSetupAndContracts]` | Establish the Room, bounded outcome, dependencies, ownership, traversal, and documentation. | none | DOTS, current state, and Table structure exist; dependencies and implementation boundary are explicit; no Decoration code is created. | complete | `DOTS.md`; `Documents/DECORATION_PASS_CURRENT_STATE.md`; `Tables/DecorationPassTable/` |
| `[DecorationPassRoom]+[DecorationPassTable]+[DecorationCatalogAdapter]` | Expose validated semantic sprite lookup for Decoration without scattering atlas coordinates or runtime JSON parsing through the algorithm. | RoomSetupAndContracts | Typed requests by stable alias/family/category/tags resolve to exact accepted sprite IDs; changed or incomplete catalog authority refuses before use. | complete | `Tables/DecorationPassTable/CatalogAdapter/`; focused validator passed all 486 records and query modes; catalog validator and headless editor load passed on 2026-10-01 |
| `[DecorationPassRoom]+[DecorationPassTable]+[DecorationResultContract]` | Define detached, complete cell-paint output and preserved room/doorway context. | DecorationCatalogAdapter | Result dimensions and cell assignments validate; every physical cell has exactly one assignment; source map remains unchanged. | complete | `Tables/DecorationPassTable/ResultContract/`; seeded size-4 and size-5 validation passed exact coverage, invalid refusal, detached context, assignment ownership, and source non-mutation; headless editor load passed on 2026-10-01 |
| `[DecorationPassRoom]+[DecorationPassTable]+[BaseCellPainter]` | Classify physical cells from floor/wall geometry, neighborhood topology, Layout floor ownership, room semantics, and doorways. | DecorationResultContract | Complete-input validation, topology classification, deterministic assignment, exact coverage, and non-mutation pass. | planned | Requires separate Alignment/Execute |
| `[DecorationPassRoom]+[DecorationPassTable]+[FantasyDungeonProfile]` | Map logical paint roles to the current fantasy catalog without embedding art decisions in the painter. | BaseCellPainter | Required roles resolve to accepted IDs; direction conventions are explicit; ambiguous art is exposed for human review. | planned | Requires separate Alignment/Execute and later visual acceptance |
| `[DecorationPassRoom]+[DecorationPassTable]+[TileMapLayerAdapter]` | Materialize a Decoration result through a Godot TileMapLayer backed by the packed atlas. | FantasyDungeonProfile | Rendered source IDs and atlas coordinates match every Decoration assignment without changing source data. | planned | Requires separate Alignment/Execute |
| `[DecorationPassRoom]+[DecorationPassTable]+[ComposedGenerationPreview]` | Exercise seeded Rapid, Layout, Decoration, and rendering together. | TileMapLayerAdapter | Multiple sizes and all four archetypes validate; preview starts cleanly; Robert accepts visual topology and tile selection. | planned | Requires separate Alignment/Execute and human visual check |

## Current References And Unresolved State

- Current-state reference: [Documents/DECORATION_PASS_CURRENT_STATE.md](Documents/DECORATION_PASS_CURRENT_STATE.md)
- Rapid contract: [../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/RAPID_ROOM_GENERATION_SYSTEM.md](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/RAPID_ROOM_GENERATION_SYSTEM.md)
- Layout contract: [../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/ROOM_LAYOUT_SYSTEM.md](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/ROOM_LAYOUT_SYSTEM.md)
- Controller contract: [../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/LIGHTWEIGHT_GENERATION_CONTROLLER.md](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/LIGHTWEIGHT_GENERATION_CONTROLLER.md)
- Sprite package contract: [../../WorkshopAssets/FantasySpriteCatalog/README.md](../../WorkshopAssets/FantasySpriteCatalog/README.md)
- Production and WorkshopAssets are read-only dependencies for this Room.
- The topology vocabulary, tile-role mapping, and preview wiring remain unimplemented. The catalog adapter and result contract are current under `Tables/DecorationPassTable/`.
