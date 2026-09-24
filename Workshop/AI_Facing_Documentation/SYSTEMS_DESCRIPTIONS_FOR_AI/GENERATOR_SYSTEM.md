# Generator System Description
Updated: 2026-09-24
Checkpoint: `[GeneratorRoom]+[LayoutGeneration]+[RoomJudgement]`
Implementation baseline/evidence: Git `9cfce5ff6eebe2f1c7b1cecf6f7a31fd52b6059f` plus the GeneratorRoom directory reorganization

## Rapid Shape

The current generator system contains a working procedural dungeon-field prototype plus completed, human-accepted Generation Parameter Resolver, Base Geometry Generator, Room Discovery, ConnectionCorrection, PreJudgementCull, and RoomJudgement components.

```text
prototype scene caller
    -> DungenGeneratorFrontier
        -> field Dictionary
    -> DungeonRenderer
        -> GridMap cells
```

The system is unfinished. It does not yet integrate resolved parameters into the base generator or implement the intended reusable controller, final layout-result contract, Global Maps, Local Maps, general POIs, towns, initial 3×3 generation, lazy frontier expansion, or persistence integration.

The approved direction is modular, encapsulated, compositional, and reusable. Later scoped work must be able to add generators without coupling their behavior into a one-off universal implementation. Illustrative calls such as `create_new_poi(CAVE, MEDIUM)` and `create_new_local(biome, world_coord)` describe the desired consumer boundary; they are not approved API signatures.

## Current Locations And Ownership

| Owner | Responsibility |
|---|---|
| [`GenerationParameterResolver/`](../../Rooms/GeneratorRoom/LayoutGeneration/GenerationParameterResolver/) | Typed Inspector catalog, semantic request validation, profile merge rules, and detached concrete parameter results. |
| [`BaseGeometryGenerator/`](../../Rooms/GeneratorRoom/LayoutGeneration/BaseGeometryGenerator/) | Typed bounded geometry generation, taxation, safe boundary planning, square/circular/compound-circle wrapping, and F6 debug scene. |
| [`RoomDiscoveryFill/`](../../Rooms/GeneratorRoom/LayoutGeneration/RoomDiscoveryFill/) | Typed cardinal floor-room discovery with explicitly optional immediate frontier-wall collection. |
| [`ConnectionCorrection/`](../../Rooms/GeneratorRoom/LayoutGeneration/ConnectionCorrection/) | Typed supplied punch patterns, iterative inexpensive connection correction, fresh-room return, and correction evidence. |
| [`PreJudgementCull/`](../../Rooms/GeneratorRoom/LayoutGeneration/PreJudgementCull/) | Typed two-stage residual-room culling and explicit RoomJudgement gating. |
| [`RoomJudgement/`](../../Rooms/GeneratorRoom/LayoutGeneration/RoomJudgement/) | Typed substantial-room save-or-sunder repair using bounded plus punches and maintained region data. |
| [`dungeon_generator_frontier.gd`](../../Rooms/GeneratorRoom/DungeonGeneration/dungeon_generator_frontier.gd) | Generation, field transformation, connectivity analysis, and repair. |
| [`dun_gen_frontier_caller.gd`](../../Rooms/GeneratorRoom/DungeonGeneration/dun_gen_frontier_caller.gd) | Prototype startup and hard-coded generation request. |
| [`dungeon_renderer.gd`](../../Rooms/GeneratorRoom/DungeonGeneration/dungeon_renderer.gd) | Translation from cell values to `GridMap` items. |
| [`DunGenFrontier.tscn`](../../Rooms/GeneratorRoom/DungeonGeneration/DunGenFrontier.tscn) | Runnable caller, renderer, mesh-library, and camera composition. |
| [`GeneratorTestLibrary.tres`](../../Rooms/GeneratorRoom/Assets/DunGenMeshLibrary/GeneratorTestLibrary.tres) | Prototype floor, wall, and debug meshes. |
| [`frontier_harness.py`](../../Rooms/GeneratorRoom/Scripts/frontier_harness.py) | Independent Python stress-test and comparison harness. |
| [`frontier_seed_inspector.py`](../../Rooms/GeneratorRoom/Scripts/frontier_seed_inspector.py) | Single-seed text inspection. |
| [`quarry_generator_test.gd`](../../Rooms/GeneratorRoom/Tests/quarry_generator_test.gd) | Example composition of crop, boundary, repair, and largest-region operations. |

