# Claim And Zoning Current State
Updated: 2026-09-26
Checkpoint: `[LayoutInterpretationRoom]+[ClaimAndZoning]+[PurposeAndCoveragePass]`
Implementation baseline/evidence: Room-local Geometry Analysis, atomic Area claiming, Universal Pass, and Purpose/Coverage Pass validated with Godot 4.4.1; no Production implementation or Git checkpoint is recorded here.

## Rapid Shape

Geometry Analysis trusts the closed generator pipeline's `MapData` contract and performs one linear scan to collect detached floor evidence. It does not revalidate dimensions, cell vocabulary, or connectivity, and it does not calculate a global route.

Atomic Area claiming consumes that evidence through detached claim state. Universal Pass composes analysis and claims into an all-or-nothing Entrance/Boss result. Purpose/Coverage Pass then claims one purpose's ordered requirements and partitions remaining eligible geometry into bounded Generic Areas without mutating `MapData`.

## Current Locations And Structure

- [`Implementation/layout_geometry_analyzer.gd`](Implementation/layout_geometry_analyzer.gd): one row-major floor scan with no duplicate upstream validation.
- [`Implementation/geometry_analysis_result.gd`](Implementation/geometry_analysis_result.gd): detached cells, floor coordinates, cardinal neighbor queries, and on-demand single- or multi-source distance floods.
- [`Tests/test_geometry_analysis.gd`](Tests/test_geometry_analysis.gd): floor evidence, distance-field, detachment, source-preservation, and Production-map cost checks.
- [`Implementation/area_claim.gd`](Implementation/area_claim.gd): detached completed claim data, bounds, tags, role, requirement identity, and origin.
- [`Implementation/area_claim_request.gd`](Implementation/area_claim_request.gd): optional requirement identity and caller-ranked origin candidates.
- [`Implementation/area_claim_state.gd`](Implementation/area_claim_state.gd): detached geometry owner, exclusive coordinate ownership, full pre-mutation validation, and detached claim lookup.
- [`Implementation/zone_claim_engine.gd`](Implementation/zone_claim_engine.gd): origin clearance, minimum-footprint selection, preference ranking, bounded flood growth, narrow-connection policy, and atomic application.
- [`Tests/test_zone_claim.gd`](Tests/test_zone_claim.gd): non-growing, bounded growth, exclusivity, atomic refusal, narrow-chain, detachment, and source-preservation checks.
- [`Implementation/universal_pass.gd`](Implementation/universal_pass.gd): Entrance-first claiming, one Entrance-origin distance flood, farthest-first Boss search, and no-partial-result refusal.
- [`Implementation/universal_pass_result.gd`](Implementation/universal_pass_result.gd): detached geometry, claims, state, Entrance distance field, and maximum distance.
- [`Tests/test_universal_pass.gd`](Tests/test_universal_pass.gd): Entrance-first composition, distant Boss selection, seeded Entrance ties, all-or-nothing failure, and Production-map checks.
- [`Implementation/purpose_coverage_pass.gd`](Implementation/purpose_coverage_pass.gd): ordered purpose execution, multiplicity selection, required/preferred relationship handling, Entrance-distance progression ranking, Generic fallback coverage, and all-or-nothing required-minimum failure.
- [`Implementation/purpose_coverage_result.gd`](Implementation/purpose_coverage_result.gd): detached purpose, geometry, claim state, universal claims, coverage ratio, and honest unzoned-floor result.
- [`Tests/test_purpose_coverage_pass.gd`](Tests/test_purpose_coverage_pass.gd): all-six-purpose composition, multiplicity, relationship metadata, progression targets, Generic coverage, exclusivity, source preservation, and atomic required-failure checks.

All new implementation and tests remain under the Room. Production was read through its public API but not modified.

## Entry Points And Flow

```gdscript
var result: GeometryAnalysisResult = LayoutGeometryAnalyzer.analyze(map_data)
```

The analyzer collects floor coordinates in stable row-major order and returns detached evidence without mutating source cells. Consumers may request one cardinal distance flood from one or more owned origins. Upstream generator guarantees are trusted as-is.

## Component Contracts

### Trusted Input Boundary

`MapData` dimensions, cell vocabulary, floor presence, and single-region connectivity are generator-owned guarantees. Geometry Analysis does not spend runtime reconfirming them. Focused generator tests own those invariants; downstream pipeline components trust them.

### Mutation Boundary

`MapData.cells` and returned floor-coordinate arrays are detached. Geometry Analysis exposes queries but owns no claim state and performs no writes to the source map.

### Atomic Area Claims

`AreaClaimState` owns exclusive coordinate-to-claim membership. It validates every coordinate in a complete candidate before assigning any tile. Empty, repeated, non-floor, or overlapping candidates fail loudly and leave the existing state unchanged.

`ZoneClaimEngine.try_claim()`:

