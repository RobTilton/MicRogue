# Layout Interpretation Zone Contract
Updated: 2026-09-25
Checkpoint: `[LayoutInterpretationRoom]+[ZoneCatalog]+[ZoneContract]`
Implementation baseline/evidence: Approved design contract only. No Layout Interpretation implementation exists; Git checkpoint is intentionally not recorded here.

## Rapid Shape

Layout Interpretation assigns semantic Areas to portions of an otherwise meaningless connected floor plan. The source generator does not create recoverable rooms; it surfaces randomized connected `MapData`. Area definitions therefore provide loose claim requirements, not templates for reconstructing architecture.

The governing rule is: strict contracts, loose placement. Hard minimums determine validity. Growth limits contain claims. Preferences rank valid choices but never cause failure. Relationships guide claims when required by the selected purpose. Tags tell downstream systems what an Area permits, encourages, or forbids.

## Global Ownership And Claim Language

Layout Interpretation claims and tags Areas only. It places no doors, lights, actors, enemies, bosses, scenery, furnishings, loot, traps, portals, stairs, cells, shelves, beds, equipment, decorations, encounters, or other constructed content.

Every successful Area claim produces at least:

- a unique Area/Zone ID;
- an approved Area role;
- exact claimed floor coordinates;
- applicable semantic tags;
- geometric metadata;
- applicable relationships to other claimed Areas.

The following terms are authoritative:

- **Hard minimum:** floor capacity required for a valid claim. If it cannot be met, try another origin.
- **Growth:** how a valid seed may claim additional connected, unclaimed floor.
- **Maximum claimed tiles:** a hard cap on tile membership.
- **Bounding window:** the maximum width and height containing the complete claim; rotation is allowed where dimensions differ.
- **Preference:** a ranking signal among valid claims. Failure to satisfy it cannot invalidate placement.
- **Relationship:** purpose-level or Area-level placement intent involving another claimed Area.
- **Tag:** downstream semantic intent. A tag never claims its associated content already exists.

Pathing and flood growth use four-directional floor connectivity. Diagonal corner-to-corner contact is not traversable connectivity.

## Tag Semantics

Tags expose later-system opportunities or restrictions without placing content:

- `ENTRANCE`: semantic entry/spawn Area.
- `BOSS`: semantic boss-use Area.
- `NO_ENEMY`: prohibits later enemy placement.
- `ENEMY`: permits or encourages later enemy use.
- `LIGHT`: requests later lighting treatment.
- `NO_LIGHT`: invariant prohibition on later lighting; this exact spelling and meaning must be preserved.
- `LOCKABLE`: permits later access control.
- `LOOTABLE`: permits or encourages later loot use.
- `TRAPPED`: permits or encourages later trap use.
- `SWARM`: permits or encourages clustered population.
- `ARCANE`: requests later arcane treatment.
- `DIVINITY`: requests later divine treatment.
- `CROSS_FAMILY(ABERRATION)`: identifies an Area useful to a future Aberration occupant-family pass.
- `CROSS_FAMILY(ELEMENTAL)`: identifies an Area useful to a future Elemental occupant-family pass.

Except for invariant prohibitions such as `NO_LIGHT` and `NO_ENEMY`, exact downstream behavior remains owned by the consuming systems.

## Universal Areas

### Entrance Area

Role: `ENTRANCE_AREA`

Hard minimum:

- Claim exactly one `2x4`, `4x2`, or `3x3` floor footprint.
- At least one footprint side must be wall-adjacent.

Growth:

- None. The Area remains the selected minimum footprint.

Preferences:

- Prefer wall adjacency on at least two sides.

Relationships:

- None. Entrance becomes the reference origin for navigable progression.

Tags:

- `ENTRANCE`
- `NO_ENEMY`
- `LIGHT`

### Boss Area

Role: `BOSS_AREA`

Hard minimum:

- Initial valid floor footprint: `3x3`.
- Use the farthest valid claim geometry found from Entrance-distance ordering.

Growth:

- Flood through connected, unclaimed floor.
- Maximum claimed tiles: 50.
- Bounding window: `8x8`.
- May cross narrow connections and encompass multiple smaller geometric pockets.

Preferences:

- Prefer the largest usable connected space at the selected distant location.
- Prefer a single open area, but accept multiple connected smaller pockets.

Relationships:

- Farthest valid Area found by descending cardinal distance from `ENTRANCE_AREA`.

Tags:

- `BOSS`
- `LIGHT`

## Purpose Areas

### Guard Post Area

Role: `GUARD_POST_AREA`

Hard minimum:

- `3x3` floor footprint.

Growth:

- Maximum claimed tiles: 20.
- Bounding window: `5x5`.

Preferences:

- Prefer placement along the central Entrance-to-Boss path.
- When a companion Area is defined, prefer placement within two walkable tiles of it.
- If two-tile proximity is unavailable, place as close as valid geometry permits.
- Companion proximity can never prevent an otherwise valid claim.

Tags:

- `ENEMY`
- `LIGHT`
- `LOCKABLE`

### Cell Area

Role: `CELL_AREA`

Hard minimum:

- Reserve enough floor capacity for a later `2x2` cell unit multiplied by the selected cell-chain length.
- The capacity footprint may rotate.

Growth:

- No separate flood-fill tile cap.
- Bounding window: `12x12`.
- A larger claim may reserve capacity for longer or multiple future cell rows; Layout Interpretation does not place those cells or their spacing.

Preferences:

- Prefer long wall-adjacent claims.

Tags:

- No unique tags.

### Shrine Area

Role: `SHRINE_AREA`

Hard minimum:

- `3x3` floor footprint.

Growth:

- Maximum claimed tiles: 30.
- Bounding window: `8x8`.

Preferences:

- Prefer open floor.
- Minimize wall contact across the completed flood claim.

Tags:

- `LIGHT`
- `DIVINITY`

### Burial Chamber Area

Role: `BURIAL_CHAMBER_AREA`

Geometry:

- Copy `CELL_AREA` hard-minimum, growth, rotation, bounding-window, and wall-preference behavior.
- Interpret the reserved capacity as a future burial chain rather than a future cell chain.

Tags:

- `SWARM`

`CELL_AREA` tags are not inherited.

### Library Area

Role: `LIBRARY_AREA`

Hard minimum:

- `2x4` or `4x2` floor footprint.

Growth:

- Maximum claimed tiles: 24.
- Bounding window: `4x8` or `8x4`.

Preferences:

- Prefer long claims.
- Prefer useful wall adjacency.

Tags:

- `LOOTABLE`
- `ARCANE`

### Scrying Chamber Area

Role: `SCRYING_CHAMBER_AREA`

Hard minimum:

- `3x3` floor footprint.

Growth:

- Maximum claimed tiles: 16.
- Bounding window: `5x5`.

Preferences:

- Prefer the central region of the map.

Tags:

- `LIGHT`
- `ARCANE`

### Alchemy Lab Area

Role: `ALCHEMY_LAB_AREA`

Hard minimum:

- `3x5` or `5x3` floor footprint.

Growth:

- Maximum claimed tiles: 40.
- Bounding window: `8x8`.
- May span multiple smaller geometric pockets connected by floor.

Preferences:

- Prefer a sprawling claim.

Tags:

- `LOOTABLE`
- `SWARM`
- `ARCANE`

### Armory Area

Role: `ARMORY_AREA`

Hard minimum:

- `5x5` floor footprint.

Growth:

- Maximum claimed tiles: 36.
- Bounding window: `8x8`.

Preferences:

- Prefer rectangular claims whose side lengths are as close as possible.
- Prefer proportions such as `5x5`, `5x6`, or `6x7` over `4x8`.
- When a companion Area is defined, prefer placement within two walkable tiles of it.
- If two-tile proximity is unavailable, place as close as valid geometry permits.
- Companion proximity can never prevent an otherwise valid claim.