Python tooling reproduces related logic independently. It is evidence and inspection infrastructure, not a runtime dependency.

## Generation Parameter Resolver

Entry catalog: [`starter_generation_catalog.tres`](../../Rooms/GeneratorRoom/LayoutGeneration/GenerationParameterResolver/starter_generation_catalog.tres).

Every request must explicitly select one supported value from each axis:

- Archetype: Dungeon, Tower, or Cave.
- Scale: Small, Medium, or Large.
- Geometry Modifier: Exposed, Standard, or Confined.

`Standard` is an explicit identity profile, not a default. Missing, unsupported, duplicate, incomplete, or invalid catalog/request data returns a `GenerationResolution` failure whose message identifies the resolver source path. The resolver performs no geometry generation.

Catalog ownership:

- Archetype owns geometry strategy, base radii, radius-change buffer, and base taxation ratio.
- Scale owns raw-field size, cut-window radius, room count, maximum-radius adjustment, and taxation multiplier.
- Geometry Modifier owns its maximum-radius adjustment and taxation multiplier.
- Resolver code owns validation and merge rules.

The output is a detached `ResolvedGenerationParameters` snapshot containing raw-field size, cut-window radius and derived output size, room count, geometry strategy, resolved minimum/maximum radii, concrete taxation interval, and the provisional-room-count flag.

All three starter Archetypes use the same base room-radius range of `4–12`. Maximum-radius adjustments are additive. Cave retains its one-point buffer, reducing the magnitude of every individual maximum-radius adjustment by one; it does not impose a smaller base room range. Minimum radius remains fixed at the Archetype's base minimum and is never changed by Scale or Geometry Modifier; maximum cannot resolve below it. Tax multipliers compose multiplicatively; the interval is calculated from room count × Archetype ratio × Scale multiplier × Modifier multiplier, rounded once, and clamped to at least `1`.

Small and Large room counts (`44` and `176`) are provisional test-calibration values. Medium uses the `100`-room baseline. Calibration can update this Inspector data without changing resolver logic.

## Base Geometry Generator

Entry scene for visual testing: [`BaseGeometryDebug.tscn`](../../Rooms/GeneratorRoom/LayoutGeneration/BaseGeometryGenerator/BaseGeometryDebug.tscn).

The component accepts only `ResolvedGenerationParameters`. It validates the complete request before mutation, creates an oversized `GeometryField`, stamps rectangular rooms, selects a safe random cut window, applies the resolved boundary strategy, and returns only the bounded field.

`GeometryField` owns a `Vector2i` size and row-major `PackedInt32Array` using `VOID = 0`, `FLOOR = 1`, and `WALL = 2`. No semantic labels, seed, rooms, doors, entrances, actors, or persistence data are returned.

Generated room diameter is `(room_radius × 2) - 1`. X/Y radii are selected independently. Later room stamps fully overwrite earlier cell values, preserving prototype behavior.

Taxation uses the concrete interval produced by the resolver. Rooms `1..interval` use the resolved maximum radius; the maximum falls by one for each completed interval and never below the resolved minimum.

Dungeon/Tower cut selection computes the valid center range before selecting a coordinate and preserves one raw cell outside every cut edge. Invalid inputs refuse without partial output. Square wrapping overwrites the output perimeter as wall. Circular wrapping changes cells outside the radius to void and makes the inner circular edge wall.

All three Archetypes share the same rectangular raw generation. Dungeon selects a square boundary and Tower selects a circular boundary. Cave selects a compound-circle boundary without changing room stamping.

Cave uses 4/5/6 circles for Small/Medium/Large. Its circle radius is derived by integer-halving the Scale cut-window radius, producing radii 5/7/10. The planner randomly chooses a starting long-axis side and a safe position on that side, aims the chain through the raw-field center, and requires at least 20% diameter overlap rounded up to whole cells. Circle placement applies a perpendicular-only bounded random walk: each noise step changes by `-1`, `0`, or `+1`, and total displacement remains within ±3 of the baseline. Safety and overlap are validated while placing each circle.

