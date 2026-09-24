# DWR — MICRO ROGUE SCOPE DEFINITION HANDOFF

## Objective

Create the authoritative `Scope_Defined.md` for **Micro Rogue**.

This document defines the intended **completed game**.

It does **not** define:

* MVP.
* Implementation order.
* Current repository state.
* Exact balance values.
* Final formulas.
* Systems whose design is explicitly unresolved.

Do not expand scope while documenting it.

---

## 1. Authority Rules

1. Statements marked **REQUIRED** are authoritative scope.
2. Statements marked **EXPLICITLY OUT OF SCOPE** must not be introduced without a later deliberate scope change.
3. Statements marked **UNRESOLVED** are intentionally undecided. Do not resolve them.
4. Statements marked **POSSIBLE FUTURE** are not requirements.
5. Current implementation does not override this specification.
6. Historical Micro Rogue designs do not override this specification unless represented here.
7. Do not infer missing mechanics.
8. Do not convert examples into requirements.
9. Do not add features for completeness.
10. Preserve the distinction between:

* world state,
* player knowledge,
* character state.

11. Implementation details should not be promoted into scope requirements unless explicitly specified below.

---

# 2. Core Identity — REQUIRED

Micro Rogue is a **top-down procedural dungeon-exploration game** strongly aligned with the design intent of classic *Rogue*.

Presentation is:

* 8-bit.
* Predominantly grayscale.
* Top-down.
* Potential limited albedo/color shifts are acceptable.
* The game is **not intended to be a 3D game** from the player's perspective.

The current use of Godot 3D/GridMap technology is an implementation technique and does not redefine the game as a 3D game.

The central persistence model is:

> **The world is the game. The character is the player's current means of interacting with it.**

Characters are mortal.

The world persists across characters.

---

# 3. Primary Persistence Model — REQUIRED

Character death does **not** reset the world.

Persistent world state includes, at minimum, concepts such as:

* Geography.
* Generated Local Maps.
* Generated POIs and their layouts.
* Towns.
* Prosperity.
* Hostility.
* Trade routes.
* Boss state.
* Cleared/repopulated POIs.
* World time.
* World mutations.
* Consequences produced by previous characters.

A new character enters the existing world rather than receiving a regenerated copy of it.

A completely new world is created only through an explicit new-world/regeneration action.

---

# 4. Player Knowledge — REQUIRED

Player knowledge is distinct from both world state and character state.

Knowledge may persist across characters within the same world.

Current required examples include:

* Identified item identities/effects.
* Previously seen towns.
* Previously discovered trade routes.

Regenerating the world resets world-specific knowledge.

This is the intended form of limited cross-character persistence.

It is **knowledge persistence**, not conventional power-based meta progression.

---

# 5. Character State — REQUIRED

Each new character is rolled/generated with basic stats.

Stats materially affect gameplay.

Characters gain levels.

Character progression includes **Professions**.

Professions are skill families/buckets/trees through which characters gain abilities.

Skill points are primarily obtained through leveling.

Skills may also be acquired directly from rare sources.

A skill-granting book grants the specific skill contained in that book. It does not provide generic build-compatible progression currency.

Rare high-value quests may also provide exceptional skill progression rewards.

Character-specific progression does not automatically transfer to the next character after death.

---

# 6. Profession / Skill Interface — REQUIRED DIRECTION, DESIGN UNRESOLVED

Profession and skill progression are required.

The final presentation and mechanical implementation are unresolved.

A **grid-based active skill board** is the current intended direction and must not be casually removed or replaced during unrelated implementation work.

Its exact structure is not yet authoritative.

Historical implementations of the skill board are not automatically authoritative.

---

# 7. Shared Actor-System Invariant — REQUIRED

> **INVARIANT: Every gameplay system the player can touch must also be available to applicable enemy actors.**

Examples include:

* Equipment.
* Skills.
* Item use.
* Relevant environmental/world interactions.

This invariant primarily matters because enemies are intended to include intelligent humanoid actors.

Player and enemy actors should not receive separate duplicated versions of the same gameplay systems merely because one is player-controlled.

Shared access does **not** imply:

* Equal possession.
* Equal item rarity.
* Equal opportunity.
* Equal intelligence.
* Equal behavior.
* Equal progression.
* That every enemy uses every available system.

Example:

An enemy being capable of equipping a God-Touched weapon does not imply that ordinary enemies commonly possess God-Touched weapons.

---

# 8. Combat — REQUIRED

Combat is **real-time**.

Older turn-based Micro Rogue designs are not authoritative for the current scope.

Exact combat mechanics, damage formulas, healing formulas, resource systems, and balance are downstream design concerns.

---

# 9. World Address Structure — REQUIRED

The world uses a hierarchical/pointer-based location model.

Conceptually:

