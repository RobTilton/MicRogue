# Universal Area Catalog Current State
Updated: 2026-09-25
Checkpoint: `[LayoutInterpretationRoom]+[ZoneCatalog]+[UniversalZones]`
Implementation baseline/evidence: Room-local GDScript implementation validated with Godot 4.4.1; no Production implementation or Git checkpoint is recorded here.

## Rapid Shape

The Universal Area Catalog provides detached, validated profile data for `ENTRANCE_AREA` and `BOSS_AREA` plus their shared endpoint-selection policy. It contains no routing, flood-fill, endpoint-selection, or tile-claim algorithm.

The profiles convert the approved Zone Contract into inert typed inputs for later Geometry Analysis and Zone Claim components. Tags remain downstream semantic instructions rather than evidence that content exists.

## Current Locations And Structure

- [`Implementation/layout_area_semantics.gd`](Implementation/layout_area_semantics.gd): universal growth, tag, preference, connectivity, route-selection, endpoint-adjustment, endpoint-assignment, and tie-policy enums.
- [`Implementation/layout_area_profile.gd`](Implementation/layout_area_profile.gd): typed Area-profile data and detached-copy behavior.
- [`Implementation/universal_endpoint_policy.gd`](Implementation/universal_endpoint_policy.gd): typed endpoint-selection policy and detached-copy behavior.
- [`Implementation/universal_area_catalog.gd`](Implementation/universal_area_catalog.gd): code-owned Entrance/Boss data, validation, lookup, and loud refusal.
- [`Tests/test_universal_area_catalog.gd`](Tests/test_universal_area_catalog.gd): standalone headless Godot validation suite.
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
var endpoint_policy: UniversalEndpointPolicy = catalog.get_endpoint_policy()
```

`create()` constructs both profiles and the endpoint policy, validates the full set before storing it, and returns `null` after a loud error if validation fails. Supported lookups return detached data. Unsupported Area roles fail loudly and return `null`.

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

### Endpoint Policy

- Four-directional connectivity.
- Longest qualifying navigable route.
- Qualifying endpoint capacity: `3x3`, `4x2`, or `2x4`.
- Move an undersized endpoint inward to the next qualifying area.
- Smaller qualifying end becomes Entrance; larger becomes Boss.
- Equal endpoints use a random coin flip.

This policy describes required behavior only. Later components own the search and mutation mechanics.

### Validation Boundary

The catalog validates:

- exact universal catalog completeness and unique roles;
- positive, unique minimum footprints;
- valid wall-adjacency ranges;
- absence of growth data on non-growing profiles;
- positive tile and bounding limits on flood profiles;
- unique supported preferences and tags;
- exact approved endpoint-policy values.

## Validation And Current Limits

Executed with Godot 4.4.1 on 2026-09-25:

1. Headless editor import completed successfully and registered the four implementation classes plus the test script.
2. `test_universal_area_catalog.gd` passed 36 checks covering exact Entrance/Boss data, endpoint policy, detached profile/policy state, unsupported-role refusal, and malformed-profile refusal.
3. Expected refusal checks emitted exact-origin errors for `GENERIC_AREA` lookup and a zero-size minimum footprint; both returned the expected failure values and the suite exited successfully.

Current limits:

- Purpose-required and Generic Area profiles are not implemented.
- No route analysis, origin search, endpoint movement, area-size comparison, flood growth, tile claim, tag enforcement, or result packaging exists.
- This is Room-local implementation, not Production runtime authority.
- Human implementation acceptance and Production adoption remain pending.
