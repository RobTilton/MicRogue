# DecorationPassRoom DOTS
Updated: 2026-10-01
Checkpoint: `[DecorationPassRoom]+[DecorationPassTable]+[RoomSetupAndContracts]`
Implementation baseline/evidence: Production Rapid, Room Layout, and Lightweight Generation Controller contracts plus the durable Fantasy Sprite Catalog package were inspected on 2026-10-01; no Decoration implementation exists.

## Room Contract

- Room: DecorationPassRoom
- Outcome: Build a modular Decoration stage that consumes Layout-completed `RapidRoomMapData`, assigns one valid fantasy-catalog sprite to every physical map cell, and exposes a separate `TileMapLayer` rendering adapter.
- Scope / prohibited territory: Decoration result contracts, catalog adaptation, topology-aware base-cell painting, one fantasy-dungeon profile, a TileMapLayer adapter, and a composed validation preview. Do not modify Production generators, Layout, WorkshopAssets, atlas pixels, catalog membership, or semantic metadata. Exclude population, loot, enemies, traps, lighting behavior, navigation, collision, persistence, and Production adoption.
- Acceptance: Decoration refuses invalid input before partial output, does not mutate `RapidRoomMapData`, preserves Layout context, assigns exactly one valid catalog sprite per physical cell, is deterministic for seeded input, renders the same assignments through a TileMapLayer adapter, validates all four Layout archetypes and multiple sizes, and receives human visual acceptance for topology and tile choice.
- Authority evidence: Robert approved the complete Room direction through the DecorationPassRoom Alignment Check, clarified that the current execution is setup only, and issued `Execute` on 2026-10-01.
- Starting state: No DecorationPassRoom or Decoration implementation existed. No user-supplied Git checkpoint is known. Current dependencies remain externally owned and read-only.

## Current Traversal

- Last completed checkpoint: `[DecorationPassRoom]+[DecorationPassTable]+[RoomSetupAndContracts]`
- Active/interrupted checkpoint: none
- Next eligible action: provide a new Alignment Check for `[DecorationPassRoom]+[DecorationPassTable]+[DecorationCatalogAdapter]`; do not begin implementation from this setup approval
- Human acceptance / Git checkpoint: Room purpose and setup boundary are approved; no implementation or visual acceptance exists; no Git checkpoint is known

## Mandatory Box List

| Checkpoint: [Room]+[Table]+[Box] | Responsibility | Depends on | Completion condition | Status | Outputs / evidence |
|---|---|---|---|---|---|
| `[DecorationPassRoom]+[DecorationPassTable]+[RoomSetupAndContracts]` | Establish the Room, bounded outcome, dependencies, ownership, traversal, and documentation. | none | DOTS, current state, and Table structure exist; dependencies and implementation boundary are explicit; no Decoration code is created. | complete | `DOTS.md`; `Documents/DECORATION_PASS_CURRENT_STATE.md`; `Tables/DecorationPassTable/` |
| `[DecorationPassRoom]+[DecorationPassTable]+[DecorationCatalogAdapter]` | Expose validated semantic sprite lookup for Decoration without scattering atlas coordinates or runtime JSON parsing through the algorithm. | RoomSetupAndContracts | Typed requests by stable alias/family/category/tags resolve to exact accepted sprite IDs; changed or incomplete catalog authority refuses before use. | planned | Requires separate Alignment/Execute |
| `[DecorationPassRoom]+[DecorationPassTable]+[DecorationResultContract]` | Define detached, complete cell-paint output and preserved room/doorway context. | DecorationCatalogAdapter | Result dimensions and cell assignments validate; every physical cell has exactly one assignment; source map remains unchanged. | planned | Requires separate Alignment/Execute |
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
- The Decoration output representation, catalog adapter API, topology vocabulary, tile-role mapping, and preview wiring remain unimplemented.
