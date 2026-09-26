# Doorway Placement Selection Current State
Updated: 2026-09-26

Checkpoint: `[DoorwayPlacementRoom]+[OffsitePreparation]+[SystemDescriptionSanitation]`
Implementation baseline/evidence: repository entry HEAD `ddb3a6dd78b71f7d21badd22f05c95fc7c4ef0b3`; uncommitted Production package, retained Room prototype/suites, rewired Workshop visualization, and synchronized AI-facing documentation.

## Rapid Shape

Doorway Placement is a shipped, validated Production geometry system for existing doorway openings. It scans generator-owned floor cells, cheaply gates opposing floor/wall pairs, validates gated cells against approved local geometry, greedily preserves spaced results, and returns door coordinates/orientations. The Workshop renderer consumes the Production API and displays accepted doorway floor cells bright red without changing geometry or interpretation data. Automated, isolated, performance, and human visual checks pass. The Room is terminal with no remaining work.

Rob owns consequential workflow and design intent. Cody owns routine implementation details after the behavior and affected source boundary are aligned and authorized.

## Current Locations And Structure

- Room traversal authority: `Workshop/Rooms/DoorwayPlacementRoom/DOTS.md`
- This current-state reference: `Workshop/Rooms/DoorwayPlacementRoom/DOORWAY_PLACEMENT_CURRENT_STATE.md`
- Production public caller: `Production/Systems/DoorwayPlacementSystem/PackageAndSurface/doorway_placer.gd`.
- Production typed result: `Production/Systems/DoorwayPlacementSystem/PackageAndSurface/doorway_placement.gd`.
- Production selection pass/catalog: `Production/Systems/DoorwayPlacementSystem/Selection/doorway_selection_pass.gd`.
- Package contract: `Production/Systems/DoorwayPlacementSystem/README.md`.
- Durable system description: `Workshop/AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/DOORWAY_PLACEMENT_SYSTEM.md`.
- Retained prototype and focused suites: `Workshop/Rooms/DoorwayPlacementRoom/`.
- Existing visualization script: `Workshop/WorkshopAssets/visualization_tool.gd`.
- Existing visualization scene: `Workshop/WorkshopAssets/VisualizationTool.tscn`.
- Runtime input types: `Production/Systems/MapGenerationSystem/GenerationController/map_data.gd` and `Production/Systems/LayoutInterpretationSystem/PackageAndSurface/interpretation_data.gd`.

## Entry Points And Flow

1. An internal consumer calls `DoorwayPlacer.place_doors()` with valid generator-owned `MapData` containing one cardinally connected floor region.
2. `DoorwayPlacer` directly composes `DoorwaySelectionPass`; it does not reconfirm generator-owned dimensions, cell storage, legend, floor, or connectivity guarantees.
3. The selection pass scans floor cells in stable row-major order.
4. A cell passes the cheap gate when left equals right, up equals down, the pair values differ, and the two values are exactly floor and wall.
5. A passing cell therefore has one cardinal `FLOOR-FLOOR-FLOOR` passage through a perpendicular `WALL-FLOOR-WALL` opening.
6. The pass captures a centered radius-3 (7×7) snapshot and tests the transformed catalog. Required wall cells must match; unspecified cells are wildcards. The gate already owns the required passage floors.
7. A matching candidate is greedily accepted when it is at Manhattan distance `>= 3` from the last accepted doorway. The first accepted candidate has no spacing dependency.
8. Output records the opening coordinate and whether its containing wall is horizontal or vertical. Input data remains unchanged.
9. The Workshop renderer draws its normal role-colored floor/wall view, then visually replaces accepted doorway floor cells with a bright-red floor mesh.

## Component Contracts

### Room documentation

- Job: preserve scope, authority, traversal state, evidence, and the actionable current tool contract.
- Inputs: confirmed Room objective, bounded authorization, implementation evidence gathered in later Boxes, and validation results.
- Outputs: synchronized `DOTS.md` and this current-state reference.
- Ownership: Cody maintains accuracy during approved execution; Rob owns acceptance and consequential intent.

### Doorway selector

- Job: recognize valid existing doorway openings; it does not cut, place, or mutate geometry.
- Input: valid `MapData` from the closed generator/interpreter pipeline.
- Output: ordered typed doorway results containing authoritative `Vector2i` coordinates and cardinal wall orientation.
- Ordering: row-major greedy traversal.
- Spacing: Manhattan distance from only the last accepted doorway must be at least three.
- Snapshot: full centered 7×7 evidence is required; candidates without that bounded snapshot are rejected.
- Catalog: nine canonical reference shapes normalized around their opening. The matcher derives every unique 0°/90°/180°/270° rotation from both the original and mirrored form, deduplicating symmetry. The ninth canonical shape requires a full two-cell wall span on both sides of the opening and a one-cell return above and below one end; transforms cover the opposite end and vertical forms.
- Exposed internal entry point: `DoorwayPlacer.place_doors(map_data: MapData) -> Array[DoorwayPlacement]`.
- Pipeline rule: valid `MapData` is guaranteed upstream; Doorway Placement owns no defensive confirmation of those invariants.

