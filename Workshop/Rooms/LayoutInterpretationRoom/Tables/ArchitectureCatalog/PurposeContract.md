# Layout Interpretation Purpose Contract
Updated: 2026-09-25
Checkpoint: `[LayoutInterpretationRoom]+[ArchitectureCatalog]+[PurposeContract]`
Implementation baseline/evidence: Approved design contract only. No Layout Interpretation implementation exists; Git checkpoint is unknown.

## Rapid Shape

Layout Interpretation receives completed generator-independent `MapData` plus one approved architectural purpose. It claims universal Areas first, then the purpose's required Areas in declared order, then distinct `GENERIC_AREA` claims from useful remaining floor. It describes geometry and meaning without changing map cells or placing content.

The initial catalog is clamped to six purposes: two for each current Map Generation Archetype. Occupant family does not define original architecture and is not an input to this contract.

## Universal Claim Order

Every interpretation begins with exactly two universal claims:

1. `ENTRANCE_AREA` x1.
2. `BOSS_AREA` x1, grown from the valid floor region at the greatest navigable distance from Entrance.

Entrance is the semantic spawn area but places no player, door, stairs, portal, or other content. Boss identifies the major destination but places no boss, loot, furniture, encounter, or other content. Boss growth may encompass multiple visually room-like pockets; later systems may differentiate their contents.

After universal claims, the selected purpose's requirements execute in their declared order. Relationships may refer to Zones established earlier in that order.

## Approved Purpose Catalog

| Map Generation Archetype | Approved purposes |
|---|---|
| `DUNGEON` | `PRISON`, `CATACOMB` |
| `TOWER` | `MAGE_TOWER`, `GUARD_TOWER` |
| `CAVE` | `BURROW_NEST`, `MINE_SHAFT` |

No additional purpose belongs to the initial catalog.

## Ordered Purpose Requirements

### Prison

Purpose key: `PRISON`

1. `GUARD_POST_AREA` x1 near `ENTRANCE_AREA`.
2. `GUARD_POST_AREA` x1 designated as the Cell-area anchor.
3. `CELL_AREA` x1-3, related spatially to the Cell-area Guard Post.

The later Claim and Zoning work owns the mechanics that place the second Guard Post and grow the Cell Zones around it. This contract establishes the relationship, not its algorithm.

### Catacomb

Purpose key: `CATACOMB`

1. `SHRINE_AREA` x1.
2. `BURIAL_CHAMBER_AREA` x1-4.

A size-dependent second Shrine is outside the initial contract.

### Mage Tower

Purpose key: `MAGE_TOWER`

1. `LIBRARY_AREA` x1.
2. `SCRYING_CHAMBER_AREA` x1.
3. `ALCHEMY_LAB_AREA` x1.

Multi-level Tower additions are deferred until multi-level layouts are an actual supported requirement.

### Guard Tower

Purpose key: `GUARD_TOWER`

1. `GUARD_POST_AREA` x1 near `ENTRANCE_AREA`.
2. `ARMORY_AREA` x1 near `ENTRANCE_AREA`.
3. `ARMORY_AREA` x1 pushed toward the middle of navigable Entrance-to-Boss progression.
4. `BARRACKS_AREA` x1 adjacent to the middle Armory Area.

The initial contract requires exactly two Armories.

### Burrow / Nest

Purpose key: `BURROW_NEST`

1. `NESTING_RESTING_AREA` x1, preferring the middle region of navigable Entrance-to-Boss progression.
2. `FOOD_STORAGE_AREA` x1.

`REFUGE` is not a separate required Zone. The universal Boss Zone fulfills that spatial function for the initial scope.

### Mine Shaft

Purpose key: `MINE_SHAFT`

1. `GUARD_POST_AREA` x1 near `ENTRANCE_AREA`.
2. `DEPOT_AREA` x1.
3. `EQUIPMENT_STORAGE_AREA` x2, distributed at target positions near 35% and 70% of navigable Entrance-to-Boss progression.

The percentage targets are approximate placement intent, not exact coordinate-distance requirements.

## Generic Completion

After all universal and purpose-required claims succeed, the interpreter claims distinct `GENERIC_ZONE` instances from useful remaining floor. Every instance has a unique Zone ID and explicit tile membership but no invented architectural or gameplay purpose.

The initial system does not add Patrol, Storage, Hallway, or other speculative generic roles. Later systems may interpret or use `GENERIC_AREA` claims without requiring Layout Interpretation to predict their contents.

The complete successful output contains:

- exactly one Entrance Zone;
- exactly one Boss Zone;
- every required Zone for the selected purpose;
- zero or more uniquely identified `GENERIC_AREA` claims;
- honest information about any remaining unzoned floor.

## Ownership And Deferred Mechanics

This contract owns the approved purpose vocabulary, required roles, multiplicities, order, and spatial relationships. It does not define:

- Zone dimensions, shapes, openness, or growth limits;
- how a value is selected within a count range;
- route-analysis or Zone-claim algorithms;
- the final generic coverage target;
- randomness or determinism guarantees;
- concrete Godot classes, dictionaries, Resources, or serialization;
- doors, portals, stairs, traps, scenery, lighting, loot, actors, occupants, furnishings, decorations, or encounters.

Those decisions belong to later DOTS Boxes. A successful final subsystem will pair the interpreted Zone list with the exact `MapData` whose coordinates it describes and will not return partial interpretation data on failure.

## Validation And Current Limits

- Rob confirmed the six-purpose catalog and the complete requirement set in conversation on 2026-09-25.
- Contract consistency was checked against the active Room DOTS and Architecture Catalog direction.
- This is design evidence only; no runtime behavior has been implemented or tested.
- Human approval applies to this Purpose Contract, not to future implementation mechanics or Production adoption.