If no next circle can be placed, the valid partial chain is preserved. The wrapper unions the valid circle masks, calculates their bounds, expands by one cell, crops the raw field, converts every cell outside the union and every untouched void inside it to wall, and walls the union's inner perimeter. The returned Cave field is a variable-sized rectangle containing only floor and wall cells.

Production generation owns internal randomized RNG state. `generate_with_rng()` permits deterministic injected RNG for testing without establishing a production seed contract. The F6 debug caller exposes optional fixed-seed controls strictly for reproducible visual inspection and defaults to Cave/Medium/Standard during the Cave validation checkpoint.

## Room Discovery Fill

Entry point: `RoomDiscoveryFill.discover(field, include_frontier_walls)`.

The component trusts the closed internal `GeometryField` contract and performs only a null refusal. It does not defensively revalidate or copy Base Geometry output. Discovery scans row-major and uses cardinal connectivity only, giving each discovered room a stable zero-based ID in first-floor encounter order.

Each typed `DiscoveredRoom` contains:

- `id: int`.
- `floor_cells: Array[Vector2i]`, containing the complete connected floor footprint.
- `frontier_walls: Array[Vector2i]`, containing unique cardinally adjacent wall coordinates when explicitly requested.

`RoomDiscoveryResult` contains the typed room array, `frontier_walls_included`, and an error message. Calling discovery with `include_frontier_walls = false` skips frontier collection and returns empty frontier arrays. A valid map with no floor succeeds with zero rooms.

The optional frontier contract is provisional for ConnectionCorrection testing. Shared wall coordinates intentionally appear in every bordering room's frontier and identify inexpensive opening candidates. Discovery does not choose openings, build hallways, modify geometry, or construct an ownership-label array. ConnectionCorrection directly maintains the room data affected by its own mutations rather than invoking discovery again. Rob accepted and checkpoint-tagged this contract on 2026-09-24, explicitly retaining permission to revisit frontier collection if Box 4 proves it wasteful.

## Connection Correction

Entry point: `ConnectionCorrection.correct(field, discovery, patterns)`. Inputs are a bounded field, successful Room Discovery with frontier walls, and an explicitly supplied typed pattern array. The standard catalog contains single, horizontal/vertical three-cell lines, four three-cell elbows, plus, and 3×3 square: nine orientations total.

Correction copies the input field and never mutates the source. It deduplicates frontier-wall centers, builds a temporary floor-coordinate ownership lookup, and evaluates every supplied pattern at every center exactly once. Candidates crossing bounds, touching the map's outer edge, changing void, mutating no wall, or failing to touch at least two distinct rooms are rejected.

Candidates are ranked by most distinct rooms connected, fewest wall cells mutated, smallest pattern, lowest Y, lowest X, then catalog order. They are processed once in that order. A candidate is skipped when its rooms have already merged; every accepted punch reduces the room count. ConnectionCorrection changes the punch cells to floor, directly merges the affected rooms' floor/frontier data, removes opened walls, adds newly exposed local frontier walls, and updates coordinate ownership. It performs no flood fill.

`ConnectionCorrectionResult` returns copied corrected geometry, directly maintained post-correction rooms with floor/frontier data intact, typed applied-punch records, candidate-evaluation and mutated-cell totals, and per-pattern usage. It performs no long-route search or hallway construction; those remain RoomJudgement authority.

`BaseGeometryDebug.tscn` exposes `apply_connection_correction`, defaulting to enabled. With `use_fixed_seed`, the same generated field can be viewed before and after correction by toggling only this setting.

## Entry Points And Flow

### Prototype Scene

On `_ready()`, the caller randomizes a seed and requests a `91 × 61` field with 100 room stamps and X/Y radius bounds of 4 through 17. It passes the returned field directly to the renderer.

The renderer clears its `GridMap`, skips void cells, places mesh item `0` for floor, and places mesh item `1` for wall.

### Dungeon Generation

`DungenGeneratorFrontier.generate_dungeon()`:

