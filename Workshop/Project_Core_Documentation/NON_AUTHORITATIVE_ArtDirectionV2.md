# Non-Authoritative Retained Source: ArtDirectionV2
Updated: 2026-10-03

Status: NON-AUTHORITATIVE. Rob designated this material non-authoritative on 2026-10-03. Retained for reference only; inherited authority statements below do not establish current project requirements or execution authority.

---

````md
# MICROGUE — 8×8 COMPOSITIONAL ART SYSTEM
**Status:** R&D Direction / Prototype Contract  
**Date:** 2026-09-28  
**Scope:** Actor sprites, equipment composition, animation grammar, combat effects, impact particles  
**Target:** Godot 4.x / Aseprite  
**Design Mode:** MCA — modular, compositional, explicit ownership, minimal cross-system knowledge

---

# 1. SYSTEM SUMMARY

MICROGUE uses extremely constrained **8×8 actor sprites** combined from ordered transparent equipment layers.

Actors remain visually minimal.

Equipment identity is constructed from:

- fixed pixel addresses
- silhouette mutations
- material palettes
- semantic detail pixels
- equipment properties
- optional UID-derived cosmetic variation

Actions deliberately contrast with the minimal actors.

Physical attacks and magic use exaggerated motion lines, impact frames, particles, sound, hitstop, and larger effect canvases to communicate force.

Core visual rule:

> **Actors communicate state. Actions communicate force.**

Secondary construction rule:

> **Carve to recognition. Spend remaining pixels on identity.**

---

# 2. AUTHORITATIVE ACTOR SPACE

Actor canvas:

`8×8 pixels`

The base humanoid does NOT need to occupy the entire canvas.

Current expected maximum body footprint:

`~6×8`

Unused horizontal space is intentional and reserved for:

- weapons
- shields
- armor silhouette expansion
- back equipment
- helmets
- exceptional equipment

The base actor should remain visually neutral.

Required responsibilities:

- recognizable humanoid
- facing
- skin region
- hair region
- equipment anchors
- readable unequipped state

Facial features are NOT required.

At this resolution, equipment is permitted to replace most or all facial information.

---

# 3. EQUIPMENT-FIRST PAPER DOLL DESIGN

Do NOT finalize the naked/base actor first.

Define basic equipment geometry first.

Equipment determines required actor anchors.

Required initial equipment set:

- helmet
- armor
- boots
- weapon
- shield
- backpiece

Equipment establishes:

- head region
- torso region
- hand coordinates
- foot coordinates
- usable exterior space
- required negative space
- expected occlusion

After these constraints are established, construct the minimum humanoid necessary to connect and support them.

Conceptually:

`GEAR → ANCHOR REQUIREMENTS → PAPER DOLL`

Not:

`PAPER DOLL → FORCE GEAR TO FIT`

---

# 4. COMPOSITION ORDER

All actor/equipment assets use the same 8×8 coordinate space.

Transparent pixels have no ownership.

A non-transparent pixel replaces the current pixel at that coordinate.

Later layers are authoritative.

Current composition order:

1. Backpiece
2. Base Actor
3. Boots
4. Armor
5. Helmet
6. Weapon
7. Shield

Conceptually:

`FinalPixel[x,y] = last non-transparent pixel at [x,y]`

This ordering provides intentional occlusion.

Examples:

- armor replaces torso pixels
- helmet replaces head/face pixels
- weapon may render over armor
- shield renders over weapon/body where appropriate
- rear weapon components may exist in Backpiece while foreground components exist in Weapon

---

# 5. SEMANTIC PIXEL OWNERSHIP

Pixels are not treated only as visual marks.

Specific coordinates may have semantic responsibilities.

Examples:

- HAND
- HEAD
- FOOT
- BLADE
- GUARD
- POMMEL
- SHIELD_BAND
- GEM_SOCKET

Equipment classes should establish stable pixel vocabularies.

Example sword structure:

```text
_#_   blade
_#_   blade
_#_   blade
#-#   guard / HAND / guard
_*_   pommel or gem
````

Where:

* `#` = equipment
* `-` = actor hand anchor
* `*` = pommel/detail/gem

The hand belongs to the actor.

The weapon composes around the hand.

---

# 6. EQUIPMENT MORPHOLOGY

Equipment variants should preferentially be produced by legal mutations of a recognizable base form.

## Sword

Base properties:

* blade length
* blade profile
* blade material
* guard geometry
* guard material
* pommel geometry
* pommel material
* gem/detail

