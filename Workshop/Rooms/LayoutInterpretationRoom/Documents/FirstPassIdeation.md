```md
# Layout Interpretation System — Concept Draft

Status: Ideation
Purpose: Convert completed dungeon geometry into semantic gameplay zones without depending on generator internals.

## Input

Layout Interpretation consumes completed `MapData` only:

- `width`
- `height`
- row-major `cells`
- `ABYSS = 0`
- `FLOOR = 1`
- `WALL = 2`

The system must not depend on how the geometry was generated.

## Core Principle

Do not attempt to reconstruct the generator's original rooms.

Instead, claim useful contiguous areas of floor and define them as semantic **Zones**.

A Zone is a bounded set of traversable floor tiles that can be treated as one gameplay space.

Large open areas may naturally become multiple Zones.

## Zone Creation

Each Zone begins from an `OriginCoord`.

The Zone grows through controlled flood fill.

Conceptual inputs:

- `OriginCoord`
- `WidthLimit`
- `HeightLimit`
- `ZoneTileLimit`
- geometric boundaries
- already-claimed floor tiles

Example:

`WidthLimit = 8`
`HeightLimit = 6`
`ZoneTileLimit = 36`

The flood fill claims reachable floor until one of the limits stops further growth.

Because the fill is constrained by both dungeon geometry and hard limits, Zones may be irregular.

This is desirable.

## Coverage

After each Zone is created, calculate how much of the dungeon's traversable floor has been assigned to Zones.

Conceptually:

`TotalFloorPlanZoned()`

If coverage remains below the target threshold, create another Zone from valid unclaimed floor.

Initial conceptual coverage target:

`>= 85%`

Not every floor tile must belong to a formal Zone.

Small connectors, awkward slivers, narrow transitional areas, and insignificant leftovers may remain unzoned.

## Zone Priority

Zone creation should occur in priority order.

### Universal Required Zones

These exist regardless of dungeon family.

Examples:

- Player Spawn
- Boss
- Exit
- Other required portal / transition zones

Universal roles remain semantically stable even when their geometric requirements vary.

Example:

`BossZone` is always a Boss Zone, but a Dragon Boss Zone may require much more open space than a Goblinoid Boss Zone.

## Dungeon Families

Layout Interpretation defines a small set of broad dungeon families.

Initial families:

- Humanoid
- Insect
- Beast
- Dragon
- Goblinoid
- Undead

More specific creature types may later fall under these broader families.

Each family may define:

- required Zone types
- preferred Zone types
- Zone size limits
- Zone shape constraints
- fallback Zone types

No external proxy system is required yet.

The family definitions can live directly inside Layout Interpretation and may later be replaced or overridden by external data.

## Family-Driven Zone Language

Examples only:

### Humanoid
- Barracks
- Storage
- Common Area
- Guard Area

### Insect
- Nest
- Brood Chamber
- Feeding Area

### Beast
- Den
- Feeding Area
- Territory

### Dragon
- Lair
- Hoard Chamber

### Goblinoid
- Camp
- Guard Area
- Storage
- Refuse Pit

### Undead
- Crypt
- Ossuary
- Tomb
- Ritual Chamber
- Corpse Pit

These names are not yet final requirements.

The important rule is that dungeon family influences which semantic Zones should exist and what geometric limits they prefer.

## Fallback Zones

After universal and family-required Zones are created, remaining usable floor can be claimed by generic or family-appropriate fallback Zones.

Examples:

- Generic Mob Patrol
- Nesting
- Refuse Pit
- Storage
- Ambush Area

Fallback Zones allow the system to reach useful floor coverage without forcing every claimed area to represent a major room.

## Architectural Boundary

Layout Interpretation owns:

- identifying usable floor areas
- creating Zones
- assigning Zone IDs
- recording Zone tile membership
- assigning semantic Zone roles
- storing geometric metadata
- tracking Zone coverage

Layout Interpretation does **not** place:

- doors
- traps
- scenery
- lighting
- loot
- actors

Those later systems consume Zone metadata.

Example:

A later Population system may read:

`Zone.Role = PLAYER_SPAWN`

and place the player actor on a valid remaining tile inside that Zone.

## Emerging Pipeline

`Map Geometry`
→ `Layout Interpretation`
→ `Doors`
→ `Portals`
→ `Traps`
→ `Scenery`
→ `Lighting`
→ `Loot`
→ `Population`

Earlier systems establish constraints.

Later systems consume those constraints.

Population remains near the end because actors must adapt to the final occupied state of the dungeon.
```