1. Creates a local RNG using the supplied seed.
2. Allocates a row-major `PackedInt32Array` filled with void.
3. Repeatedly chooses in-bounds rectangular rooms.
4. Shrinks each random radius ceiling by iteration until its minimum is reached.
5. Writes each rectangle perimeter as wall and its interior as floor; later stamps overwrite earlier values.
6. Applies cardinal-cross repair.
7. Returns the repaired field dictionary.

The live registered class name is spelled `DungenGeneratorFrontier`. Consumers must preserve that spelling until a separately authorized migration changes it.

### Connectivity Repair

Repair copies the field, finds cardinally connected floor regions, labels them, and collects adjacent wall cells. It evaluates the supplied stamp at candidate wall centers and accepts candidates touching at least two original regions.

Candidate priority is most regions touched, least void destroyed, least total non-floor material destroyed, lowest Y, then lowest X. At most one selected stamp is applied for each original region, and duplicate centers are rejected. Selection uses the original labels rather than recomputing connectivity after every mutation. The current cross is the center plus its four cardinal neighbors.

Repair returns the copied field plus stamp, mutation, and candidate counts. `generate_dungeon()` currently returns only the field.

### Other Transformations

- `crop_window()` copies an asserted in-bounds window.
- `seal_boundary()` mutates outer-edge cells to wall.
- `repair_with_shape()` accepts a caller-supplied stamp.
- `keep_largest_region()` copies the field and changes floors outside the largest region to walls.
- `find_floor_regions()` returns cardinally connected floor-cell arrays.
- `field_to_ascii()` serializes void, floor, and wall as `0`, `.`, and `#`.

## Component Contracts

### Field Dictionary

| Key | Type | Contract |
|---|---|---|
| `width` | `int` | X-axis cell count. |
| `height` | `int` | Y-axis cell count. |
| `cells` | `PackedInt32Array` | Row-major storage at `y * width + x`. |
| `seed` | `int` | Seed when preserved by the producer. |

`crop_window()` additionally returns `source_origin` and `source_seed`. Metadata is not consistent across transformations, and no typed result owner or schema validator exists.

### Cell Encoding And Renderer Coupling

| Value | Generator meaning | Renderer behavior |
|---:|---|---|
| `0` | `VOID` | No mesh. |
| `1` | `FLOOR` | Mesh item `0`. |
| `2` | `WALL` | Mesh item `1`. |

The generator and renderer independently declare these values. The renderer also assumes mesh IDs floor `0`, wall `1`, and debug `2`. Until this coupling has a shared owner, changes require composed generator-and-renderer validation.

### Mutation And Input Boundaries

- `seal_boundary()` mutates the supplied cell array.
- Generation creates a new field.
- Repair and largest-region filtering operate on copies.
- The renderer mutates only its `GridMap`.
- The caller orchestrates but does not own persistence.

Generation is deterministic for identical valid parameters and seed. The randomized prototype caller does not expose its seed. Public inputs are not comprehensively validated; dimensions and radii must permit valid origins, and field dictionaries must contain the expected keys, types, dimensions, and cell count.

### Intended Controller Boundary — Not Implemented

The controller is intended to accept validated requests/settings, coordinate generator modules, shield callers from internal algorithms, and return a defined result. API names, settings ownership, result types, module composition, mutation rules, errors, and determinism guarantees remain unresolved.

Generation and persistence are separate responsibilities: a generator produces a result; the world owner decides how it becomes persistent state.

## Required Outside Data

- Godot 4.4 with Forward Plus.
- [`GeneratorTestLibrary.tres`](../../Rooms/GeneratorRoom/Assets/DunGenMeshLibrary/GeneratorTestLibrary.tres) for prototype rendering.
- Python 3 for research/evidence tooling.
- [`Scope_Defined.md`](../../Rooms/Project_Core_Documentation/Scope_Defined.md) for completed-game requirements.
- [`GeneratorRoom/CurrentState.md`](../../Rooms/GeneratorRoom/CurrentState.md) for immediate readiness and next action.

The GDScript core otherwise uses Godot built-in types.

## Validation And Current Limits