Example transformations:

`Sword → base blade`

`Longsword → blade +1 pixel length`

`Greatsword → blade +2 pixels length`

`Curved/Falchion → lateral blade pixel displacement / added asymmetric mass`

Do NOT require a unique complete sprite for every normal combination.

---

# 7. MATERIAL AS PALETTE

Material identity should preferentially modify palette rather than geometry.

Example material progression:

* bronze
* iron
* steel
* silver
* gold
* ebony
* azure / magical material

Geometry communicates equipment type.

Palette communicates material.

Example:

Same boot geometry + bronze palette
= Bronze Boots

Same geometry + steel palette
= Steel Boots

Same geometry + gold palette
= Gold Boots

---

# 8. MULTI-MATERIAL ITEMS

Individual semantic regions may use independent material palettes.

Example sword:

* steel blade
* gold guard
* steel pommel
* ruby socket

Example leather armor:

* leather body remains brown
* buckle/rivet pixel uses metal material palette

This allows item composition without multiplying complete sprite assets.

---

# 9. DETAIL PIXELS

Single pixels may encode substantial item information.

Possible semantic detail pixels:

* gem
* rivet
* buckle
* reinforcement
* magical accent
* damage
* trim
* enchantment marker

At 8×8, one pixel is intentionally high-information.

Example shield:

```text
###
#_#
_#_
```

Base shield.

Example tower shield:

```text
###
#_#
#_#
###
```

Additional horizontal pixels may create a banded construction.

A single differently colored center pixel may indicate a gem or boss-quality embellishment.

---

# 10. UID VISUAL VARIATION

Normal equipment may optionally derive cosmetic variation from item UID.

Possible UID-derived properties:

* guard variant
* pommel variant
* permitted detail pixel
* trim position
* minor silhouette mutation

UID variation must remain inside legal equipment-class constraints.

UID variation must NOT destroy immediate equipment recognition.

Concept:

`Item UID → deterministic visual variant selection`

This is cosmetic identity, not arbitrary per-pixel noise.

---

# 11. UNIQUE / ARTIFACT EQUIPMENT

Normal systemic equipment follows compositional grammar.

Exceptional equipment may use authored overrides.

Rule:

> **Systemic equipment obeys grammar. Unique equipment may intentionally violate grammar.**

Unique equipment should still participate in the normal compositor where possible.

A unique item may contribute pixels to multiple composition stages.

Example oversized legendary sword:

### Backpiece pass

Renders rear/over-shoulder blade section.

### Helmet pass

Helmet naturally occludes the rear blade where appropriate.

### Weapon pass

Renders foreground blade/handle section.

May override normal hand placement.

This allows an oversized weapon to pass behind and in front of the actor without requiring a completely unique character sprite.

Special-case capabilities may include:

* multi-layer rendering
* alternate hand anchor
* expanded silhouette
* forbidden normal coordinates
* authored geometry

---

# 12. BASE ANIMATION

Idle animation should remain extremely small.

Target:

`2 frames`

Possible idle motion:

* one-pixel vertical compression
* one-pixel vertical displacement
* selective line removal/addition

The actor should remain immediately readable.

Animation complexity belongs primarily to actions, not idle anatomy.

---

# 13. PHYSICAL ATTACK GRAMMAR

Physical attacks animate the actor primarily through whole-sprite displacement and weapon/effect motion.

Base attack sequence:

1. Idle stops
2. Weapon lowers / anticipation pose
3. Actor shifts ~1 pixel backward
4. Actor commits ~2 pixels forward
5. Attack effect becomes highly visible
6. Impact occurs
7. Actor returns to anchor
8. Idle resumes

Core rule:

> **Animate the action, not the anatomy.**

Detailed limb articulation is unnecessary if anticipation, direction, force, impact, and recovery are readable.

---

# 14. ATTACK TIMING

Turn-based combat permits readable animation without harming real-time control responsiveness.

Current maximum conceptual action budget:

`~30 frames`

This is a ceiling, not a required duration.

Different weapon classes may use different timing.

Examples:

* dagger: very short / repeated
* sword: medium
* spear: directional commitment
* hammer: slower anticipation + stronger impact hold
* exceptional attack: may use full effect budget

Timing itself communicates weapon weight.

---

# 15. WEAPON MOTION SIGNATURES

Weapon classes should have distinct motion grammar.

## Dagger

Sequence:

`back → forward → back → forward → idle`

