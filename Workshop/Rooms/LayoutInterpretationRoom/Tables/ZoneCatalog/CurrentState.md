# Zone Catalog Current State
Updated: 2026-09-26
Checkpoint: `[LayoutInterpretationRoom]+[ZoneCatalog]+[PurposeAndFallbackZones]`
Implementation baseline/evidence: Room-local GDScript implementation validated with Godot 4.4.1; no Production implementation or Git checkpoint is recorded here.

## Rapid Shape

The Zone Catalog provides detached, validated profile data for all sixteen approved Area roles. It contains no placement or tile-claim algorithm.

The profiles convert the approved Zone Contract into inert typed inputs for later Geometry Analysis and Zone Claim components. Tags remain downstream semantic instructions rather than evidence that content exists.

## Current Locations And Structure

- [`Implementation/layout_area_semantics.gd`](Implementation/layout_area_semantics.gd): growth, tag, and preference enums.
- [`Implementation/layout_area_profile.gd`](Implementation/layout_area_profile.gd): typed Area-profile data and detached-copy behavior.
- [`Implementation/universal_area_catalog.gd`](Implementation/universal_area_catalog.gd): code-owned Entrance/Boss data, validation, lookup, and loud refusal.
- [`Implementation/purpose_area_catalog.gd`](Implementation/purpose_area_catalog.gd): code-owned purpose-required and Generic Area data, geometry-clone validation, cross-catalog validation, lookup, and loud refusal.
- [`Tests/test_universal_area_catalog.gd`](Tests/test_universal_area_catalog.gd): standalone headless Godot validation suite.
- [`Tests/test_purpose_area_catalog.gd`](Tests/test_purpose_area_catalog.gd): purpose/fallback and cross-catalog validation suite.
- [`ZoneContract.md`](ZoneContract.md): authoritative design input.
- [`../ArchitectureCatalog/Implementation/layout_interpretation_semantics.gd`](../ArchitectureCatalog/Implementation/layout_interpretation_semantics.gd): shared approved Area-role vocabulary.

All implementation and tests remain under the Room. Production has not been modified.

## Entry Points And Flow

Conceptual use:

```gdscript
var catalog: UniversalAreaCatalog = UniversalAreaCatalog.create()
var entrance: LayoutAreaProfile = catalog.get_profile(
	LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA
)
```

`create()` constructs and validates both profiles before storing them. Supported lookups return detached data. Unsupported Area roles fail loudly and return `null`.

Purpose/fallback use follows the same boundary:

```gdscript
var purpose_areas: PurposeAreaCatalog = PurposeAreaCatalog.create()
var cell_area: LayoutAreaProfile = purpose_areas.get_profile(
	LayoutInterpretationSemantics.AreaRole.CELL_AREA
)
```

`PurposeAreaCatalog.validate_purpose_catalog()` verifies that every ordered requirement in the completed Initial Purpose Catalog resolves to an implemented Area profile.

## Component Contracts

### Entrance Profile

- Exact minimum alternatives: `2x4`, `4x2`, or `3x3`.
- Growth mode: none.
- At least one wall-adjacent side; two preferred.
- Tags: `ENTRANCE`, `NO_ENEMY`, `LIGHT`.

Zero tile cap and zero bounding window mean no growth data applies; the selected minimum footprint is the complete claim.

### Boss Profile

- Minimum footprint: `3x3`.
- Growth mode: flood.
- Maximum 50 claimed tiles within an `8x8` bounding window.
- Narrow connections permitted so one claim may span multiple connected pockets.
- Preferences: largest usable connected space, then a single open area when available.
- Tags: `BOSS`, `LIGHT`.

### Purpose And Generic Profiles

The catalog implements the approved data for:

- Guard Post, including non-blocking two-tile companion proximity.
- Cell and Burial Chamber chain-capacity geometry within `12x12`; Burial Chamber copies geometry only and adds `SWARM` independently.
- Shrine, Library, Scrying Chamber, Alchemy Lab, Armory, Barracks, Nesting/Resting, Food Storage, Depot, and Equipment Storage.
- Equipment Storage geometry cloned from Armory without Armory tags or companion behavior.
- Generic Area with a `2x2` seed, 30-tile cap, no bounding window, narrow-chain traversal, and no forced remainder absorption.

The shared profile schema now expresses optional rotating non-square bounding windows, chain-unit geometry, geometry-clone provenance, non-blocking companion proximity, all approved preferences, and all approved tags. `NO_LIGHT` remains a distinct invariant tag value.

### Validation Boundary

The catalog validates:

- exact universal catalog completeness and unique roles;
- positive, unique minimum footprints;
- valid wall-adjacency ranges;
- absence of growth data on non-growing profiles;
- positive tile and bounding limits on flood profiles;
- unique supported preferences and tags;

## Validation And Current Limits

Executed with Godot 4.4.1 on 2026-09-25:

1. Headless editor import completed successfully and registered the four implementation classes plus the test script.
2. `test_purpose_area_catalog.gd` passed 148 checks covering all fourteen purpose/fallback profiles, exact limits/preferences/tags, geometry-only clones, detached lookup, Purpose Catalog cross-resolution, and unsupported-role refusal.
3. After endpoint-policy removal, `test_universal_area_catalog.gd` passed 30 regression checks covering exact Entrance/Boss data, detached profile state, unsupported-role refusal, and malformed-profile refusal.
4. Expected refusal checks emitted exact-origin errors for unsupported cross-catalog lookups and a zero-size minimum footprint; all returned the expected failure values and both suites exited successfully.

Current limits:

- Placement and claim mechanics remain owned by Claim And Zoning rather than this catalog.
- This is Room-local implementation, not Production runtime authority.
- Human implementation acceptance and Production adoption remain pending.