1. Trusts the catalog-owned Area profile and completed geometry/claim-state contracts.
2. Uses caller-ranked origins when supplied; otherwise ranks available floor using applicable soft preferences and internal random tie values.
3. Requires an origin surrounded by floor in all eight neighboring directions.
4. Finds a complete unclaimed minimum footprint containing the origin.
5. Returns that footprint directly for non-growing Areas.
6. Flood-grows other Areas cardinally within their tile cap and oriented bounding window.
7. Allows one-tile connections only when the profile permits them; otherwise growth cells must participate in open `2x2` floor.
8. Applies the completed claim atomically.

Zero tile cap means the bounding window is the limiter. Zero bounding window means the tile cap is the limiter. At least one limiter is required for flood growth.

Preferences influence origin ordering or growth shape but do not turn an otherwise valid Area contract into failure. Purpose-level relationship orchestration remains outside this component.

### Universal Pass

Universal Pass claims Entrance first using its existing profile and seeded tie behavior. It then performs one multi-source cardinal distance flood from every tile in the completed Entrance claim. Boss origins are attempted from greatest distance toward least, accepting the first origin that produces a complete valid Boss claim.

If either claim fails, the temporary state is discarded and the call returns `null`; no partial universal result escapes. Successful results contain exactly two exclusive claims plus the detached Entrance distance field needed by later progression placement.

### Purpose And Coverage Pass

Purpose/Coverage Pass trusts the three completed catalogs, runs Universal Pass, and works from a duplicate of its claim state. Requirements execute strictly in catalog order. Count ranges choose a desired count through the supplied random source: the minimum is mandatory, while additional ranged instances are attempted until the desired count or available-geometry terminal condition. Exact-count requirements remain mandatory in full.

Relationship behavior is semantic and deliberately loose:

- `NEAR_AREA` ranks origins by cardinal distance to the named universal claim.
- `AROUND_REQUIREMENT` and `ADJACENT_REQUIREMENT` reference already-completed requirement claims. Required relationships are tried transactionally and accept a completed claim only within two or one cardinal tiles respectively.
- `PROGRESSION_TARGETS` converts the requested percentage into a target distance between zero and the maximum Entrance distance, then ranks origins by proximity to that distance band.
- Relationship kind, strength, target claim IDs, and progression target are preserved on each completed claim for downstream use.

A failure before the required minimum—or within an exact-count requirement—discards the temporary composition and returns `null`; source `MapData` and caller-visible prior results remain unchanged. Failure of an additional ranged instance stops that requirement at its already-valid count. After all required Areas succeed, Generic Areas repeatedly claim eligible unowned floor under their 30-tile cap. The loop is bounded by floor-count-derived attempts and also stops at the first terminal no-claim result. Remaining floor is reported in `unzoned_floor`; it is not silently absorbed or treated as failure.

## Validation And Current Limits

Executed with Godot 4.4.1 on 2026-09-26:

- Simplified `test_geometry_analysis.gd` passed 13 checks.
- Checks cover complete floor collection, cardinal multi-source distance evidence, detached results, and source-map preservation.
- One internally random Production `CAVE/LARGE/CONFINED` map returned 917 floor tiles, remained unchanged, and completed the linear floor scan in `584 microseconds` in the observed headless run.
- `test_zone_claim.gd` passed 32 checks covering exact non-growing Entrance claims, Boss/Library caps and windows, exclusive membership, atomic overlap/fixed-origin failure, Generic traversal through a one-tile chain, detached outputs, tags, requirement identity, and unchanged source `MapData`.
- The overlap fixture intentionally emitted an exact-origin error and demonstrated no partial mutation.
- Simplified `test_universal_pass.gd` passed 17 checks covering Entrance-first composition, one complete Entrance distance flood, farthest usable Boss placement, seeded Entrance ties, exact roles/two-claim state, footprint/cap preservation, non-overlap, no-partial failure, and one Production `DUNGEON/MEDIUM/STANDARD` composition.
- The intentional no-wall Entrance fixture emitted an exact-origin universal refusal and returned `null`.
- `test_purpose_coverage_pass.gd` passed 84 checks. All six approved purposes completed on deterministic `45x45` open-map fixtures with one Entrance, one Boss, valid required multiplicities, distance-band progression, exclusive ownership, capped Generic Areas, preserved relationship metadata, valid coverage ratios, and unchanged source maps.
- The intentional undersized Guard Tower fixture emitted a required-Area refusal, returned `null`, and preserved its source map, demonstrating no partial purpose result.
- Final regression reruns passed Geometry Analysis (13), Zone Claim (32), Universal Pass (17), Purpose/Coverage (84), Universal Area Catalog (30), Purpose Area Catalog (148), and Initial Purpose Catalog (103). Expected negative fixtures continued to fail loudly.
- The final Geometry Analysis regression observed a random Large Cave with 1,097 floor tiles in `988 microseconds`; this is observation only.

Current limits:

- The measured timing is one observation, not a performance guarantee.
- Small or structurally ineligible floor remnants are reported as unzoned for later decoration or population handling.
- `PurposeCoverageResult` is a Room-local orchestration result, not the final public `InterpretationData` package or entry point.
- Human implementation acceptance and Production adoption remain pending.
