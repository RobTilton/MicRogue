# Micro Rogue — Defined Project Scope
Updated: 2026-09-23

---

**IMMUTABLE:** After Rob accepts this document, its content is immutable and must not be changed through routine implementation, reconciliation, documentation synchronization, or inferred authority.

**SOLE EXCEPTION:** This document may be changed only when a later task directly links this exact `Scope_Defined.md` file and explicitly authorizes a scope change to it.

## 1. Authority And Use

This document is the authoritative boundary for the intended completed Micro Rogue game. When an approved Room closes and the next project action is otherwise undefined, this document is the baseline for determining what remains inside the intended game.

This document defines completed-game scope. It does not define:

- The minimum viable product (MVP).
- Implementation order.
- Current repository or implementation state.
- Exact balance values.
- Final formulas.
- Mechanics whose design is explicitly unresolved.

Authority labels used here have exact meanings:

- **REQUIRED:** committed completed-game scope.
- **EXPLICITLY OUT OF SCOPE:** prohibited unless this document is deliberately changed under its sole exception.
- **UNRESOLVED:** required direction or relevant question whose exact design is intentionally undecided.
- **POSSIBLE FUTURE:** permitted for later consideration but not committed scope.
- **NON-BINDING EXAMPLE:** explanatory only; not a requirement.

Rules for interpretation:

1. Do not expand scope while applying this document.
2. Do not infer missing mechanics or add features for completeness.
3. Do not convert examples, implementation techniques, or historical designs into requirements.
4. Current implementation does not override this document.
5. Historical Micro Rogue designs do not override this document unless their requirements are represented here.
6. Preserve the distinction between world state, player knowledge, and character state.
7. Preserve every explicitly unresolved decision as unresolved until separately designed under valid task authority.
8. Possible-future concepts must not be treated as requirements or architectural assumptions.

Source basis: [`GameDefinitionV1.md`](GameDefinitionV1.md). That source packet is retained as the authorized input used to establish this defined scope. This document is the continuing scope authority after human acceptance.

## 2. Rapid Shape

Micro Rogue is a top-down procedural dungeon-exploration game strongly aligned with the design intent of classic *Rogue*. It uses real-time combat inside a persistent generated world.

The central persistence rule is:

> **The world is the game. The character is the player's current means of interacting with it.**

Characters are mortal. Character death does not reset the world. A newly rolled character enters the world left by earlier characters, while a deliberately created new world establishes a new world state and resets world-specific player knowledge.

Presentation is:

- 8-bit.
- Predominantly grayscale.
- Top-down.
- Permitted to use limited albedo or color shifts.
- Not intended to appear as a 3D game from the player's perspective.

Godot 3D or `GridMap` technology may be used as an implementation technique; it does not redefine the player-facing game as 3D.

## 3. State Ownership And Persistence

### 3.1 World State — REQUIRED

The world persists across characters. Persistent world state includes, at minimum, the following concepts:

- Geography and the Global Map.
- Generated Local Maps.
- Generated POIs and their layouts.
- Towns.
- Prosperity and Hostility.
- Trade routes.
- Boss state.
- Cleared or repopulated POIs.
- World time.
- World mutations.
- Consequences produced by previous characters.

A character's death does not regenerate or revert this state. A completely new world is created only through an explicit new-world or regeneration action.

### 3.2 Player Knowledge — REQUIRED

Player knowledge is distinct from both world state and character state. World existence does not automatically grant player knowledge.

World-specific knowledge may persist across characters in the same world. Required examples are:

- Identified item identities and effects.
- Previously seen towns.
- Previously discovered trade routes.

Creating or regenerating the world resets world-specific knowledge. This is limited cross-character persistence through knowledge, not conventional power-based meta progression.

### 3.3 Character State — REQUIRED

Each new character is rolled or generated with basic stats, and those stats materially affect gameplay. Characters gain levels and progress through Professions.

Professions are skill families, buckets, or trees through which characters gain abilities. Skill points are obtained primarily through leveling. Skills may also be acquired directly from rare sources.