Two rapid attack beats.

Visual:

* narrow silver streaks
* small scattered hit particles
* rapid repeated impact

Audio:

`shink-shink`

## Sword

Visual:

* broad directional slash
* readable arc
* moderate impact burst

## Spear

Visual:

* strong linear projection
* exaggerated silver/white directional streaks
* long perceived reach

The spear sprite remains small.

The visual representation of thrust may extend far beyond the literal weapon geometry.

## Hammer / Blunt

Visual:

* strong anticipation
* concentrated impact
* limited cutting streaks
* larger hitstop
* radial/star impact particles

Audio:

* thump / whump

---

# 16. HITSTOP

Heavy physical impacts may temporarily freeze animation.

Example:

1. attack commits
2. impact sound
3. ~4 frame freeze
4. impact particles explode
5. target displacement occurs
6. secondary collision effect if applicable

Hitstop communicates force before the resulting board state changes.

---

# 17. KNOCKBACK / COLLISION FEEDBACK

Combat effects should visually communicate mechanical consequences.

Example causal chain:

`ATTACK → FORCE → DISPLACEMENT → WALL COLLISION → BONUS DAMAGE`

If an attack moves an actor several cells, the preceding animation must visually support that force.

Wall collisions may produce:

* secondary impact sound
* secondary particle burst
* short freeze
* debris pixels

The player should visually understand why displacement/collision damage occurred without requiring combat-log explanation.

---

# 18. EFFECT SCALE

Actor scale:

`8×8`

Effects are NOT required to remain inside 8×8.

Current conceptual effect space:

`up to ~32×32`

A 32×32 effect may preserve the coarse MICROGUE language by treating 4×4 blocks as equivalent visual units while using individual subpixels for:

* sparks
* streaks
* fragments
* highlights
* motion breakup
* embers

This creates intentional juxtaposition:

`tiny actor → enormous action`

---

# 19. MAGIC

Magic may be substantially more visually aggressive than ordinary physical actions.

Example fireball:

1. small initial fire representation
2. expanding/swiveling orange-red-yellow projectile
3. trailing ember pixels
4. oversized impact burst
5. rapid disappearance
6. optional short-lived floor embers

Magic effects may temporarily dominate the screen.

The environment and actors return immediately to their restrained visual language afterward.

---

# 20. PROCEDURAL IMPACT PARTICLES

Do NOT hand-author every impact particle arrangement.

Impact effects should be parameterized and reusable.

Input concept:

```text
ImpactContext
- impact_position
- incoming_direction
- force
- attacker
- weapon_type
- skill
- damage_type
- magical_effect
- material
```

Output parameters may include:

* particle count
* palette
* spread
* velocity
* angular/tangential motion
* lifetime
* size
* direction bias
* secondary effects

Target visual:

* 1–2 pixel fragments
* white/silver for generic weapon impact
* 4–7+ random directions depending on force
* outward motion
* optional paired/connected pixel appearance
* visible spinning/corkscrew behavior

Godot's particle system may own low-level particle simulation.

MICROGUE owns semantic interpretation.

Conceptual boundary:

`Combat Meaning → Effect Recipe → Godot Particle System`

Godot 4 provides `GPUParticles2D` / `ParticleProcessMaterial`, including point emission, direction/spread, velocity, angular/tangential motion, lifetime variation, color, and related particle behavior.

Custom particle shaders remain available if built-in particle behavior becomes insufficient.

---

# 21. CLOTH / CONNECTED FLEXIBLE MOTION

Flexible materials can use tiny authored frame sequences rather than physical simulation.

Example cape:

`4 frames`

Approximate motion:

* upper moving section: ~2 pixel total lateral range
* lower section: ~4 pixel total lateral range

Greater displacement farther from the anchor sells flexible connected material.

Possible reuse:

* capes
* robes
* long hair
* tassels

---

# 22. BANNERS

Banner motion uses the same connected-material principle with different orientation.

Possible motion:

* anchored vertical edge remains stable
* body oscillates horizontally
* center retains stronger vertical structure
* outer edge receives greater displacement
* one-pixel tear may disappear/reappear between frames

Temporary disappearance of a torn edge pixel may exaggerate wind-whipped motion.

---

# 23. VISUAL INFORMATION CHANNELS

Different visual properties communicate different item/action information.

