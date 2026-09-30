# ArtworkRoom Fantasy Candidate Selection
Updated: 2026-09-30
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[FantasyCandidateClassification]`
Implementation baseline/evidence: Visual classification from the four validated Atlas Intake contact sheets derived from `colored-transparent_packed.png`, SHA-256 `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`.

Status: Supporting classification evidence only. Direct human selection superseded this document as catalog authority. The accepted membership contract is [FINAL_FANTASY_CATALOG.md](FINAL_FANTASY_CATALOG.md); `Pending` values below were never treated as acceptance.

## Rapid Shape

This is a deliberately broad fantasy-game candidate pass, not an exhaustive atlas catalog. Candidate clusters cover overworld nature, dungeon terrain and structures, containers and props, melee equipment, armor, shields, staffs, and hit or magical effects. Each range uses inclusive, zero-based atlas coordinates. Rob's selection is pending; no entry is accepted merely because it appears here.

Use the contact-sheet label `xx,yy` to inspect a cell. A cell's Godot row-major frame is `frame = y * 49 + x`.

## Review Sheets

- [x 00–24, y 00–10](../Tables/AtlasCatalogTable/Evidence/ContactSheets/atlas_x00-24_y00-10.png)
- [x 25–48, y 00–10](../Tables/AtlasCatalogTable/Evidence/ContactSheets/atlas_x25-48_y00-10.png)
- [x 00–24, y 11–21](../Tables/AtlasCatalogTable/Evidence/ContactSheets/atlas_x00-24_y11-21.png)
- [x 25–48, y 11–21](../Tables/AtlasCatalogTable/Evidence/ContactSheets/atlas_x25-48_y11-21.png)

## Candidate Clusters

All coordinate ranges are inclusive. `Strong` means the cluster visibly matches the category. `Mixed` means it is plausibly useful but contains variants whose exact semantics or desired subset need Rob's judgment.

| ID | Category | Coordinates | Confidence | Observed content | Decision |
|---|---|---|---|---|---|
| `NAT-01` | Overworld detail | `(1..7, 0)` | Mixed | Red and green organic-looking ground, growth, or impact decals. | Pending |
| `NAT-02` | Overworld vegetation | `(0..7, 1..2)` | Strong | Trees, shrubs, grasses, mushrooms, and other vegetation silhouettes. | Pending |
| `NAT-03` | Overworld vegetation | `(13..17, 6)` | Strong | Small green planted or vine-like terrain details. | Pending |
| `NAT-04` | Overworld creature/detail | `(18..20, 5)` | Mixed | Green blob, bush, or creature-like sprites. | Pending |
| `TRN-01` | Dungeon terrain and structure | `(8..22, 0..4)` | Strong | Walls, floors, arches, pillars, ladders, stonework, water boundaries, and structural details. | Pending |
| `TRN-02` | Dungeon terrain and structure | `(8..17, 5..6)` | Strong | Water, stone, vegetation, barriers, and structural variants. | Pending |
| `TRN-03` | Dungeon walls and floors | `(0..24, 11..18)` | Strong | Large coherent library of wall, floor, doorway, corner, grate, platform, and marked-state variants. | Pending |
| `TRN-04` | Fantasy buildings and structure | `(0..18, 19..21)` excluding `(2..7, 19..20)` | Mixed | Building fronts, roof or wall forms, furnishing-like structures, and construction variants; excluded cells are humanoid actors outside the requested categories. | Pending |
| `CON-01` | Containers and props | `(0..7, 3..10)` | Strong | Fences, gates, crates, doors, chests, shelving, and furniture-like props. | Pending |
| `CON-02` | Containers and props | `(8..17, 7..10)` | Strong | Chests, cabinets, seating, tables, beds, and related furnishing variants. | Pending |
| `CON-03` | Containers and props | `(18..23, 11..13)` | Strong | Doors, cabinets, tables, gates, beds, and container-like variants. | Pending |
| `CON-04` | Containers and props | `(46..48, 5..9)` | Mixed | Bags, packs, boxes, or cabinet-like inventory/world props. | Pending |
| `ARM-01` | Armor and armored figures | `(24..31, 0..10)` | Strong | Helmets, body armor, skeletal or armored bodies, and armor silhouettes. | Pending |
| `ARM-02` | Headgear and armor | `(32..36, 0..1)` | Mixed | Helmet, mask, headgear, and related equipment variants. | Pending |
| `ARM-03` | Armor and headgear | `(42..48, 0..5)` | Strong | Helmets, crowns, hats, body armor, packs, and related equipment. | Pending |
| `WPN-01` | Melee and non-gun weapons | `(32..36, 2..9)` | Strong | Swords, blades, arrows, polearm-like forms, and weapon silhouettes. | Pending |
| `WPN-02` | Weapons, shields, and gear | `(37..41, 0..9)` | Mixed | Crossed weapons, shields, armor pieces, and equipment variants. | Pending |
| `WPN-03` | Melee weapon marker | `(23, 2)` | Strong | Crossed-blade or crossed-weapon sprite. | Pending |
| `WPN-04` | Weapons and staffs | `(0..5, 15)` | Strong | Blades, axe or mace forms, a staff, and a trident or polearm. | Pending |
| `WPN-05` | Weapons, projectiles, and keys | `(25..34, 11)` | Mixed | Arrow or blade forms plus key-like sprites; exact roles need selection. | Pending |
| `WPN-06` | Non-gun weapons | `(33..34, 20)` | Strong | Green crossed or paired weapon form and a red blade-like sprite. | Pending |
| `WPN-07` | Melee weapon marker | `(34, 21)` | Strong | Crossed-weapons sprite. | Pending |
| `SHD-01` | Shields or magical guard effects | `(42..46, 7..9)` | Mixed | Ringed shield, ward, or equipment variants in multiple colors. | Pending |
| `SHD-02` | Shields or magical guard effects | `(43..47, 12)` | Mixed | Gold crescent, ring, or ward sequence. | Pending |
| `FX-01` | Hit effect | `(21..23, 5)` | Strong | Three red strike, slash, or impact frames. | Pending |
| `FX-02` | Hit or magical effects | `(18..23, 8..9)` | Strong | Yellow and green effect sequences with coherent frame progression. | Pending |
| `FX-03` | Hit effect | `(37..38, 10)` | Strong | Red slash or wound-like effect pair. | Pending |
| `FX-04` | Hit or magical effects | `(43..47, 11..13)` | Strong | Red rings, gold circular effects, and colored impact or ward frames. | Pending |
| `FX-05` | Water or magical effect | `(14..15, 18)` | Mixed | Blue droplet, splash, or magical-energy pair. | Pending |
| `OPT-01` | Optional fantasy consumables | `(32..34, 12..14)` | Strong | Scroll, flask, bottle, and potion-like sprites. Outside the explicit list but genre-aligned. | Pending |
| `OPT-02` | Optional fantasy books or containers | `(32..34, 15..16)` | Mixed | Book, panel, chest, or container-like variants. | Pending |

## Deliberately Excluded Dead Weight

- `(39..47, 10)`: heart and medical-style HUD symbols.
- `(35..48, 14..20)`: predominantly faces, buttons, dice, numerals, alphabet glyphs, UI controls, and status symbols.
- `(35..48, 21)`: predominantly warning, UI, chess-piece, and interface symbols.
- `(2..7, 19..20)`: humanoid actor sprites not requested by the current catalog scope.
- Cells outside the candidate clusters: unselected by default. Their omission is not a claim that they are unusable.

The small approved overrides `WPN-06` and `WPN-07` remain candidates even though they are adjacent to excluded UI-heavy territory.

## Human Selection Contract

Rob may accept or reject whole IDs, or trim an ID by giving coordinate ranges or individual coordinates. Ambiguous clusters should not be silently promoted. After decisions are supplied, the catalog will be rewritten into stable, game-facing entries; only that reconciled catalog can feed the Godot consumer-resource Box.

## Validation And Current Limits

- All four review sheets were inspected at original detail, covering every coordinate from `(0, 0)` through `(48, 21)`.
- Every proposed cluster is bounded to the validated atlas grid and points to a specific review sheet.
- Classification is visual and semantic; exact sprite purpose remains inferred until Rob accepts it.
- No source pixel, scene, import setting, runtime resource, or Production file was changed by classification.