A skill-granting book grants the specific skill contained in that book. It does not grant generic progression currency selected to fit the current build. Rare, high-value quests may also provide exceptional skill-progression rewards.

Character-specific progression does not automatically transfer to a later character after death.

## 4. World Structure And Generation

### 4.1 World Address Model — REQUIRED

The world uses a hierarchical, pointer-based location model:

```text
Global Map
    -> Global Coordinate / Local Map
        -> POI
            -> POI Floor
                -> Possible exceptional or portal-based destination
```

A Local Map has a Global Map coordinate that serves as its world address. POIs exist within Local Maps and may contain multiple floors.

Exceptional topology, including portal-based destinations, is architecturally permitted.

**UNRESOLVED:** The mechanics of exceptional or portal-based topology are not currently defined.

### 4.2 New-World Generation — REQUIRED

Creating a new world generates the entire Global Map. This does not require immediate full instantiation of every Local Map.

At world creation, the game generates:

- The Origin Local Map.
- Origin Town inside the Origin Local Map.
- Required starting-area POI content.
- All eight Local Maps surrounding the Origin Local Map.
- POIs for those eight neighboring Local Maps.

The initially detailed world is therefore a generated 3×3 Local Map region centered on the Origin Local Map.

After initial generation, detailed Local Maps expand lazily. When exploration reaches a new Local Map or Global coordinate, required neighboring Local Maps that do not yet exist may be generated around that frontier. The Global Map itself has already been established.

### 4.3 POI Persistence — REQUIRED

Once generated, a POI layout persists. Leaving and returning does not regenerate its original layout.

Persistent POIs may subsequently change through legitimate mutation, including:

- Player actions.
- World events.
- Repopulation.
- Other later-defined mutation systems.

The mutated result becomes the new persistent state.

**NON-BINDING EXAMPLE:** A sufficiently destructive interaction could eventually turn a tower into ruins. No trigger, damage threshold, collapse behavior, player damage, or recovery mechanic is established by this example.

### 4.4 POI Categories — REQUIRED

At scope level:

> **POI = Civilization + Dungeons**

Civilization represents settlements and other civilized POIs. “Dungeon” is a gameplay category, not a requirement that every dungeon be an underground stone structure.

Intended dungeon archetypes include:

- Caves.
- Ruins.
- Raider camps.
- Towers.
- Overgrown thickets.
- Bottoms of wells.
- Monster warrens.
- Nests.

Archetypes need not share identical topology or objectives.

## 5. Time, Travel, And World Continuity

### 5.1 World Time — REQUIRED

World time is a gameplay system. Its baseline real-time progression is:

> **10 real minutes = 1 world hour.**

Rest consumes:

> **6 world hours.**

Inn rest and camp rest consume the same amount of world time.

**UNRESOLVED:** Their healing, resource, and other detailed behavior remain downstream design.

### 5.2 Normal Travel — REQUIRED

Moving from one Local Map to an adjacent Local Map is a border crossing. Because Local Maps correspond to Global Map coordinates, this is also movement between adjacent Global coordinates.

A normal border crossing consumes:

> **3 world hours.**

**UNRESOLVED:** Movement and pathfinding within Local Maps remain downstream design.

### 5.3 Trade Routes And Fast Travel — REQUIRED

Trade routes are created through the Prosperity system when qualifying settlement prosperity and influence relationships meet required conditions.

**UNRESOLVED:** Exact trade-route thresholds remain downstream design.

Fast travel is available only along established trade routes. It does not teleport the character: the character still traverses the physical route through the world. Fast travel removes the normal border-crossing time cost for that traversal.

Trade routes improve connectivity without bypassing geography.

### 5.4 Discovery — REQUIRED

A town or trade route may exist without being known to the player. Generation or simulation alone does not mark it as known. The player must see or discover it before it enters persistent player knowledge.

### 5.5 New-Character Starting Location — REQUIRED

The first character starts in Origin Town.

After a character dies, a later character may begin in:

- Origin Town; or
- A previously seen town connected to Origin Town through a trade-route path the player has previously discovered.

