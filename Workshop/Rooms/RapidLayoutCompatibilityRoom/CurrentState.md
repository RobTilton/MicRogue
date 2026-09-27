# Rapid/Layout Compatibility Current State
Updated: 2026-09-27
Checkpoint: `[RapidLayoutCompatibilityRoom]+[CompatibilityContract]+[InterfaceAndInvariantAudit]`
Implementation baseline/evidence: Git `9a4f60b71fcf34e961c23b9c5449b6a68e6028e9`; clean worktree at Room entry; focused source inspection performed 2026-09-27. No runtime composition test has yet been executed.

## Rapid Shape

Rapid Room Generation and Layout Interpretation do not currently compose at their public boundaries. Rapid returns `RapidRoomMapData`; Layout accepts and retains only the legacy generator's nominal `MapData`. Their physical cell values agree for floor and wall, but Layout's type ownership extends through its complete pipeline and output package. Rapid also owns explicit doorway metadata and generation diagnostics that the legacy `MapData` contract cannot carry.

The active Box is an interface-and-invariant audit. Rob has reserved the consequential rewiring design and has stated that the intended handling is already prepared. Implementation must not begin until that handling is recorded here and in DOTS.

## Current Locations And Structure

- [`Production/Systems/RapidRoomGenerationSystem/rapid_room_generator.gd`](../../../Production/Systems/RapidRoomGenerationSystem/rapid_room_generator.gd): returns `RapidRoomMapData` from ordinary and seeded entry points.
- [`Production/Systems/RapidRoomGenerationSystem/rapid_room_map_data.gd`](../../../Production/Systems/RapidRoomGenerationSystem/rapid_room_map_data.gd): owns Rapid width, height, detached cells, doorways, and diagnostics.
- [`Production/Systems/LayoutInterpretationSystem/PackageAndSurface/layout_interpreter.gd`](../../../Production/Systems/LayoutInterpretationSystem/PackageAndSurface/layout_interpreter.gd): public three-argument boundary typed to `MapData` plus purpose and legacy `GenerationSemantics.Scale`.
- [`Production/Systems/LayoutInterpretationSystem/PackageAndSurface/interpretation_data.gd`](../../../Production/Systems/LayoutInterpretationSystem/PackageAndSurface/interpretation_data.gd): retains the exact input as a typed `MapData` and uses `MapData.FLOOR` during reassignment.
- [`Production/Systems/LayoutInterpretationSystem/ClaimAndZoning/`](../../../Production/Systems/LayoutInterpretationSystem/ClaimAndZoning/): analyzer and passes propagate `MapData`; claim logic names `MapData.WALL` and `MapData.ABYSS`.
- [`Production/Systems/MapGenerationSystem/GenerationController/map_data.gd`](../../../Production/Systems/MapGenerationSystem/GenerationController/map_data.gd): legacy physical-map type currently coupled to Layout.

## Exact Compatibility Boundaries

### Nominal type boundary

`LayoutInterpreter.interpret()` cannot accept `RapidRoomMapData` because its first parameter is statically typed `MapData`. This is not isolated to the public signature: `PurposeCoveragePass`, `UniversalPass`, `LayoutGeometryAnalyzer`, and `InterpretationData.create()` use the same nominal legacy type, and `InterpretationData.map_data` is declared `MapData`.

### Physical cell contract

Both map types use row-major `PackedInt32Array` cells with `FLOOR = 1` and `WALL = 2`, plus integer width and height. Rapid has no abyss value because its returned square is closed by an exterior wall ring. Layout treats out-of-bounds positions as `MapData.ABYSS` internally; it does not require stored abyss cells for that behavior.

Known source inspection therefore shows no numeric floor/wall translation requirement. It does not yet prove that Rapid geometry satisfies every Area-claim profile under every intended purpose/scale pair.

### Metadata and identity boundary

Rapid additionally owns detached `RapidRoomDoorway` records and generation diagnostics. Converting only width, height, and cells into legacy `MapData` would discard those fields from the exact object carried by `InterpretationData`. The Room contract prohibits silently losing that channel.

Layout's existing output contract promises exact input-object carriage. Any generalized physical-map interface, inheritance choice, wrapper, conversion, or revised output contract is consequential architecture and awaits Rob's direction.

### Semantic-program boundary

Layout requires `Purpose` and `GenerationSemantics.Scale`. Rapid accepts only an integer square top-board size and neither owns nor reports the legacy Scale. Layout uses Scale to choose required Area counts, profiles, and caps; source inspection does not indicate that it validates Scale against map dimensions. The caller may continue to own the semantic Scale, or the contract may be changed, but that choice awaits Rob's direction.

## Preserved Invariants

- Rapid owns generation and its explicit doorway metadata.
- Layout assigns semantic floor ownership without modifying physical cells.
- Successful interpretation must retain the physical map object required by the approved contract rather than an undocumented lossy substitute.
- Layout may trust generator-owned valid dimensions, floor presence, and one cardinally connected floor region.
- A mandatory Area failure returns `null` without a partial interpretation package.
- No legacy-generator dependency may be added to Rapid merely to satisfy Layout.

## Validation Evidence And Remaining Work

Established by focused source inspection:

- Raw Rapid floor/wall values align with the values Layout currently tests.
- The present call fails at the typed public boundary before geometric interpretation.
- The legacy type dependency is distributed across Layout rather than confined to one adapter point.
- Scale is used as semantic catalog input and is not supplied by Rapid.

Not yet established:

- Rob's intended rewiring contract.
- Which purpose/scale combinations Rapid must support and which Rapid board sizes map to them.
- Runtime success rates across that matrix, including Entrance/Boss and strict-purpose foundation claims.
- Final ownership and carriage of Rapid doorway/diagnostic metadata.
- Required focused test location and retained evidence.

Next action: record Rob's intended handling, revise the implementation Box around that decision, and run the smallest diagnostic composition probe that matches the approved boundary.
