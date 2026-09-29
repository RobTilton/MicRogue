# MICROGUE Art Direction — 4-Bit Dungeon Style

## Purpose

This document is the art anchor for MICROGUE.

Use it when beginning or continuing an art pass so every asset is built toward the same visual language.

The goal is **tiny, readable, dark-fantasy pixel art with a restricted 4-bit palette**, dense environmental detail, and simple symbolic actors.

---

# 1. Core Visual Direction

- **4-bit visual language**
  - Maximum working palette: **16 colors**
  - Hard pixel edges
  - No antialiasing
  - No soft gradients
  - No sub-pixel smoothing
  - No painterly rendering
- **Dark fantasy / dungeon tone**
  - Grim
  - Worn
  - Ancient
  - Dangerous
  - Functional rather than cute
- **Not chibi**
- **Not mascot-like**
- **Not soft or rounded by default**
- Avoid exaggerated “cute” proportions unless a creature genuinely calls for them.

The visual target is:

> **Tiny symbolic characters inside a richly detailed, high-contrast dungeon world.**

---

# 2. Palette Direction

The palette should remain **restricted and muted**, but it is **not grayscale-only**.

Color is allowed and should help gameplay readability.

## Suggested 16-Color Working Palette

| ID | Role | Hex |
|---|---|---|
| 00 | Near-black / deepest void | `#0B1012` |
| 01 | Charcoal | `#343A3A` |
| 02 | Stone gray | `#666B68` |
| 03 | Bone / parchment highlight | `#E3D5B8` |
| 04 | Deep brown | `#292623` |
| 05 | Leather brown | `#4B3A30` |
| 06 | Dust / ochre brown | `#6A573A` |
| 07 | Dead moss green | `#344536` |
| 08 | Moss / poison green | `#66783A` |
| 09 | Torch amber | `#E99B2F` |
| 0A | Rust / copper | `#A85A28` |
| 0B | Deep forest green | `#315C3C` |
| 0C | Cold teal | `#24505B` |
| 0D | Desaturated blue | `#2F425F` |
| 0E | Muted violet | `#4D3D62` |
| 0F | Blood / danger red | `#C33D36` |

These values are the **starting contract**, not sacred forever.  
If adjusted later, update the palette globally rather than drifting asset-by-asset.

---

# 3. Color Usage Rules

Use hue deliberately.

### Environment
Mostly:
- near-black
- charcoal
- gray
- brown
- bone

### Nature / poison / goblins
Mostly:
- dead green
- moss green
- forest green

### Fire / light / valuable highlights
Mostly:
- amber
- rust / copper

### Water / cold / arcane
Mostly:
- teal
- desaturated blue
- muted violet

### Blood / danger / demonic elements
Mostly:
- red

## Important

The world should **not become rainbow-noisy**.

Most tiles should use only a small subset of the full 16-color palette.

---

# 4. Actor Scale

## Standard Character Frame

- **Frame:** `8×8`
- **Typical humanoid sprite footprint:** approximately `6×8`
- The remaining horizontal space acts as breathing room and limited weapon/shield spill.

Actors are intentionally tiny.

At this scale, characters are **symbols first**, illustrations second.

---

# 5. Character Design Rules

Humanoids should communicate primarily through:

- silhouette
- posture
- weapon shape
- shield shape
- helmet / hood shape
- robe / cloak shape
- one or two strong color accents

Do **not** attempt to render detailed anatomy or armor plates that cannot survive the resolution.

A player should still read clearly as:

- unarmed
- sword user
- shield user
- sword + shield
- spear user
- bow user
- robed
- hooded

Visible gear is optional and should focus on **major silhouette changes**, not exhaustive paper-doll fidelity.

---

# 6. Environment Detail

Unlike actors, the environment can carry much more visual density.

Preferred dungeon features:

- cracked stone
- chipped masonry
- irregular brick
- rubble
- shallow water
- moss
- roots / grass
- chains
- banners
- torches
- pillars
- doors
- stairs
- bones
- barrels
- chests
- altars
- small debris

Dense texture is encouraged **as long as gameplay silhouettes remain readable**.

Black negative space is part of the composition and should not be filled just because space exists.

---

# 7. Pixel Construction Rules

Every production asset should obey:

- Integer pixel placement only
- Hard-edged pixels
- No blur
- No antialiasing
- No transparency feathering
- No hidden high-resolution rendering pretending to be pixel art
- Nearest-neighbor scaling only
- Prefer clusters of pixels over isolated noise
- Preserve readable negative space

When possible, final assets should be manually cleaned or reconstructed at their literal production resolution.

---

# 8. Contrast Rules

Characters and interactable objects must separate from the floor.

Preferred hierarchy:

1. **Near-black** for deep outline / negative space
2. **Dark-mid tone** for body mass
3. **Light-mid tone** for readable form
4. **Bright highlight or accent** only where useful

Avoid outlining everything equally.

Important objects can receive stronger contrast than background decoration.

---

# 9. Asset Workflow

Build the game **piece by piece**, not as one giant generated sprite sheet.

Recommended workflow:

1. Generate or sketch **one semantic object**
2. Judge its silhouette and style
3. Rebuild / clean it at literal pixel resolution
4. Lock it as canonical
5. Derive variants from the canonical asset
6. Move to the next object

Examples:

### Floor
- plain stone
- cracked stone
- stained stone
- rubble

### Walls
- straight wall
- inner corner
- outer corner
- wall end
- damaged wall

### Infrastructure
- closed door
- open door
- stairs up
- stairs down
- pillar
- gate

### Decoration
- torch
- bones
- barrel
- chest
- altar
- chains

### Actors
- player
- goblin
- skeleton
- zombie
- imp
- slime
- boar
- orc
- ogre

---

# 10. Creature Rule

At tiny scale, **silhouette accuracy matters more than detail**.

A creature must immediately read as the intended creature.

Example:

A boar should emphasize:
- long snout
- low body
- arched / heavy back
- short legs
- optional single-pixel tusk highlight

Do not accept a sprite merely because the palette and rendering style look correct if the creature silhouette is wrong.

---

# 11. Style Rejection Checklist

Reject or revise an asset if it becomes:

- cute by accident
- chibi
- overly round
- soft-shaded
- anti-aliased
- painterly
- too detailed for its native resolution
- muddy against the floor
- visually noisy
- palette-drifting
- inconsistent with the rest of the set
- anatomically unreadable
- reliant on generated fake pixels

---

# 12. Art Walk Anchor

When beginning an art session, the instruction is:

> **Use the MICROGUE 4-bit dungeon style: restricted muted 16-color palette, literal hard-edged pixel art, tiny symbolic actors, dense high-contrast dungeon environments, dark fantasy tone, no cute/chibi treatment, and one canonical asset at a time.**

---

## Current Direction Status

**LOCKED FOR EXPLORATION**

- 4-bit-style restricted color palette: **YES**
- Muted color rather than pure grayscale: **YES**
- Dark dungeon tone: **YES**
- Dense environment detail: **YES**
- Tiny symbolic actors: **YES**
- Standard actor frame: **8×8**
- Typical humanoid footprint: **~6×8**
- Piece-by-piece asset workflow: **YES**
- Final production assets should be literal pixel art: **YES**