An undiscovered town is ineligible. An undiscovered trade route cannot establish eligibility. This expands future starting options through knowledge and world development without directly increasing character power.

## 6. Characters, Actors, And Combat

### 6.1 Shared Actor-System Invariant — REQUIRED

> **Every gameplay system the player can touch must also be available to applicable enemy actors.**

This includes equipment, skills, item use, and relevant environmental or world interactions. The invariant is especially important because enemies are intended to include intelligent humanoid actors.

Player actors and enemy actors must not receive separate duplicated versions of the same gameplay systems merely because one is player-controlled.

Shared access does not imply:

- Equal possession.
- Equal rarity.
- Equal opportunity.
- Equal intelligence or behavior.
- Equal progression.
- That every enemy uses every system.

An enemy's ability to equip a God-Touched weapon, for example, does not make God-Touched equipment common among ordinary enemies.

### 6.2 Combat — REQUIRED

Combat is real-time. Historical turn-based Micro Rogue designs are not authoritative for this scope.

**UNRESOLVED:** Exact combat mechanics, damage and healing formulas, resource systems, and balance remain downstream design.

### 6.3 Enemies And Families — REQUIRED

Enemies exist in Families: groupings or factions of related actors. Enemy Families can be hostile toward one another; hostile actors are not treated as one unified faction.

Enemies are intended to be primarily intelligent or humanoid, supporting the shared actor-system invariant. Other creature and enemy types remain permitted.

**UNRESOLVED:** Exact Family relationships, behaviors, spawning rules, and AI remain downstream design.

## 7. Character Progression

### 7.1 Professions And Skills — REQUIRED

**REQUIRED:** Profession and skill progression are committed completed-game scope.

**UNRESOLVED:** The grid-based active skill board is the protected current direction, but its final presentation, structure, and mechanical implementation are not yet settled. It must not be casually removed or replaced during unrelated work; changing that direction requires valid design authority. Historical skill-board implementations are not automatically authoritative.

## 8. Items, Equipment, And Identification

### 8.1 Weapons And Armor — REQUIRED

Weapons and armor use multiple independent item-generation dimensions. Required conceptual dimensions include:

- Material Tier.
- Weapon or Equipment Shape Tier.
- Quality Tier.

Equipment quality affects access to affixes. Affixes are not universally available at all quality levels. The highest quality levels gain access to affixes, with God-Touched occupying the extreme legendary-equivalent end of generation.

**UNRESOLVED:** Exact tier names and numerical distributions remain downstream item-system design unless separately established later.

### 8.2 God-Touched Equipment — REQUIRED

God-Touched is both an exceptional quality state and an affix gate. God-Touched weapons and armor can access special affixes unavailable to ordinary equipment.

God-Touched status is required for weapons or armor to exceed the normal limit of two affixes. God-Touched equipment is exceptionally rare.

Established divine identities are:

- Abyssious.
- Kalamitous.
- Sizzliarad.

**UNRESOLVED:** Exact divine affix catalogs and effects remain downstream item-system design.

### 8.3 Rings — REQUIRED

Rings do not use the standard weapon-and-armor generation model. Their structure includes:

- Lesser/Greater paired concepts.
- Greater-only concepts.
- God-Touched-only concepts or categories where applicable.

Rings do not receive God-Touched affixes. This restriction is intentional.

### 8.4 Necklaces — REQUIRED

Necklaces do not use the standard weapon-and-armor generation model. A necklace has only one affix total and may receive a God-Touched result.

When a necklace rolls God-Touched, its available affix pool changes to permit God-Touched affixes while excluding ordinary lower-tier options according to the later-defined high-end necklace rules.

**UNRESOLVED:** Exact jewelry tables remain downstream design.

### 8.5 Identification — REQUIRED

Rogue-style identification is part of the game. Certain item categories or interactions may have hidden, world-specific identities, and their names or identities may differ between generated worlds.

Once discovered, an identity persists as player knowledge across characters in that world. A new world resets this identification knowledge.

The intended interaction space includes concepts such as:

- Throwing items.
- Drinking unidentified potions.
- Wearing rings.
- Curses.
- Strange fountains.
- Dipping items into uncertain substances.

