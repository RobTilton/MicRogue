# Generator System Description
Updated: 2026-09-24
Checkpoint: `[GeneratorRoom]+[LayoutGeneration]+[BaseGeometryGenerator]`
Implementation baseline/evidence: Git `9cfce5ff6eebe2f1c7b1cecf6f7a31fd52b6059f` plus the GeneratorRoom directory reorganization

## Rapid Shape

The current generator system contains a working procedural dungeon-field prototype, a completed semantic Generation Parameter Resolver, and a typed Base Geometry Generator awaiting human visual validation. Base Geometry consumes resolved parameters, creates oversized rectangular-room topology, applies interval taxation, then internally cuts and wraps a bounded Dungeon or Tower result.

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
| [`BaseGeometryGenerator/`](../../Rooms/GeneratorRoom/LayoutGeneration/BaseGeometryGenerator/) | Typed bounded floor/wall generation, taxation, safe window selection, square/circular wrapping, explicit Cave refusal, and F6 debug scene. |
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

Maximum-radius adjustments are additive. Cave reduces the magnitude of every individual maximum-radius adjustment by one. Minimum radius remains fixed at the Archetype's base minimum and is never changed by Scale or Geometry Modifier; maximum cannot resolve below it. Tax multipliers compose multiplicatively; the interval is calculated from room count × Archetype ratio × Scale multiplier × Modifier multiplier, rounded once, and clamped to at least `1`.

Small and Large room counts (`44` and `176`) are provisional test-calibration values. Medium uses the `100`-room baseline. Calibration can update this Inspector data without changing resolver logic.

## Base Geometry Generator

Entry scene for visual testing: [`BaseGeometryDebug.tscn`](../../Rooms/GeneratorRoom/LayoutGeneration/BaseGeometryGenerator/BaseGeometryDebug.tscn).

The component accepts only `ResolvedGenerationParameters`. It validates the complete request before mutation, creates an oversized `GeometryField`, stamps rectangular rooms, selects a safe random cut window, applies the resolved boundary strategy, and returns only the bounded field.

`GeometryField` owns a `Vector2i` size and row-major `PackedInt32Array` using `VOID = 0`, `FLOOR = 1`, and `WALL = 2`. No semantic labels, seed, rooms, doors, entrances, actors, or persistence data are returned.

Generated room diameter is `(room_radius × 2) - 1`. X/Y radii are selected independently. Later room stamps fully overwrite earlier cell values, preserving prototype behavior.

Taxation uses the concrete interval produced by the resolver. Rooms `1..interval` use the resolved maximum radius; the maximum falls by one for each completed interval and never below the resolved minimum.

Cut selection computes the valid center range before selecting a coordinate and preserves one raw cell outside every cut edge. Invalid inputs refuse without partial output. Square wrapping overwrites the output perimeter as wall. Circular wrapping changes cells outside the radius to void and makes the inner circular edge wall.

Dungeon and Tower share rectangular raw generation. Dungeon selects a square boundary; Tower selects a circular boundary. Cave's compound-circle boundary is pinned and explicitly refused until separately designed.

Production generation owns internal randomized RNG state. `generate_with_rng()` permits deterministic injected RNG for testing without establishing a production seed contract.

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

This supports the current prototype and its dependencies. It does not establish Python/GDScript equivalence, visual acceptance, a single-region guarantee, production performance, the future controller contract, or world/Local Map/POI/town generation.

Current preservation limits:

- Cross repair reduces fragmentation but does not guarantee one region.
- The renderer duplicates cell values and assumes fixed mesh IDs.
- The caller hard-codes settings and renders directly.
- The dictionary boundary is untyped with inconsistent metadata.
- The GDScript test has no retained runnable owner scene.
- The seed inspector's default harness filename is stale; it needs an explicit `--harness` path.

[`GeneratorRoom/DOTS.md`](../../Rooms/GeneratorRoom/DOTS.md) defines the required compositional Boxes and dependencies. Base Geometry implementation and automated checks are complete; human F6 visual validation remains required before the Box can close. No further Box implementation is currently authorized.
