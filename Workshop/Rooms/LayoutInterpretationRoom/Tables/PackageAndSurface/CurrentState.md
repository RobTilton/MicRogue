# Package And Surface Current State
Updated: 2026-09-26
Checkpoint: `[LayoutInterpretationRoom]+[PackageAndSurface]+[PublicEntryPoint]`
Implementation baseline/evidence: Room-local mutable interpretation package and seedless public entry point validated with Godot 4.4.1; no Production implementation or Git checkpoint is recorded here.

## Implemented Surface

- [`Implementation/interpretation_data.gd`](Implementation/interpretation_data.gd): exact `MapData` carriage, purpose and universal IDs, row-major Zone overlay, Zone lookup, coverage/unzoned state, and atomic bulk ownership transfer.
- [`Implementation/interpretation_zone.gd`](Implementation/interpretation_zone.gd): mutable semantic Zone record with protected coordinate replacement and automatic bounds refresh.
- [`Tests/test_interpretation_data.gd`](Tests/test_interpretation_data.gd): composed package construction and mutation suite.
- [`InterpretationDataContract.md`](InterpretationDataContract.md): authoritative package and mutation contract.
- [`Implementation/layout_interpreter.gd`](Implementation/layout_interpreter.gd): two-argument public composition surface with internally cached catalogs and internal per-call randomness.
- [`Tests/test_layout_interpreter.gd`](Tests/test_layout_interpreter.gd): successful full composition, exact map carriage, physical-cell preservation, output surface, and no-partial failure checks.
- [`PublicEntryPointContract.md`](PublicEntryPointContract.md): authoritative caller boundary.

## Construction

```gdscript
var data: InterpretationData = InterpretationData.create(map_data, purpose_coverage_result)
```

Construction trusts the completed pipeline result, carries the exact `MapData` reference, copies claim metadata into Zone records, and builds one Zone-ID overlay. It performs no new layout decision or upstream validation.

## Mutation

```gdscript
data.reassign_cells(coordinates, destination_zone_id)
```

`destination_zone_id == 0` moves floor into the unzoned set. A positive ID transfers it to an existing Zone. Every request is checked in full before mutation, then overlay ownership, Zone coordinates, bounds, unzoned membership, claimed count, and coverage are updated together. Empty Zones remain addressable.

Door detection, disconnected-piece detection, destination choice, Zone creation/deletion, content placement, and geometry changes are outside this Box.

## Public Entry Point

```gdscript
var data: InterpretationData = LayoutInterpreter.interpret(map_data, purpose)
```

The public caller supplies no catalogs, passes, tuning values, random generator, or seed. Catalogs are cached internally after class initialization. Every interpretation call owns one randomized internal generator and returns either the complete mutable blueprint or `null`.

## Validation

Executed with Godot 4.4.1 on 2026-09-26:

- `test_interpretation_data.gd` passed 34 checks.
- Construction preserved exact `MapData` identity, purpose, Entrance/Boss IDs, all claims, metadata, overlay dimensions, coverage, and unzoned floor.
- Overlay ownership and Zone coordinate membership agreed before and after mutation.
- Zone-to-Zone transfer preserved all floor ownership, refreshed both Zone records, and allowed the emptied source Zone to remain represented.
- Transfers to and from unzoned floor updated overlay, coordinate collections, and coverage.
- Invalid-coordinate and missing-destination fixtures failed loudly and left ownership unchanged.
- Composed regressions passed Geometry Analysis (13), Zone Claim (32), Universal Pass (17), Purpose/Coverage (84), and Interpretation Data (34): 180 checks total. Expected negative fixtures continued to fail loudly.
- The regression Geometry Analysis run observed 1,032 floor tiles in `1,005 microseconds`; this is an observation, not a guarantee.
- `test_layout_interpreter.gd` passed 11 focused checks. A complete `45x45` open-map Mage Tower interpretation took `879,538 microseconds` in the observed run; this includes all claiming and Generic coverage, not only floor analysis.
- The public failure fixture emitted the expected Entrance refusal, returned `null`, and preserved physical cells.
- Final public-surface regressions passed Geometry Analysis (13), Zone Claim (32), Universal Pass (17), Purpose/Coverage (84), Interpretation Data (34), and Public Entry Point (11): 191 checks total. The final composed `45x45` observation completed in `782,633 microseconds`; expected negative fixtures continued to fail loudly.

Composed system integration remains the final planned Box.
