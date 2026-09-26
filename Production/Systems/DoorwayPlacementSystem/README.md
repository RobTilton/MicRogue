# Doorway Placement System
Updated: 2026-09-26

This Production system recognizes valid existing doorway openings in generator-owned floor geometry. It does not cut or mutate geometry and has no rendering or gameplay responsibility.

## Public Entry Point

```gdscript
var doorways: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(map_data)
```

The caller supplies valid `MapData` from the closed Map Generation pipeline. Results are returned in stable row-major greedy order. Each `DoorwayPlacement` contains the authoritative opening `coordinate` and its containing wall's `HORIZONTAL` or `VERTICAL` orientation.

This is an internal-only pipeline. “Public” identifies the system's exposed input/output surface inside that pipeline; it does not describe an untrusted external or commercial API. Doorway Placement trusts the generator-owned guarantees that `MapData` has valid dimensions, matching row-major cells, valid cell values, floor presence, and one cardinally connected floor region. It performs no defensive confirmation of those established invariants.

## Components

- `PackageAndSurface/`: public caller and typed doorway result.
- `Selection/`: floor gate, local snapshot matching, transformed geometry catalog, greedy ordering, and spacing.

## Contract

The selector scans floor cells in row-major order. A candidate gate requires one opposing floor pair and one opposing wall pair. The candidate's centered radius-3 snapshot must contain an approved doorway pattern. Nine canonical patterns generate their unique rotations and reflections; unlisted snapshot cells are wildcards. Accepted doorways must be at least three Manhattan tiles from the last accepted doorway.

The system does not alter `MapData`, place tiles or meshes, render doors, assign Zone ownership, or perform population, decoration, loot, persistence, or Central Controller work.

## Measured Performance

A 2026-09-26 headless benchmark timed only `DoorwayPlacer.place_doors()` across 50 freshly generated Cave/Large/Standard maps. The first pass was `3.400 ms`; 49 warm passes measured `2.401 ms` minimum, `3.880 ms` median, `4.378 ms` mean, `7.634 ms` p95, and `13.979 ms` maximum on the validation machine. Map generation was excluded. These values are evidence from one machine, not a platform-independent timing guarantee.

## Dependency And Portability

`DoorwayPlacementSystem/` depends only on the public `MapData` type supplied by `MapGenerationSystem/`. Copy both complete directories into a Godot 4 project and allow Godot to import their scripts before using the public entry point. No Layout Interpretation, Workshop, scene, renderer, autoload, Global, asset, or Micro Rogue gameplay dependency is required.

The durable AI-facing contract is [`Workshop/AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/DOORWAY_PLACEMENT_SYSTEM.md`](../../../Workshop/AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/DOORWAY_PLACEMENT_SYSTEM.md).