[`frontier_results.csv`](../../Rooms/GeneratorRoom/Tests/Evidence/FrontierHarness/frontier_results.csv) contains 10,000 recorded Python-harness seed rows at `121 × 41`, 100 room stamps, and radii 5 through 15. It compares cardinal-cross repair with a full 3×3 stamp.

On 2026-09-23, seed `4434` remained reproducible: 83 raw regions became 2 cross-repaired regions using 67 stamps and 197 mutated cells. Godot 4.4.1 also imported, loaded, and executed the reorganized prototype scene headlessly without reported errors.

On 2026-09-24, [`generation_parameter_resolver_test.gd`](../../Rooms/GeneratorRoom/Tests/GenerationParameterResolver/generation_parameter_resolver_test.gd) passed 107 checks covering all 27 starter combinations, representative resolved values, Cave buffering, percentage-based taxation, detached results, required request values, duplicate/missing profiles, invalid catalog data, explicit Standard identity, and the corrected separation of room-generation strategy from boundary strategy. The existing dungeon prototype also passed a headless regression execution after resolver and Base Geometry integration.

On 2026-09-24, [`base_geometry_generator_test.gd`](../../Rooms/GeneratorRoom/Tests/BaseGeometryGenerator/base_geometry_generator_test.gd) passed 63,793 checks after Cave's base room range was normalized to `4–12`. Coverage includes all supported catalog combinations, taxation, fixed minimum radius, Dungeon/Tower regression, Cave circle counts and radii, randomized safe starting sides/positions, center crossing, 20% overlap rounding, bounded perpendicular noise, one-cell union expansion, floor/wall-only Cave output, deterministic seeded generation, and valid partial-chain preservation. The Cave-default debug scene and existing prototype scene both executed headlessly without error.

On 2026-09-24, [`room_discovery_fill_test.gd`](../../Rooms/GeneratorRoom/Tests/RoomDiscoveryFill/room_discovery_fill_test.gd) passed 41,092 checks covering cardinal partitioning, diagonal separation, deterministic ordering, empty-floor success, null refusal, input non-mutation, optional and shared frontier walls, uniqueness, complete floor coverage, and composition across all 27 generated catalog combinations. Resolver and Base Geometry regressions remained clean at 107 and 63,793 checks.

On 2026-09-24, [`connection_correction_test.gd`](../../Rooms/GeneratorRoom/Tests/ConnectionCorrection/connection_correction_test.gd) passed 4,447 checks covering the nine standard orientations, minimal-destruction and maximum-connection ranking, direct room/frontier maintenance, void/outer-edge/source preservation, deliberately unresolved geometry, and all 27 generated catalog combinations. Generated usage was single 32, lines 82, elbows 98, plus 6, and 3×3 square 95. The latest worst measured correction was Cave/Large/Confined seed 7026 at 121,711 µs with 4,851 one-time candidate evaluations. The suite now enforces a 250 ms per-map ceiling in this environment.

[`hole_punch_selection_audit.gd`](../../Rooms/GeneratorRoom/Tests/ConnectionCorrection/hole_punch_selection_audit.gd) ran 300 Dungeon/Confined maps on 2026-09-24: seeds 0–99 for each Scale. All maps completed. Across 3,965 punches, family usage was single 318 (8.02%, present in 56.00% of maps), line 1,156 (29.16%, 97.33% of maps), elbow 1,101 (27.77%, 96.33% of maps), plus 61 (1.54%, 18.00% of maps), and 3×3 square 1,329 (33.52%, 99.00% of maps). Orientation counts were horizontal line 604, vertical line 552, right-down elbow 949, right-up elbow 75, left-down elbow 73, left-up elbow 4. Selection frequency does not establish necessity; removing a pattern requires a same-seed ablation comparison of residual rooms and geometry cost.

Rob visually accepted ConnectionCorrection for closure on 2026-09-24. In particular, the 3×3 pattern's 33.52% usage produced no visually objectionable or readily identifiable destructive artifacts across the reviewed maps; its unobtrusive high usage was accepted as evidence that the local correction blended successfully into generated geometry.

## Pre-Judgement Cull