```text
Global Map
    ↓
Global Coordinate / Local Map
    ↓
POI
    ↓
POI Floor
    ↓
Possible exceptional/portal-based destinations
```

A Local Map has a Global Map coordinate that acts as its world address.

POIs exist within Local Maps.

POIs may contain multiple floors.

Exceptional topology, including portal-based destinations, is permitted by the intended architecture but is not currently mechanically defined.

---

# 10. New World Generation — REQUIRED

Creating a new world generates the **entire Global Map**.

This does **not** require every Local Map to be fully instantiated immediately.

At world creation, the game must generate:

* Origin/starting Local Map.
* Origin Town within that Local Map.
* Required starting-area POI content.
* All eight Local Maps surrounding the Origin Local Map.
* POIs for those generated neighboring Local Maps.

The initial detailed world therefore consists of a generated **3×3 Local Map region** centered on the starting Local Map.

After initial generation, detailed Local Maps expand lazily.

When exploration reaches a new Local Map/Global coordinate, required neighboring Local Maps that do not yet exist may be generated around that frontier.

The Global Map itself is already established.

---

# 11. POI Persistence — REQUIRED

Once a POI layout is generated, that layout is persistent.

Leaving and returning to a POI does not regenerate its original layout.

Persistent POIs may subsequently be changed by:

* Player actions.
* World events.
* Repopulation.
* Other future mutation systems.

The result of legitimate mutation becomes the new persistent state.

### Non-binding example

A sufficiently destructive interaction could eventually convert an existing tower into ruins.

The specific trigger, damage value, collapse behavior, player damage, and recovery mechanics are **not defined requirements**.

---

# 12. POI Categories — REQUIRED

At the scope level:

> **POI = Civilization + Dungeons**

Civilization represents settlement/civilized POIs.

"Dungeon" is a gameplay category and does not imply that every dungeon is an underground stone structure.

Current intended dungeon archetypes include:

* Caves.
* Ruins.
* Raider Camps.
* Towers.
* Overgrown Thickets.
* Bottoms of Wells.
* Monster Warrens.
* Nests.

Individual archetypes do not need identical topology or objectives.

---

# 13. Enemies and Families — REQUIRED

Enemies exist in **Families**.

Families are groupings/factions of related actors.

Enemy Families can be hostile toward one another.

The world does not treat all hostile actors as one unified faction.

Enemies are intended to be primarily intelligent/humanoid, which is a major reason for the shared actor-system invariant.

This does not prohibit other creature/enemy types.

Exact Family relationships, behaviors, spawning rules, and AI are downstream design.

---

# 14. Equipment — REQUIRED

Weapons and armor have multiple independent item-generation dimensions.

Current required conceptual dimensions include:

* Material Tier.
* Weapon/Equipment Shape Tier.
* Quality Tier.

Armor follows the same broad model.

Equipment quality affects access to affixes.

Affixes are not universally available to all quality levels.

The highest quality levels gain access to affixes, with God-Touched representing the extreme legendary-equivalent end of item generation.

Exact tier names and numerical distributions are not required by this scope document unless separately documented later.

---

# 15. God-Touched Equipment — REQUIRED

God-Touched is not merely a display label for very high quality.

It is also an **affix gate**.

God-Touched weapons/armor can access special affixes unavailable to ordinary equipment.

God-Touched status is required for weapons/armor to exceed the normal affix limit of two.

God-Touched equipment is intended to be exceptionally rare.

Named divine identities currently established include:

* Abyssious.
* Kalamitous.
* Sizzliarad.

Exact divine affix catalogs and effects are downstream item-system design.

---

# 16. Rings and Necklaces — REQUIRED

Rings and necklaces do **not** use the standard weapon/armor generation model.

Rings have:

* Lesser/Greater pair concepts.
* Greater-only concepts.
* God-Touched-only concepts/categories where applicable.

Rings do **not** receive God-Touched affixes.

This restriction is intentional.

Necklaces may receive a God-Touched result.

Necklaces have only one affix total.

When a necklace rolls God-Touched, the available affix pool changes to permit God-Touched affixes while excluding ordinary lower-tier options according to the high-end necklace rules.

Exact jewelry tables remain downstream design.

---

# 17. Equipment Durability — EXPLICITLY OUT OF SCOPE

Gear does **not break**.

Do not introduce weapon or armor degradation as a maintenance system.

---

# 18. Crafting — EXPLICITLY OUT OF SCOPE

There is **no crafting system**.

Do not introduce crafting as an assumed supporting system for equipment, economy, survival, or progression.

---

# 19. Identification — REQUIRED

Rogue-style identification is part of the game.

Certain item categories/interactions may have world-specific hidden identities.

Names/identities may differ between generated worlds.

Once an identity is discovered, that knowledge persists for the player across characters within that same world.

Creating a new world resets this identification knowledge.

