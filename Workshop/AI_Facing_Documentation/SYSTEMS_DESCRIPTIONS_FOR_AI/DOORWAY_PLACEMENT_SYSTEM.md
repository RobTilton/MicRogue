# Doorway Placement System
Updated: 2026-09-26
Runtime authority: [`Production/Systems/DoorwayPlacementSystem/`](../../../Production/Systems/DoorwayPlacementSystem/)

## Rapid Shape

Doorway Placement identifies approved existing openings in generator-owned floor geometry. It does not cut geometry. The system scans floor cells in stable row-major order, cheaply identifies possible wall crossings, validates local geometry, greedily applies spacing, and returns ordered doorway coordinates with wall orientation.

The pipeline is closed, encapsulated, and internal-only. Doorway Placement trusts the complete `MapData` contract established by Map Generation and does not repeat upstream validation.

## Current Locations And Structure

| Production owner | Responsibility |
|---|---|
| [`PackageAndSurface/doorway_placer.gd`](../../../Production/Systems/DoorwayPlacementSystem/PackageAndSurface/doorway_placer.gd) | Exposed internal entry point and composition. |
| [`PackageAndSurface/doorway_placement.gd`](../../../Production/Systems/DoorwayPlacementSystem/PackageAndSurface/doorway_placement.gd) | Typed coordinate/orientation result. |
| [`Selection/doorway_selection_pass.gd`](../../../Production/Systems/DoorwayPlacementSystem/Selection/doorway_selection_pass.gd) | Gate, snapshot, transformed catalog, greedy order, and spacing. |
| [`README.md`](../../../Production/Systems/DoorwayPlacementSystem/README.md) | Package-local usage and dependency contract. |

## Entry Point And Flow

```gdscript
var doorways: Array[DoorwayPlacement] = DoorwayPlacer.place_doors(map_data)
```

```text
valid generator-owned MapData
	-> row-major floor scan
	-> opposing-pair gate
	-> centered radius-3 snapshot
	-> transformed required-wall match
	-> last-accepted-door spacing
	-> ordered Array[DoorwayPlacement]
```

`DoorwayPlacer` directly delegates to `DoorwaySelectionPass`. It does not confirm nullability, dimensions, cell count, cell values, floor presence, or connectivity because those are established upstream invariants.

## Component Contracts

### Candidate gate

Only floor cells with a complete centered 7×7 snapshot are scanned. A cell passes when:

- left equals right;
- up equals down;
- the X pair differs from the Y pair;
- one pair is exactly wall and the other is exactly floor.

This establishes a three-floor passage through a perpendicular `WALL-FLOOR-WALL` opening before detailed matching. Abyss never substitutes for either pair.

### Valid geometry catalog

Nine canonical patterns contain required wall offsets relative to the opening. The matcher derives the 0°, 90°, 180°, and 270° rotations of the original and mirrored forms, then deduplicates symmetrical results. Derived variants are cached after their first construction.

Required offsets must be wall. Unlisted cells are wildcards, not required floor or required empty space. The gate—not the catalog—owns the opening and its two adjacent passage-floor requirements.

### Greedy selection

Candidates are considered in row-major order. After geometry succeeds, a candidate is accepted when its Manhattan distance from the last accepted doorway is at least three. Exact distance three is valid. Spacing is intentionally measured only from the last accepted doorway, not from every accepted doorway.

Changing scan order changes greedy winners and is therefore a behavioral change.

### Output

Each `DoorwayPlacement` contains:

- `coordinate: Vector2i`: authoritative map coordinate of the opening floor cell;
- `wall_orientation: WallOrientation`: `HORIZONTAL` or `VERTICAL` describing the containing wall, not the direction of travel.

The ordered result does not own or modify `MapData`. An empty array means no doorway geometry was selected.

## Required Outside Data

The only runtime dependency is the public `MapData` type owned by Map Generation. Doorway Placement relies on these upstream guarantees:

- positive width and height;
- row-major `cells` matching `width * height`;
- cell values restricted to `ABYSS`, `FLOOR`, and `WALL`;
- at least one floor cell;
- one cardinally connected floor region.

No Layout Interpretation data is required. In particular, Zone ownership, Area roles, Entrance/Boss identity, and `reassign_cells()` do not participate in doorway selection.

## Preservation Boundaries And Agent Traps

- Do not add defensive confirmation of trusted `MapData` invariants inside this system.
- Do not interpret `wall_orientation` as passage direction; the passage is perpendicular to the named wall orientation.
- Do not require every non-pattern cell in the 7×7 snapshot to match. Those cells are deliberate wildcards.
- Do not change spacing from “last accepted door” to “all accepted doors” without an explicit behavioral decision.
- Do not replace row-major traversal with unordered iteration; greedy results depend on stable order.
- Do not shrink the snapshot to 5×5. Some canonical shapes place the opening off-center and require normalized offsets three cells away.
- Do not make this system place tiles, meshes, or door assets. It returns placement data only.
- Do not introduce Workshop, renderer, scene, Central Controller, Layout Interpretation, population, decoration, loot, persistence, or other gameplay dependencies.

## Validation And Current Limits

Current Production behavior covers all nine canonical patterns and their unique rotations/reflections, horizontal and vertical walls, wildcard surrounding geometry, abyss rejection at the gate, exact-three spacing, stable greedy ordering, and input-cell preservation. The package composes with Map Generation alone and has no scene or renderer dependency.

The radius-3 scan intentionally excludes floor cells that cannot provide a complete 7×7 snapshot. Performance measurements are machine-dependent; the package-local README carries the current measured profile rather than treating it as a behavioral guarantee.
