# Architecture Catalog Table
Updated: 2026-09-25
Checkpoint: `[LayoutInterpretationRoom]+[ArchitectureCatalog]+[PurposeContract]`
Implementation baseline/evidence: No Layout Interpretation implementation exists. The occupant-driven catalog direction was superseded after establishing that occupants do not define original architecture.

## Rapid Shape

This Table discovers a bounded vocabulary of architectural/site purposes and the spaces those purposes require. Layout Interpretation uses that purpose to identify what the built environment was for, independently of who currently occupies it.

The initial vocabulary is clamped to exactly two purposes for each current Map Generation Archetype. No additional purpose belongs in the initial catalog.

## Approved Initial Purpose Catalog

| Map Generation Archetype | Layout Interpretation purpose |
|---|---|
| `DUNGEON` | `PRISON` |
| `DUNGEON` | `CATACOMB` |
| `TOWER` | `MAGE_TOWER` |
| `TOWER` | `GUARD_TOWER` |
| `CAVE` | `BURROW_NEST` |
| `CAVE` | `MINE_SHAFT` |

The Archetype describes the broad generated geometry. The purpose describes why that built or occupied space exists and therefore which architectural Zones should be interpreted from it.

The completed authoritative Room-local definition is [`PurposeContract.md`](PurposeContract.md).

## Purpose Contract Discovery

The first Box proceeds in this order:

1. Use the six approved purposes without expanding the list.
2. List candidate architectural spaces implied by each purpose.
3. Retain only distinctions that materially change spatial interpretation, allocation, relationships, or required geometry.
4. Identify shared structural roles without erasing meaningful purpose-specific behavior.
5. Classify surviving spaces as required or optional.
6. Derive the smallest site-purpose contract capable of driving the approved interpretations.

## Ownership Boundary

Architectural interpretation answers what spaces were built for. It does not decide who currently occupies them or place doors, portals, stairs, traps, scenery, lighting, loot, actors, furnishings, or decorations.

A future occupant-family pass may adapt the interpreted architecture by layering, replacing, or scrubbing decoration and signs of use. That possible system is preserved separately in [`../../../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/Pseudo_System_Family_NOT_AUTHORITATIVE.md`](../../../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/Pseudo_System_Family_NOT_AUTHORITATIVE.md) and is not authoritative.

## Current Limits

- The initial six-purpose list and Archetype mapping are approved.
- Required roles, multiplicities, order, and relationships are approved in [`PurposeContract.md`](PurposeContract.md).
- Concrete catalog representation, Zone geometry, selection mechanics, and runtime behavior remain unimplemented.
- Detailed Box dependencies and Room-wide unresolved decisions remain authoritative in [`../../DOTS.md`](../../DOTS.md).