The intended interaction space includes concepts such as:

* Throwing items.
* Drinking unidentified potions.
* Wearing rings.
* Curses.
* Strange fountains.
* Dipping items into uncertain substances.

Exact interaction catalogs are downstream design.

---

# 20. Magic — REQUIRED AT WORLD/SCOPE LEVEL

Magic exists.

Magic is not intended to be universally mundane.

The setting establishes that magic entered the world as a consequence of an ongoing conflict among the gods.

This conflict also supports the existence of:

* Magical world events.
* God-Touched equipment.
* Rare magical equipment.
* World mutation.

Magic is strongly associated with rings and high-end equipment.

Exact spell systems, mana systems, healing mechanics, and magical formulas are downstream design.

---

# 21. World Mutation — REQUIRED

The persistent world can change physically over time.

After sufficient world time has passed, events may include:

* Earthquakes.
* Volcanic events.
* Mystical events.
* Other consequences associated with the conflict among the gods.

World mutation may change existing persistent locations.

Exact event timing, probability, mutation algorithms, and effects are unresolved implementation/design concerns.

---

# 22. Prosperity — REQUIRED

Settlements have a deliberately limited Prosperity system.

Prosperity receives positive influence from concepts including:

* Settlement/town tier.
* Completed quests.

Nearby dangerous POIs/boss power suppress Prosperity.

Prosperity affects civilized economic quality.

Higher Prosperity can produce access to better gear through the economy.

Prosperity also participates in the creation of trade routes between settlements.

Exact radii, formulas, thresholds, and numerical values are downstream design.

---

# 23. Hostility — REQUIRED

Hostility is **not intended as a direct punishment meter for the player**.

Its primary responsibilities are:

1. Suppressing Prosperity.
2. Increasing potential loot/equipment power circulating among hostile NPCs/enemies.

High Hostility therefore represents increased danger with increased potential reward.

Exact loot modification, equipment-generation behavior, and numerical formulas are downstream design.

---

# 24. Quests — REQUIRED

Quests are generated from relationships between:

* Town influence.
* Relevant POIs.
* Boss-bearing POIs.

Exceptional threats may produce rare/high-value "heroic" quests.

Exact quest templates, generation algorithms, rewards, and terminology are downstream design.

---

# 25. Shops and Economy — REQUIRED

Items can be sold to shops.

Items can be purchased from shops.

Shops refresh/reset on a seven-world-day cycle.

Prosperity affects economic/item quality.

Whether individual merchants must exist as fully simulated persistent Actors versus service interfaces is **UNRESOLVED**.

---

# 26. Time — REQUIRED

World time is a gameplay system.

Baseline real-time progression:

> **10 real minutes = 1 world hour.**

Rest consumes:

> **6 world hours.**

At the current scope level:

> **Inn rest and camp rest consume the same amount of world time.**

Their detailed resource/healing behavior is downstream design.

---

# 27. Normal Travel — REQUIRED

Moving from one Local Map to an adjacent Local Map constitutes a **border crossing**.

A normal border crossing consumes:

> **3 world hours.**

Local Maps correspond to Global Map coordinates; therefore crossing between adjacent Local Maps is also movement between adjacent Global coordinates.

Exact movement/pathfinding implementation inside Local Maps is downstream design.

---

# 28. Trade Routes and Fast Travel — REQUIRED

Trade routes are created through the Prosperity system when qualifying settlement prosperity/influence relationships reach the required conditions.

Exact thresholds are downstream design.

Fast travel is available **only along established trade routes**.

Fast travel does **not** teleport the player.

The character still traverses the physical route through the world.

Fast travel removes the normal border-crossing time cost associated with that traversal.

Trade routes therefore improve world connectivity rather than bypassing world geography.

---

# 29. Discovery and Trade-Route Knowledge — REQUIRED

A world may contain towns and trade routes that the player does not yet know about.

World existence does not automatically grant player knowledge.

A town is not considered known merely because world generation created it.

A trade route is not considered known merely because the world simulation created it.

The player must have **seen/discovered** them for them to become part of persistent player knowledge.

---

# 30. New Character Starting Location — REQUIRED

The first character begins from Origin Town.

After character death, later characters are not necessarily restricted to Origin Town.

A later character may begin in:

* Origin Town, or
* A previously seen town that is connected to Origin Town through a trade-route path the player has previously discovered.

A town that exists but has not been discovered is not eligible.

A trade route that exists but has not been discovered cannot establish starting-location eligibility.

This allows persistent player knowledge and world development to expand future starting options without directly increasing character power.

---

# 31. Death — REQUIRED

Death is death.

When a player character dies:

1. The character dies in the world.
2. Their body and possessions initially become part of the world state.
3. The world advances **seven days** before the next character enters.
4. Time-dependent systems advance accordingly, including shop refresh behavior.
5. Some corpse contents may be removed during this interval.
6. World actors may interact with or acquire remaining possessions.
7. The corpse itself may be silently removed.
8. A new character is rolled into the same persistent world.

