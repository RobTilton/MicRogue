# Generator Room Current State
Updated: 2026-09-24
Checkpoint: `[GeneratorRoom]+[LayoutGeneration]+[RoomJudgement]` complete
Implementation baseline/evidence: Git `9cfce5ff6eebe2f1c7b1cecf6f7a31fd52b6059f` plus the current Room-formatting changes

## Rapid Shape

GeneratorRoom is active and incomplete. A working procedural dungeon-field prototype generates overlapping rooms, repairs most disconnected floor regions, and renders the result through a Godot `GridMap`.

The typed pipeline through RoomJudgement is complete and human-accepted. RoomJudgement remains exposed in the visual debug scene and guarantees that every substantial residual room is either connected to the main room through the bounded plus-punch process or completely sundered into wall.

Durable technical detail is owned by the [Generator System Description](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/GENERATOR_SYSTEM.md). Completed-game requirements are owned by [`Scope_Defined.md`](../Project_Core_Documentation/Scope_Defined.md).

## Current Locations And Readiness

| Location | Current state |
|---|---|
| [`DungeonGeneration/`](DungeonGeneration/) | Working Godot generator, prototype caller, renderer, and runnable scene. |
| [`LayoutGeneration/GenerationParameterResolver/`](LayoutGeneration/GenerationParameterResolver/) | Completed typed semantic catalog, resolver, request, result, and refusal boundary. |
| [`LayoutGeneration/BaseGeometryGenerator/`](LayoutGeneration/BaseGeometryGenerator/) | Completed bounded geometry generator, internal cut/wrap helpers, Cave boundary planner, tests, and F6 debug scene. |
| [`LayoutGeneration/RoomDiscoveryFill/`](LayoutGeneration/RoomDiscoveryFill/) | Completed typed cardinal room discovery with explicitly optional frontier-wall collection; collection may be revisited if ConnectionCorrection proves it wasteful. |
| [`LayoutGeneration/ConnectionCorrection/`](LayoutGeneration/ConnectionCorrection/) | Completed typed local punch patterns, direct room/frontier maintenance, mutation evidence, and result contract. |
| [`LayoutGeneration/PreJudgementCull/`](LayoutGeneration/PreJudgementCull/) | Completed two-stage residual-room cull and explicit RoomJudgement gate. |
| [`LayoutGeneration/RoomJudgement/`](LayoutGeneration/RoomJudgement/) | Completed and human-accepted typed save-or-sunder pass using one or two plus punches and maintained room/frontier data. |
| [`Assets/DunGenMeshLibrary/`](Assets/DunGenMeshLibrary/) | Required prototype rendering meshes; paths repaired and resolving. |
| [`Scripts/`](Scripts/) | Python research and stress-test tools; not runtime dependencies. |
| [`Tests/`](Tests/) | Godot test script and retained 10,000-seed evidence. |
| [`Documents/`](Documents/) | Empty; no current owner or required output. |

Current working entry point: [`DungeonGeneration/DunGenFrontier.tscn`](DungeonGeneration/DunGenFrontier.tscn).

## Validation And Current Limits

Validated on 2026-09-23:

- Godot 4.4.1 imported the reorganized resources successfully.
- The prototype scene loaded and executed headlessly without reported errors.
- Python seed `4434` remained reproducible through the frontier harness; cross repair reduced 83 raw regions to 2.
- Recorded stress-test evidence contains 10,000 seed rows.
- Updated resolver regression passes 107 checks after geometry/boundary strategy separation.
- Base Geometry tests pass 63,793 checks across taxation, all 27 Archetype/Scale/Modifier permutations, square/circular/compound-circle boundaries, Cave planning and partial-chain preservation, deterministic RNG, and invalid inputs after Cave base-radius normalization.
- Room Discovery tests pass 41,092 checks across focused room/frontier behavior and all 27 generated catalog combinations.
- Resolver and Base Geometry regressions remain clean at 107 and 63,793 checks after Room Discovery integration.
- ConnectionCorrection tests pass 4,447 checks across all nine stamp orientations, focused selection/preservation behavior, direct room merging, unresolved cases, and all 27 generated catalog combinations.
- Generated-map evidence used single 32 times, lines 82, elbows 98, plus 6, and 3×3 square 95. The latest worst measured correction was Cave/Large/Confined seed 7026 at 121,711 µs with 4,851 one-time candidate evaluations.
- A separate 300-seed Dungeon/Confined audit (100 seeds per Scale) completed without failure and recorded 3,965 punches: single 318 (8.02%), lines 1,156 (29.16%), elbows 1,101 (27.77%), plus 61 (1.54%), and 3×3 square 1,329 (33.52%). Usage proves selection, not necessity; removal requires an ablation comparison.
- PreJudgementCull passes 16 focused threshold checks. Applied to the same 300 maps, 20 required RoomJudgement, one map culled one 1-cell room, and 279 bypassed judgement with no residual cull required.
- RoomJudgement passes 29 checks covering one-plus repair, connected offset two-plus repair, the five-coordinate limit, six-coordinate sunder, void and outer-edge rejection, source preservation, refusal behavior, and all 27 catalog combinations. Five generated fixtures required judgement and all returned one connected room. All preceding suites remain clean: Resolver 107, Base Geometry 63,793, Room Discovery 41,092, ConnectionCorrection 4,447, and PreJudgementCull 16.
- Rob visually accepted Cave/Large/Confined seed `9026` with RoomJudgement active and directed the Box to ship and close on 2026-09-24.
- `BaseGeometryDebug.tscn` executes headlessly without reported errors.
- All visually tested Dungeon seeds passed. All Cave variants passed visual testing. Tower Large and Medium passed; Tower Small/Confined remains a yellow pass pending later hole-punch confirmation.

Not yet established:

- Stable controller and final layout-result contracts; the resolver's concrete parameter-result contract is established.
- Reusable composition boundaries for later Local Map, POI, and town generators beyond the implemented layout components.
- Required input validation, failure behavior, and determinism guarantees.
- A runnable owner scene for `Tests/quarry_generator_test.gd`.
- Single-region output as a generator guarantee.
- Human acceptance of the later Room-level composed system and remaining Boxes.

The seed inspector currently requires an explicit harness path because its default filename is stale. A Python cache artifact created during validation remains retained because deletion was not authorized.

## Next Required Action

Open FinalGeometryValidation for design discussion and alignment. Its planned responsibility is to verify the final geometry-only result contract after RoomJudgement; implementation is not yet authorized.
