# Initial Purpose Catalog Current State
Updated: 2026-09-25
Checkpoint: `[LayoutInterpretationRoom]+[ArchitectureCatalog]+[InitialPurposes]`
Implementation baseline/evidence: Room-local GDScript implementation validated with Godot 4.4.1; no Production implementation or Git checkpoint is recorded here.

## Rapid Shape

The Initial Purpose Catalog is a private, code-owned, generator-independent catalog for the six approved architectural purposes. A caller supplies an explicit purpose key; the catalog returns a detached typed definition containing that purpose's ordered Area requirements, counts, identities, and purpose-level relationships.

The catalog does not infer purpose from `MapData`, own Area geometry, or claim floor. It is ready as a validated Room-local dependency for later Layout Interpretation components.

## Current Locations And Structure

- [`Implementation/layout_interpretation_semantics.gd`](Implementation/layout_interpretation_semantics.gd): stable Geometry Archetype, Purpose, Area-role, relationship-kind, and relationship-strength enums.
- [`Implementation/layout_area_requirement.gd`](Implementation/layout_area_requirement.gd): typed ordered requirement record and detached-copy behavior.
- [`Implementation/layout_purpose_definition.gd`](Implementation/layout_purpose_definition.gd): typed purpose definition and deep-copy boundary.
- [`Implementation/initial_purpose_catalog.gd`](Implementation/initial_purpose_catalog.gd): code-owned definitions, complete-catalog validation, lookup, and loud refusal.
- [`Tests/test_initial_purpose_catalog.gd`](Tests/test_initial_purpose_catalog.gd): standalone headless Godot validation suite.
- [`PurposeContract.md`](PurposeContract.md): authoritative design input for the implementation.
- [`../ZoneCatalog/ZoneContract.md`](../ZoneCatalog/ZoneContract.md): authoritative Area-role vocabulary referenced by the catalog.

All implementation and tests remain under the Room. Production has not been modified.

## Entry Points And Flow

Conceptual use:

```gdscript
var catalog: InitialPurposeCatalog = InitialPurposeCatalog.create()
var definition: LayoutPurposeDefinition = catalog.get_definition(
	LayoutInterpretationSemantics.Purpose.PRISON
)
```

`create()` constructs all six definitions, validates the complete catalog before storing any entry, and returns `null` after a loud error if validation fails. `get_definition()` rejects unsupported keys loudly and returns a deep copy for supported keys. Callers cannot mutate the stored catalog through a returned definition.

## Component Contracts

### LayoutInterpretationSemantics

Owns the closed initial vocabulary:

- Geometry Archetypes: Dungeon, Tower, Cave.
- Purposes: Prison, Catacomb, Mage Tower, Guard Tower, Burrow/Nest, Mine Shaft.
- All sixteen approved Area roles.
- Relationship kinds: none, near universal Area, around prior requirement, adjacent to prior requirement, and progression targets.
- Relationship strengths: none, preferred, and required.

These enums have no Production generator import or dependency. The Geometry Archetype mapping records approved catalog grouping; interpretation still receives purpose explicitly.

### LayoutAreaRequirement

Owns one ordered requirement's stable ID, Area role, minimum/maximum count, relationship kind and strength, optional universal target, optional prior-requirement target, and optional progression percentages.

Relationship targets are explicit. Requirement-to-requirement relationships may only target an earlier record in the same ordered definition.

### LayoutPurposeDefinition

Owns one purpose key, its approved Geometry Archetype grouping, and an ordered typed requirement array. Construction and lookup duplicate the requirement records.

### InitialPurposeCatalog

Owns the six approved definitions and validates:

- exact catalog completeness and uniqueness;
- supported Purpose and Area-role keys;
- nonempty unique requirement IDs;
- positive counts and `minimum <= maximum`;
- relationship data appropriate to its relationship kind;
- references only to universal Areas or prior requirement IDs;
- ordered, in-range progression targets;
- progression-target count matching the maximum claim count.

The catalog contains no Area shapes, growth limits, tags, route logic, floor data, or claiming behavior.

## Validation And Current Limits

Executed with Godot 4.4.1 on 2026-09-25:

1. Headless editor import completed successfully and registered all four implementation classes plus the test script.
2. `test_initial_purpose_catalog.gd` passed 103 checks covering all six keys, exact ordered roles and counts, approved Geometry Archetype mapping, Prison relationships, Guard Tower relationships and midpoint, Burrow midpoint, Mine Shaft 35%/70% targets, detached lookup state, and unsupported-purpose refusal.
3. The unsupported-purpose check intentionally emitted the exact-origin error from `initial_purpose_catalog.gd`, returned `null`, and did not change the successful test exit.

Current limits:

- This is Room-local implementation, not Production runtime authority.
- Area-profile objects, tags, geometry requirements, universal-Area implementation, route analysis, floor claims, generic partitioning, result packaging, and public caller do not exist yet.
- Human implementation acceptance and Production adoption remain pending.