The game must **not** guarantee preservation of the dead character's equipment for retrieval.

---

# 32. Corpse Runs — EXPLICITLY NOT A REQUIRED LOOP

The game is not designed around a conventional corpse-run mechanic.

A later character may potentially encounter consequences or remaining possessions from a previous character because the world is persistent.

This is emergent persistence, not a promise that lost equipment will wait for retrieval.

---

# 33. POI Repopulation — REQUIRED

Cleared POIs can repopulate over time.

Current intended rule:

On the weekly cycle, an eligible cleared POI has a chance to repopulate using an appropriate local Family.

The currently discussed chance is **10%**, but this numerical value should be treated as a balance value rather than a permanent scope invariant unless separately locked.

Boss-state eligibility must be respected.

Exact implementation remains downstream design.

---

# 34. Saving — REQUIRED

The game does not intentionally support save-scumming as part of its gameplay contract.

World changes and character death are intended to become authoritative saved state.

Exact serialization frequency and technical save implementation are not scope requirements.

---

# 35. Conventional Meta Progression — EXPLICITLY OUT OF SCOPE

Do not implement conventional roguelite meta progression in which repeated deaths permanently increase the baseline power of future characters.

Persistent world changes and persistent player knowledge are intentional and do not violate this rule.

Examples of permitted persistence:

* The world is more prosperous because previous characters completed quests.
* A boss remains dead.
* Hostility has changed.
* Trade routes have formed.
* Item identities remain known.
* Previously discovered towns/routes remain known.

These are consequences and knowledge, not account-level character power upgrades.

---

# 36. End Condition — CURRENTLY NONE REQUIRED

No formal victory/end condition is currently required.

The persistent world may continue for as long as the player wishes to play it.

The player may eventually choose to abandon/regenerate the world.

Do not invent a final boss, campaign victory, world-completion condition, or credits trigger merely to provide a conventional ending.

---

# 37. NPC Adventurers — POSSIBLE FUTURE

Autonomous NPC adventurers are **not currently required scope**.

The concept remains permitted for future consideration.

Do not build architecture around the assumption that a full autonomous adventurer simulation must exist.

Do not remove architectural flexibility solely to prohibit the concept either.

---

# 38. Limited Cross-Character Storage — POSSIBLE FUTURE

A future bank/storage system might permit a small number of items to intentionally survive between player characters.

This is **not currently required**.

Do not implement or assume this system until deliberately designed.

---

# 39. Off-Screen Simulation Depth — UNRESOLVED

The required depth of autonomous world simulation is not currently defined.

Do not infer that persistent actors require a full off-screen life simulation.

Do not infer that persistence requires:

* Autonomous global NPC travel.
* Autonomous quest completion.
* Full simulated economies.
* Persistent individual lives for every NPC.
* Autonomous dungeon clearing.
* Autonomous character progression.

Some world systems necessarily advance with time, including explicitly defined systems such as shop refresh, POI repopulation, and world mutation.

Anything beyond explicitly defined behavior remains unresolved.

---

# 40. Current Scope Boundary

Micro Rogue is intended to contain:

* Persistent generated world.
* Mortal rolled characters.
* Real-time combat.
* Character stats and leveling.
* Profession/skill progression.
* Procedural dungeon exploration.
* Persistent POIs.
* Intelligent enemies using shared gameplay systems.
* Equipment and rare affixes.
* Identification.
* Curses and uncertain world interactions.
* Towns.
* Shops.
* Quests.
* Prosperity.
* Hostility.
* Enemy Families/factions.
* Trade routes.
* World time.
* Fast travel through physical trade routes.
* World mutation.
* Knowledge persistence across characters.
* Consequences that survive character death.

It is **not** currently defined as:

* A crafting game.
* A durability/gear-maintenance game.
* A conventional meta-progression roguelite.
* A full autonomous-world simulator.
* A 3D action game.
* A game requiring NPC adventurers.
* A game requiring a formal victory condition.

---

# 41. Required Documentation Behavior

When converting this packet into `Scope_Defined.md`:

**Do not design.**

If repository state conflicts with this packet, report the conflict.

If historical documentation conflicts with this packet, this packet takes precedence for the new scope document.

If two statements inside this packet appear to conflict, stop and report the conflict rather than resolving it independently.

If implementation details are absent, leave them absent.

If a concept is marked unresolved, preserve it as unresolved.

If a concept is marked possible future, do not represent it as committed scope.

If an example is provided, do not promote the example into a mechanical requirement.

The purpose of `Scope_Defined.md` is to establish a stable boundary for subsequent MVP definition and implementation work.

**Do not create the MVP from this packet unless separately instructed.**
