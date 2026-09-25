# Map Generation System
Updated: 2026-09-25
Status: Production; GeneratorRoom closed
Runtime authority: [`Production/Systems/MapGenerationSystem/`](../../../Production/Systems/MapGenerationSystem/)

## Public Contract

The system is a portable, game-agnostic Godot layout generator. Ordinary consumers use one entry point:

```gdscript
var map_data: MapData = GeneratorCaller.make_map(
	MapParameters.new(
		GenerationSemantics.Archetype.CAVE,
		GenerationSemantics.Scale.LARGE,
		GenerationSemantics.GeometryModifier.CONFINED
	)
)
```

All three semantic values are mandatory. `Standard` is explicit and is never inferred. Supported values are:

- Archetype: Dungeon, Tower, Cave.
- Scale: Small, Medium, Large.
- Geometry Modifier: Exposed, Standard, Confined.

A successful call returns detached `MapData` containing `width`, `height`, and row-major `cells`. The authoritative cell legend is `ABYSS = 0`, `FLOOR = 1`, and `WALL = 2`; `cell_legend()` exposes the same mapping. Failure is loud, returns `null`, and never returns partial data.

Production randomness is internal. The public contract exposes no seed or reproducibility guarantee.

## Composition

```text
GeneratorCaller.make_map(MapParameters)
	-> StarterGenerationCatalog
	-> GenerationParameterResolver
	-> BaseGeometryGenerator
	-> RoomDiscoveryFill
	-> ConnectionCorrection
	-> PreJudgementCull
	-> RoomJudgement only when required
	-> MapData
```

`GenerationController` owns this order but none of the component internals. It trusts their typed contracts and does not perform a duplicated post-hoc validation pass.

| Production owner | Responsibility |
|---|---|
| [`GenerationController/`](../../../Production/Systems/MapGenerationSystem/GenerationController/) | Public request/result boundary and pipeline composition. |
| [`GenerationParameterResolver/`](../../../Production/Systems/MapGenerationSystem/GenerationParameterResolver/) | Code-owned starter catalog, semantic validation, profile merging, and concrete parameter resolution. |
| [`BaseGeometryGenerator/`](../../../Production/Systems/MapGenerationSystem/BaseGeometryGenerator/) | Rectangular room stamping, taxation, safe boundary selection, cut, and wrap. |
| [`RoomDiscoveryFill/`](../../../Production/Systems/MapGenerationSystem/RoomDiscoveryFill/) | Cardinal floor-region discovery and optional frontier-wall collection. |
| [`ConnectionCorrection/`](../../../Production/Systems/MapGenerationSystem/ConnectionCorrection/) | Cheap local hole-punch correction and direct room/frontier maintenance. |
| [`PreJudgementCull/`](../../../Production/Systems/MapGenerationSystem/PreJudgementCull/) | Cheap residual-room filtering and RoomJudgement gating. |
| [`RoomJudgement/`](../../../Production/Systems/MapGenerationSystem/RoomJudgement/) | Bounded save-or-sunder disposition for substantial residual rooms. |

## Parameter Resolution

Archetype owns boundary strategy, base radii, radius-change buffer, and base taxation ratio. Scale owns raw-field size, cut-window radius, room count, maximum-radius adjustment, and taxation multiplier. Geometry Modifier owns maximum-radius adjustment and taxation multiplier.

All Archetypes use base room radii `4–12`. Cave buffers each individual maximum-radius adjustment by one. Minimum radius remains fixed; maximum adjustments are additive. Taxation multipliers compose multiplicatively, are rounded once into an interval, and clamp to at least one.

Starter Scale data:

| Scale | Raw field | Cut radius | Room count | Max-radius adjustment | Tax multiplier |
|---|---:|---:|---:|---:|---:|
| Small | `41 × 31` | `10` | `44` | `-2` | `0.9` |
| Medium | `91 × 63` | `15` | `100` | `0` | `1.0` |
| Large | `141 × 95` | `20` | `176` | `+2` | `1.1` |

Small and Large room counts remain provisional calibration values. Changes belong in `StarterGenerationCatalog`; resolver logic should not absorb calibration data.

Modifier data:

| Modifier | Max-radius adjustment | Tax multiplier |
|---|---:|---:|
| Exposed | `+2` | `1.1` |
| Standard | `0` | `1.0` |
| Confined | `-2` | `0.9` |

## Geometry Behavior

Room diameter is `(radius × 2) - 1`; X and Y radii are selected independently. Later stamps overwrite earlier cells. Taxation lowers the active maximum radius by one after each resolved interval and never below the minimum.