Tags:

- `LOOTABLE`
- `TRAPPED`
- `ENEMY`

### Barracks Area

Role: `BARRACKS_AREA`

Hard minimum:

- `3x5` or `5x3` floor footprint.

Growth:

- Maximum claimed tiles: 30.
- Bounding window: `6x10` or `10x6`.
- May sprawl within the bounding window.

Preferences:

- None intrinsic. A selected purpose may define a relationship to a companion Area.

Tags:

- `SWARM`
- `ENEMY`
- `LIGHT`
- `LOCKABLE`

### Nesting Resting Area

Role: `NESTING_RESTING_AREA`

Hard minimum:

- `3x3` floor footprint.

Growth:

- Maximum claimed tiles: 20.
- Bounding window: `5x5`.

Preferences:

- Prefer a confined, compact area.
- Prefer the middle region of Entrance-to-Boss navigable progression.

Tags:

- `LOOTABLE`
- `SWARM`
- `NO_LIGHT`
- `TRAPPED`

### Food Storage Area

Role: `FOOD_STORAGE_AREA`

Hard minimum:

- `3x3` floor footprint.

Growth:

- Maximum claimed tiles: 50.
- Bounding window: `10x10`.
- May sprawl within the bounding window.

Preferences:

- None.

Tags:

- `SWARM`
- `NO_LIGHT`
- `CROSS_FAMILY(ABERRATION)`

### Depot Area

Role: `DEPOT_AREA`

Hard minimum:

- `5x5` floor footprint.

Growth:

- Maximum claimed tiles: 40.
- Bounding window: `12x12`.

Preferences:

- Prefer a condensed claim.
- Minimize wall contact.

Tags:

- `CROSS_FAMILY(ELEMENTAL)`

### Equipment Storage Area

Role: `EQUIPMENT_STORAGE_AREA`

Geometry:

- Copy `ARMORY_AREA` hard-minimum, growth, bounding-window, rotation, and balanced-rectangle preference behavior.

Placement:

- Space instances across Cave progression.
- The Mine Shaft purpose targets positions near 35% and 70% of Entrance-to-Boss navigable progression.

Tags:

- `LOOTABLE`

Armory tags and companion relationships are not inherited.

## Generic Area

Role: `GENERIC_AREA`

Hard minimum:

- Requires a valid `2x2` seed footprint.
- Fewer than four remaining usable tiles cannot begin a Generic Area.

Growth:

- Flood through connected, unclaimed floor.
- Maximum claimed tiles: 30.
- No width/height bounding window.
- May sprawl through openings, hallways, and one-tile-wide chains.
- When 30 tiles are claimed, close the Area and begin a new Generic Area from another eligible seed.

Preferences:

- None.

Remainders:

- A leftover region that cannot provide the minimum seed remains unzoned.
- If three tiles remain after a Generic Area reaches 30, those tiles remain unzoned. Do not force absorption or distort an existing claim.

Tags:

- `ENEMY`
- `LOOTABLE`
- `SWARM`
- `TRAPPED`

## Universal Placement Contract

Entrance claims first from geometry satisfying its profile. One four-directional distance flood begins from the completed Entrance Area. Boss candidates are attempted from greatest Entrance distance toward least distance, and the first complete valid Boss claim is accepted.

There is no global longest-route calculation, reconstructed room model, endpoint comparison, or upstream connectivity confirmation. The closed generator pipeline guarantees a single connected floor region.

## Validation And Current Limits

- Rob approved all Area requirements, limits, preferences, relationships, and tags in conversation on 2026-09-25.
- The contract was checked against the approved Purpose Contract and Room DOTS.
- The Room-local catalogs and claim passes implement and test this contract. Public packaging and Production promotion remain later work.