This list establishes intended interaction space, not an exact interaction catalog.

**UNRESOLVED:** The exact interaction catalog remains downstream design.

### 8.6 Equipment Durability — EXPLICITLY OUT OF SCOPE

Gear does not break. Weapon and armor degradation must not be introduced as a maintenance system.

### 8.7 Crafting — EXPLICITLY OUT OF SCOPE

There is no crafting system. Crafting must not be assumed as support for equipment, economy, survival, or progression.

## 9. Magic And World Mutation

### 9.1 Magic — REQUIRED

**REQUIRED:** Magic exists at the world and completed-game scope level and is not intended to be universally mundane. It entered the world as a consequence of an ongoing conflict among the gods.

This conflict supports:

- Magical world events.
- God-Touched equipment.
- Rare magical equipment.
- World mutation.

Magic is strongly associated with rings and high-end equipment.

**UNRESOLVED:** Exact spell systems, mana systems, healing mechanics, and magical formulas remain downstream design.

### 9.2 World Mutation — REQUIRED

The persistent world can change physically over time. After sufficient world time, events may include:

- Earthquakes.
- Volcanic events.
- Mystical events.
- Other consequences of the conflict among the gods.

World mutation may alter existing persistent locations.

**UNRESOLVED:** Event timing, probability, mutation algorithms, and effects remain unresolved implementation and design concerns.

## 10. Civilization, Danger, And Economy

### 10.1 Prosperity — REQUIRED

Settlements have a deliberately limited Prosperity system. Positive influences include settlement or town tier and completed quests. Nearby dangerous POIs and boss power suppress Prosperity.

Prosperity affects civilized economic quality. Higher Prosperity can provide access to better gear through the economy. Prosperity also participates in forming trade routes between settlements.

**UNRESOLVED:** Exact Prosperity radii, formulas, thresholds, and numerical values remain downstream design.

### 10.2 Hostility — REQUIRED

Hostility is not a direct punishment meter for the player. Its primary responsibilities are:

1. Suppressing Prosperity.
2. Increasing the potential loot and equipment power circulating among hostile NPCs and enemies.

High Hostility represents increased danger paired with increased potential reward.

**UNRESOLVED:** Exact loot modification, equipment-generation behavior, and numerical formulas remain downstream design.

### 10.3 Quests — REQUIRED

Quests are generated from relationships among town influence, relevant POIs, and boss-bearing POIs. Exceptional threats may generate rare or high-value heroic quests.

**UNRESOLVED:** Exact quest templates, algorithms, terminology, and rewards remain downstream design.

### 10.4 Shops And Economy — REQUIRED

Items can be bought from and sold to shops. Shops refresh or reset on a seven-world-day cycle. Prosperity affects economic and item quality.

**UNRESOLVED:** Whether merchants must be individually persistent, fully simulated Actors or may instead be service interfaces is not yet settled.

## 11. Death And Continuing World State

### 11.1 Death — REQUIRED

Death is death. When a player character dies:

1. The character dies in the world.
2. Their body and possessions initially become world state.
3. The world advances seven days before the next character enters.
4. Time-dependent systems advance accordingly, including shop refresh behavior.
5. Some corpse contents may be removed during the interval.
6. World actors may interact with or acquire remaining possessions.
7. The corpse itself may be silently removed.
8. A newly rolled character enters the same persistent world.

The game does not guarantee that a dead character's equipment remains available for retrieval.

### 11.2 Corpse-Run Boundary — REQUIRED

**REQUIRED:** The game is not designed around a conventional corpse-run loop. A later character may encounter remaining possessions or other consequences of an earlier death because the world persists, but that emergence is not a promise of recoverable equipment.

### 11.3 POI Repopulation — REQUIRED

Cleared POIs can repopulate over time. On the weekly cycle, an eligible cleared POI has a chance to repopulate using an appropriate local Family. Boss-state eligibility must be respected.

The currently discussed chance is 10 percent, but that number is a balance value rather than a permanent scope invariant unless separately locked.