Dungeon uses a square cut and sealed wall perimeter. Tower uses a circular boundary with abyss outside its inner wall edge. Cave uses 4/5/6 overlapping circles for Small/Medium/Large, radii 5/7/10, at least 20% diameter overlap, a random starting long-axis side, center-directed progress, and perpendicular-only bounded noise within ±3. Cave preserves a valid partial chain if continuation fails, crops the union with a one-cell margin, and walls cells outside the union.

`GeometryField` stores `Vector2i size` plus a row-major `PackedInt32Array`. Internal values are `VOID = 0`, `FLOOR = 1`, and `WALL = 2`.

## Connectivity Behavior

Room Discovery scans row-major using cardinal connectivity. Each `DiscoveredRoom` owns its complete floor footprint and, when requested, unique cardinally adjacent frontier walls. Shared walls may appear in multiple room frontiers. Discovery does not mutate geometry.

ConnectionCorrection evaluates the standard single, horizontal/vertical line, four elbow, plus, and 3×3 patterns. Candidates touching void or the outer edge are rejected. Ranking prefers most rooms connected, fewest wall mutations, smallest pattern, stable coordinates, then catalog order. Accepted punches directly merge maintained room/frontier data without another flood fill.

PreJudgementCull always preserves the largest room. Let `N` be its floor count and `S` the combined lesser-room floor count. If `S > 15% of N`, all lesser rooms pass to judgement. Otherwise, each lesser room below 40% of `S` becomes wall; exact 40% survives. Judgement runs only when a lesser room survives.

RoomJudgement prefers one plus punch for eligible short separations. It may use two cardinally connected plus punches with a perpendicular offset for routes through no more than five wall coordinates. Six or more requires sunder. Invalid routes, void contact, and outer-edge contact also sunder the residual room. Saved rooms merge directly into the main room; sundered floor footprints become wall. No A*, arbitrary hallway search, or replacement flood fill is performed.

## Responsibility Boundary

This system returns geometry only. It knows nothing about games, biomes, POI families, doors, entrances, tiles, painting, meshes, rendering, actors, population, loot, persistence, world state, or player knowledge. Upstream systems choose the explicit semantic request; downstream systems decide how `MapData` is used.

The runtime directory has no scene, renderer, asset, autoload, Global, Workshop, or Micro Rogue gameplay dependency. Its catalog is constructed in code, and its only preload is local. Copy the complete `MapGenerationSystem/` directory into another Godot 4 project and allow Godot to import it. The package-local [`README.md`](../../../Production/Systems/MapGenerationSystem/README.md) carries this usage contract.

## Final Validation Disposition

The planned FinalGeometryValidation component was superseded. Correctness is preserved by construction: Base Geometry establishes bounded topology; discovery is read-only; correction and judgement reject abyss and outer-edge punches; cull and sunder only convert floor into wall; judgement connects or removes every substantial residual room. The controller does not repeat those guarantees at runtime.

## Acceptance Evidence

Before Room disposal, the final suites passed:

- Parameter Resolver: 107 checks.
- Base Geometry: 63,793 checks.
- Room Discovery: 41,092 checks.
- ConnectionCorrection: 4,447 checks; final measured maximum `119,411 µs` and 4,851 candidate evaluations.
- PreJudgementCull: 16 checks.
- RoomJudgement: 29 checks.
- GenerationController: 90 checks across all 27 semantic combinations, detached output, cell legend, loud failure, and no-partial-result behavior.

The 300-map Dungeon/Confined audit completed successfully and exercised all correction-pattern families. Twenty maps required RoomJudgement. Rob visually accepted RoomJudgement using Cave/Large/Confined seed `9026`, then visually accepted the public GenerationController result.

Promotion was verified in three ways:

1. The controller suite and accepted visual entry point passed after the runtime moved to Production.
2. Only `MapGenerationSystem/` was copied into an isolated Godot project at a different project and filesystem path; `make_map(CAVE, LARGE, CONFINED)` returned valid `MapData`.
3. After GeneratorRoom removal, the main project imported cleanly enough to register the Production classes, and `make_map(DUNGEON, SMALL, STANDARD)` returned a `21 × 21` map with 441 cells. The editor reported only a stale local-layout reference to the deleted debug scene; runtime generation had no missing dependency.

GeneratorRoom, DOTS, current-state documentation, development tests, prototypes, research scripts, retained evidence, and related discarded concept files were removed after successful Production validation. `MapGenerationSystem/` is the sole runtime authority. This document is the sole retained Workshop authority for the system.