`PreJudgementCull.apply(field, rooms)` preserves the largest room unconditionally. Let `N` be its floor count and `S` the combined lesser-room floor count. If `S > 15% of N`, all rooms survive and judgement is required. If `S <= 15% of N`, each lesser room owning below 40% of `S` is converted entirely to wall; exact 40% survives. Judgement is required only when a lesser room survives. Comparisons use integer multiplication, not floating-point thresholds. The helper copies geometry, uses maintained room data, and performs no flood fill or route work.

Focused threshold tests passed 16 checks. In the 300-seed Dungeon/Confined audit, 20 maps required judgement, one map culled one 1-cell room, and 279 bypassed judgement without culling. The debug scene exposes `apply_pre_judgement_cull` for visual comparison.

Rob accepted and closed PreJudgementCull on 2026-09-24. The 20 maps retaining substantial residual rooms were accepted as sufficient evidence that RoomJudgement has a real required responsibility.

## Room Judgement

`RoomJudgement.judge(field, rooms)` consumes the copied post-cull field and substantial surviving room data. The largest room becomes the main region. Every other room is processed largest-first and receives exactly one disposition: save it into the main region or sunder its complete floor footprint into wall.

Judgement uses only one or two plus-shaped punches. A valid one-plus route is preferred. Two pluses may be cardinally connected with a perpendicular offset; together they must provide a route through no more than five wall coordinates. Six or more wall coordinates require sunder. Candidate ordering then prefers shorter wall distance, fewer total wall mutations, and stable coordinate order. Any punch touching void or the sealed outer edge is rejected.

Saved rooms and newly opened floor cells are merged directly into the maintained main room and its frontier data. Sundered rooms are removed without a replacement flood fill. RoomJudgement performs no A*, arbitrary hallway search, or defensive reconstruction of already contracted input. `RoomJudgementResult` returns copied corrected geometry, one maintained main-room record, saved and sundered room counts, punch count, and failure state.

The debug caller exposes `apply_room_judgement`, defaulting to enabled after correction and pre-judgement culling. The focused and generated suite passes 29 checks. It covers one-plus and offset two-plus saves, the six-coordinate sunder boundary, void and outer-edge rejection, source preservation, refusal behavior, and all 27 catalog combinations; five generated fixtures required judgement and all ended as one connected floor region. Rob visually accepted Cave/Large/Confined seed `9026` and closed RoomJudgement on 2026-09-24.

This supports the current prototype and its dependencies. It does not establish Python/GDScript equivalence, complete Room acceptance, production performance, the future controller contract, or world/Local Map/POI/town generation.

## Final Validation Disposition

The planned standalone FinalGeometryValidation stage is superseded. MCA requires the pipeline to preserve correctness by construction: Base Geometry owns valid bounded cell topology and sealing; read-only discovery preserves it; ConnectionCorrection and RoomJudgement reject void and outer-edge punches; PreJudgementCull and sunder behavior only convert floor to wall; and RoomJudgement resolves every substantial residual region into the maintained main room or removes its floor footprint.

GenerationController must trust these typed component contracts. It must not add a runtime post-hoc geometry validator or duplicate final-geometry test pass. Invariant tests remain with the components that own the relevant mutations, while controller evidence is limited to correct composition, request/result behavior, catalog traversal, and human visual acceptance.

Human visual evidence recorded on 2026-09-24: all tested Dungeon seeds passed; all Cave Scale/Modifier variants passed; Tower Large and Medium passed; Tower Small/Confined was accepted as a yellow pass, with possible hole-punch improvement deferred to later connectivity/judgment work. Rob subsequently declared Base Geometry ready for closure, completing the Box.

Current preservation limits:

- Cross repair reduces fragmentation but does not guarantee one region.
- The renderer duplicates cell values and assumes fixed mesh IDs.
- The caller hard-codes settings and renders directly.
- The dictionary boundary is untyped with inconsistent metadata.
- The GDScript test has no retained runnable owner scene.
- The seed inspector's default harness filename is stale; it needs an explicit `--harness` path.

[`GeneratorRoom/DOTS.md`](../../Rooms/GeneratorRoom/DOTS.md) defines the required compositional Boxes and dependencies. RoomJudgement implementation, automated validation, human visual acceptance, and closure are complete. FinalGeometryValidation is superseded; GenerationController is next eligible but not yet opened.