**UNRESOLVED:** The exact repopulation implementation remains downstream design.

### 11.4 Saving — REQUIRED

The gameplay contract does not intentionally support save-scumming. World changes and character death are intended to become authoritative saved state.

**UNRESOLVED:** Serialization frequency and technical save implementation are not defined by this scope.

### 11.5 Conventional Meta Progression — EXPLICITLY OUT OF SCOPE

Repeated deaths must not permanently raise the baseline power of later characters through conventional roguelite meta progression.

Persistent consequences and knowledge are permitted and required where specified. Examples include a more prosperous world after completed quests, a boss remaining dead, changed Hostility, formed trade routes, known item identities, and known towns or routes. These are world consequences or player knowledge, not account-level character-power upgrades.

## 12. End-Condition Boundary — REQUIRED

**REQUIRED:** Completed-game scope does not require a formal victory or end condition. The persistent world may continue as long as the player wishes, and the player may eventually abandon or regenerate it.

Do not invent a final boss, campaign victory, world-completion condition, or credits trigger solely to provide a conventional ending.

## 13. Explicitly Unresolved Simulation Boundary

### 13.1 Off-Screen Simulation Depth — UNRESOLVED

**UNRESOLVED:** The required depth of autonomous world simulation is not defined. Persistence does not imply:

- Autonomous global NPC travel.
- Autonomous quest completion.
- Fully simulated economies.
- Persistent individual lives for every NPC.
- Autonomous dungeon clearing.
- Autonomous character progression.

Explicit time-dependent systems—including shop refresh, POI repopulation, and world mutation—must advance as required.

**UNRESOLVED:** Simulation beyond explicitly defined behavior is not yet settled.

## 14. Possible Future Scope

### 14.1 NPC Adventurers — POSSIBLE FUTURE

Autonomous NPC adventurers are not required. Architecture must not assume that a full autonomous adventurer simulation will exist, but flexibility must not be removed solely to prohibit later consideration.

### 14.2 Limited Cross-Character Storage — POSSIBLE FUTURE

A future bank or storage system might intentionally preserve a small number of items between player characters. It is not required and must not be implemented or assumed until deliberately designed.

## 15. Completed-Game Scope Boundary

**REQUIRED:** Micro Rogue is intended to contain:

- A persistent generated world.
- Mortal, rolled characters.
- Real-time combat.
- Character stats and leveling.
- Profession and skill progression.
- Procedural dungeon exploration.
- Persistent POIs.
- Intelligent enemies using shared gameplay systems.
- Equipment and rare affixes.
- Identification.
- Curses and uncertain world interactions.
- Towns and shops.
- Quests.
- Prosperity and Hostility.
- Enemy Families and factional relationships.
- Trade routes.
- World time.
- Fast travel through physical trade routes.
- World mutation.
- Knowledge persistence across characters.
- Consequences that survive character death.

**EXPLICITLY OUT OF SCOPE:** Micro Rogue is not:

- A crafting game.
- A durability or gear-maintenance game.
- A conventional meta-progression roguelite.

**REQUIRED:** Micro Rogue is not intended to appear as a 3D action game from the player's perspective, and completed-game scope does not require a formal victory condition.

**UNRESOLVED:** The game is not defined as a full autonomous-world simulator; the permitted simulation depth is the unresolved boundary in Section 13.

**POSSIBLE FUTURE:** NPC adventurers are not required completed-game scope; their explicitly limited future status is defined in Section 14.1.

## 16. Downstream Decision Rule

Future design and implementation may select mechanics only within this boundary and within the authority of the task that selects them. A required system does not authorize an agent to independently settle its unresolved presentation, algorithm, formula, balance, content catalog, or simulation depth.

When no approved work remains after a Room closes:

1. Consult this document to identify required completed-game capability not yet represented by authoritative current-state evidence.
2. Do not treat that identification as execution authority.
3. Establish a new bounded task or Room through MCA alignment before implementation.
4. Preserve unresolved decisions for Rob unless a later task explicitly delegates them.
5. Never introduce an explicitly excluded or merely possible-future system as required work.