| Channel           | Primary Meaning                |
| ----------------- | ------------------------------ |
| Silhouette        | Equipment type                 |
| Palette           | Material                       |
| Detail pixel      | Gem / trim / modifier          |
| Pixel mutation    | Construction / subtype         |
| Motion signature  | Weapon behavior                |
| Timing            | Weight / speed                 |
| Effect magnitude  | Force                          |
| Sound             | Material + impact confirmation |
| Hitstop           | Impact severity                |
| Particle behavior | Force / damage character       |

Do not overload one channel when another already communicates the property.

---

# 24. ART PRODUCTION MODEL

MICROGUE art should preferentially be produced from reusable visual primitives rather than large catalogs of finished combinations.

Primary asset categories:

### Authored

* base actor
* equipment geometry modules
* equipment mutation variants
* idle frames
* attack anticipation/commitment poses
* core attack streaks/arcs
* unique artifact overrides
* spell primitives

### Parameterized / Composed

* materials
* equipment combinations
* multi-material items
* UID cosmetic variation
* normal paper-doll rendering

### Procedural

* impact particles
* spark distribution
* debris
* some magical secondary effects
* randomized effect variation

---

# 25. ASEPRITE PROTOTYPE ORDER

Do NOT begin by polishing a complete player sprite.

Prototype gear first.

Recommended first pass:

1. Sword
2. Shield
3. Tower Shield
4. Helmet
5. Boots
6. Armor
7. Backpiece / Quiver

Place all assets in the same 8×8 coordinate system.

Observe resulting anchor requirements.

Then construct the base paper doll.

Prototype success condition:

> Equipment reads correctly, composes correctly, and exposes enough information to derive the actor underneath.

---

# 26. LOSSLESS ASSET PIPELINE

Authoritative art remains native-resolution pixel data.

Preferred flow:

`8×8 native asset → Aseprite master → lossless PNG export → Godot`

Rules:

* PNG for lossless transfer/export
* preserve native 8×8 assets
* previews are NOT authoritative assets
* scale only with nearest-neighbor
* prefer integer scale factors
* disable texture filtering where required for crisp pixel rendering

Large previews may exist for inspection but must never replace the native pixel source.

---

# 27. CURRENT STYLE CONTRACT

MICROGUE should maintain deliberate contrast.

### World

Restrained.

### Actors

Symbolic.

### Equipment

Compositional.

### Idle

Microscopic.

### Movement

Minimal.

### Physical attacks

Exaggerated.

### Impact

High contrast.

### Magic

Intentionally excessive.

### Aftermath

Rapid return to visual quiet.

Core aesthetic:

> **Tiny representation. Disproportionate consequences.**

---

# 28. PROTOTYPE BOUNDARY

This document defines the current R&D direction.

Do NOT build the full rendering framework before visual validation.

Immediate next action:

`Aseprite → 8×8 canvas → basic equipment prototypes`

Validate:

* recognition
* anchor placement
* layer interaction
* palette readability
* one-pixel semantic details
* silhouette mutation
* actor negative space

Rules that survive actual pixel testing become authoritative.

Rules that fail visual testing are replaced.

---

# 29. MCA BOUNDARIES

Actor renderer should not know combat mechanics.

Equipment compositor should not know item-generation logic.

Particle renderer should not interpret combat rules.

Combat/effect translation layer provides semantic parameters.

Expected conceptual pipeline:

`Item Data`
→ `Visual Equipment Description`
→ `Equipment Composer`
→ `Actor Layers`
→ `Final 8×8 Actor`

Combat:

`Combat Result`
→ `Effect Description`
→ `Animation / Particle / Audio Systems`
→ `Rendered Feedback`

Each subsystem receives the minimum information required to perform its responsibility.

---

# 30. SESSION RESULT

Art direction is no longer based on manually authoring every complete sprite/item combination.

Current direction is a constrained visual grammar built from:

* fixed 8×8 address space
* equipment-first anchors
* ordered pixel ownership
* compositional equipment
* palette-driven materials
* semantic detail pixels
* deterministic optional variation
* authored exceptional overrides
* minimal actor animation
* exaggerated action animation
* procedural impact effects
* sound + hitstop + displacement feedback

Immediate implementation target:

> **Build basic gear. Let gear define the actor. Validate the grammar in Aseprite before building the system.**

```

One factual implementation note from our R&D survived verification: Godot's `GPUParticles2D` + `ParticleProcessMaterial` supports the parameterized particle behavior we're talking about, including point emission, spread, velocity, lifetime variation, color, and tangential motion for the little spinning/corkscrewing impact fragments.

---
