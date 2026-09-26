# Layout Interpretation Purpose Contract
Updated: 2026-09-26
Checkpoint: `[LayoutInterpretationRoom]+[ArchitectureCatalog]+[PurposeContract]`
Implementation baseline/evidence: Implemented in `Production/Systems/LayoutInterpretationSystem/ArchitectureCatalog/`; Production promotion validated on 2026-09-26; Git checkpoint unknown.

## Rapid Shape

Layout Interpretation receives completed generator-independent `MapData`, one approved architectural purpose, and the Scale used to generate that map. Purpose plus Scale resolves the required-Area program. It claims universal Areas first, then the resolved required Areas in declared order, then distinct `GENERIC_AREA` claims from useful remaining floor. It describes geometry and meaning without changing map cells or placing content.

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

The lists below are the Medium baseline. Small removes requirements that do not fit its intended architectural program; Large expands repeated Areas. Area geometry contracts do not otherwise change by Scale.

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

1. `ARMORY_AREA` x1 near `ENTRANCE_AREA`.
2. `ARMORY_AREA` x1 pushed toward the middle of navigable Entrance-to-Boss progression.
3. `BARRACKS_AREA` x1 adjacent to the middle Armory Area.
4. `GUARD_POST_AREA` x1 preferring `ENTRANCE_AREA` after the more constrained foundations are reserved.

The initial contract requires exactly two Armories.

All spatial relationships are placement preferences, not failure conditions. Within two tiles, adjacency, and progression targets rank candidate geometry; when the ideal position is unavailable, the closest valid placement is accepted. Required Area presence and multiplicity remain hard.

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

## Scale Variations

Universal `ENTRANCE_AREA` and `BOSS_AREA` remain exactly once at every Scale.

| Purpose | Small | Medium | Large |
|---|---|---|---|
| `PRISON` | Entrance Guard x1; Cell Area x1; no Cell-area Guard | Baseline | Entrance Guard x1; Cell-area Guards x2; Cell Areas x2-4 around those Guards |
| `CATACOMB` | Baseline | Baseline | Shrines x2; Burial Chambers x2-5 |
| `MAGE_TOWER` | Library x1; Alchemy Lab x1; no Scrying Chamber | Baseline | Libraries x2; Scrying Chamber x1; Alchemy Lab x1 |
| `GUARD_TOWER` | Entrance Armory x1; Entrance Guard x1; no middle Armory or Barracks | Baseline | Baseline plus a second Barracks; both Barracks prefer the middle Armory |
| `BURROW_NEST` | Baseline | Baseline | Nesting/Resting x2; Food Storage x2 |
| `MINE_SHAFT` | Entrance Guard x1; Depot x1; Equipment Storage x1 near 50% progression | Baseline | Entrance Guard x1; Depot x1; Equipment Storage x3 near 25%, 50%, and 75% progression |

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