### Visualization dependency

- Job: display accepted selections as a diagnostic layer/pass.
- Existing behavior: `visualization_tool.gd` generates and interprets a map, duplicates the floor mesh/material by Area role, and renders through one `GridMap`.
- Extension: create one bright-red floor mesh variant and apply it to accepted doorway coordinates after ordinary rendering.
- Guarantee: display changes do not modify `MapData`, Zone ownership, or interpretation state; ordinary rendering still works with no doors.
- Integration: `_ready()` selects doors from the generated `MapData`, prepares colored meshes, and passes results to `render_interpretation()`. Its optional doorway argument preserves callers that render without doors.

## Required Outside Data

- `MapData` cell legend and dimensions/cells contract.
- The nine user-provided valid-geometry reference shapes, including the short left-return layout added during visual validation.
- Existing `VisualizationTool.tscn`, `visualization_tool.gd`, and `VisualizationToolMeshLibrary.tres`.
- Godot project class registration for focused headless checks.

## Validation And Current Limits

- Confirmed `MapData` provides detached width, height, row-major cells, and floor/wall/abyss constants.
- Confirmed `InterpretationData` carries the exact `MapData` object forward and that door detection is explicitly downstream of Layout Interpretation.
- Confirmed the existing visualization already creates runtime-colored floor mesh variants and can support a red final override without modifying input data.
- Godot editor/import check completed successfully after registering `DoorwayPlacement` and `DoorwaySelector`.
- `doorway_selector_suite.gd` passed 45 checks covering all nine canonical patterns, every mirrored and quarter-turn form of the added short-return shape, vertical rotation, wildcard surrounding geometry, abyss-pair rejection, insufficient-wall rejection, exact-three spacing, too-close rejection, row-major greedy preservation, and unchanged input cells.
- Headless `VisualizationTool.tscn` integration run completed with exit code `0` and no reported errors.
- `git diff --check` reported no errors in the task files; its output included pre-existing CRLF warnings for unrelated files.
- Rob visually confirmed on 2026-09-26 that the highlighted doorway selection does what it should and accepted its simplicity.
- The promoted internal caller passed the 45-check behavior suite after its redundant input checks were removed.
- The retained Workshop prototype was also stripped of its stale duplicate input checks so Room evidence does not preserve contradictory pipeline behavior.
- Final residual search found no input-confirmation methods, obsolete failure claims, or associated error text in the Production package, Room implementation, or active Doorway Placement system description.
- Godot import/parser validation passed after full removal.
- The Workshop visualization completed headlessly after rewiring to `DoorwayPlacer`.
- An isolated Godot project containing only Map Generation and Doorway Placement selected the expected doorway and preserved `MapData`; retained path: `/tmp/doorway_placement_isolation`.
- A 50-map Cave/Large/Standard benchmark excluded map generation and measured a first pass of `3.400 ms`; 49 warm passes measured `2.401 ms` minimum, `3.880 ms` median, `4.378 ms` mean, `7.634 ms` p95, and `13.979 ms` maximum. Door counts ranged 13–31. The retained script is `/tmp/doorway_cave_large_benchmark.gd`; timings are machine-specific evidence.
- A dependency audit found only `MapData`/doorway package references in Production scripts; no Workshop, renderer, scene, Layout Interpretation, Central Controller, or gameplay dependency exists.
- Runtime authority is Production. Room prototypes remain retained evidence and are not consumers or runtime authority.
- Downstream population, decoration, tiling, and loot behavior remains outside this component by design, not as unfinished Doorway Placement work.
- “Public” in earlier Room wording meant exposed input/output within the internal system pipeline. Active documentation now uses explicit internal-surface language where ambiguity mattered.
- Output disposition: Production is runtime authority; durable contracts remain with Production and AI-facing documentation; Room prototypes/suites remain evidence; the shared visualizer remains a diagnostic consumer; temporary evidence remains retained pending any future explicit deletion authorization.
- Rob directed `Ship it` on 2026-09-26. No unresolved Doorway Placement work remains.
- The durable AI-facing system description now contains only current operational context and no longer links to or depends on Room history, retained prototypes, temporary evidence, or conversational acceptance chronology.
- No Git checkpoint has been inferred.
