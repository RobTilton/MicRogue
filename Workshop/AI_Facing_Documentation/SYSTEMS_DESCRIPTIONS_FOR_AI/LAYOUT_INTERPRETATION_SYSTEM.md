# Layout Interpretation System
Updated: 2026-09-26
Status: Production; active Medium/Large integration validated
Runtime authority: [`Production/Systems/LayoutInterpretationSystem/`](../../../Production/Systems/LayoutInterpretationSystem/)

## Public Contract

Layout Interpretation converts generated floor geometry into a mutable semantic blueprint. Ordinary consumers use one entry point:

```gdscript
var interpretation: InterpretationData = LayoutInterpreter.interpret(
	map_data,
	LayoutInterpretationSemantics.Purpose.MINE_SHAFT,
	GenerationSemantics.Scale.SMALL
)
```

The public surface accepts only a valid closed-pipeline `MapData`, supported purpose, and the Scale used to generate that map. Purpose plus Scale resolves the required-Area program. Randomness, catalogs, profiles, passes, and tuning are internal. Successful calls carry the exact `MapData` object forward without changing its physical cells. A mandatory-claim failure returns `null` without a partial package; the supported integration matrix accepts no such failure.

## Supported Purposes

| Generator archetype | Supported purposes |
|---|---|
| Dungeon | Prison, Catacomb |
| Tower | Mage Tower, Guard Tower |
| Cave | Burrow Nest, Mine Shaft |

Entrance and Boss Areas exist for every purpose. Purpose requirements, counts, order, and relationships are code-owned by `InitialPurposeCatalog`; geometric profiles and semantic tags are code-owned by the Zone catalogs.

The interpretation catalog retains Small, Medium, and Large tier definitions. Production generation currently requests only Medium and Large; Small is pinned for future generator rework without deleting its interpretation contract.

## Composition

```text
LayoutInterpreter.interpret(MapData, Purpose, Scale)
	-> cached purpose and Area catalogs
	-> linear floor evidence collection
	-> Entrance reservation
	-> one Entrance-origin cardinal distance flood
	-> farthest-valid Boss reservation
	-> purpose-required minimum reservations
	-> Boss and purpose-Area growth
	-> Generic Area coverage
	-> InterpretationData package
```

The system trusts generator-owned invariants: valid dimensions/cells, floor presence, and one cardinally connected floor region. It does not repeat generator validation or calculate a global graph diameter.

## Placement Behavior

Entrance claims a valid `2x4`, `4x2`, or `3x3` footprint with wall adjacency. One cardinal distance field is calculated from the completed Entrance Area. Boss candidates are tried farthest-first and reserve a `3x3` foundation.

All hard purpose Areas reserve their minimum foundations before any growing required Area expands. Boss and purpose Areas then grow under their individual caps and windows. Generic Areas claim remaining eligible floor last, up to 30 tiles each. Small or structurally ineligible remainder stays explicitly unzoned for later decoration/population work.

Area presence and mandatory multiplicity are hard. Spatial relationships—including near, around, adjacent, and progression bands—rank candidate geometry but do not cause failure when ideal spacing is unavailable. Balanced, compact, and sprawling Areas prefer their rectangular footprint and may fall back to equal-capacity connected floor inside their approved window. Strict Cell/Burial chain units retain exact seed geometry.

## Output Contract

`InterpretationData` contains:

- the exact original `MapData` object;
- selected purpose;
- row-major `zone_id_by_cell` ownership overlay (`0` means unzoned);
- mutable Zone records keyed by positive ID;
- Entrance and Boss Zone IDs;
- coverage ratio;
- unzoned floor coordinates.

Zone records contain role, requirement identity, origin, coordinates, bounds, tags, relationship metadata, target Zone IDs, and optional progression target.

Later consumers may transfer floor ownership through `reassign_cells(coordinates, destination_zone_id)`. The operation atomically synchronizes overlay ownership, source/destination coordinate collections, bounds, unzoned membership, and coverage. This supports later door cuts where an isolated piece of one Zone is cheaply absorbed by a neighboring Zone. Door detection and destination choice are not Layout Interpretation responsibilities.

## Responsibility Boundary

This system assigns semantic floor ownership only. It does not modify geometry or place doors, stairs, portals, lights, enemies, loot, traps, furniture, decoration, occupants, or other content. Occupant-family adaptation remains a later system.

## Validation

After Production promotion, the active System Integration matrix passed 168 checks across all 12 Medium/Large generator-to-interpreter combinations with Standard geometry. The complete interpretation catalog retained all 18 Purpose/Scale definitions and passed 187 checks. Medium Guard Tower passed 1,000 zero-retry stress runs. Small generation is pinned for future rework; earlier Small observations are historical evidence rather than active support.

Detailed evidence: [`SystemIntegrationEvidence.md`](../../Rooms/LayoutInterpretationRoom/Tables/PackageAndSurface/SystemIntegrationEvidence.md).
