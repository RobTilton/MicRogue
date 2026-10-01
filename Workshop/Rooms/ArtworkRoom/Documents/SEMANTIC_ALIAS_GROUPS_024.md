# ArtworkRoom Semantic Alias Groups — Snapshot 024
Updated: 2026-10-01
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[SemanticNamingFullPass]`
Implementation baseline/evidence: Robert completed the first comprehensive once-over in `semantic_aliases_024.json`. Godot validation passed all 499 catalog-ordered records, unique aliases, Boolean removal requests, append-only history, and clean tool reload.

## Authority Boundary

The human-edited alias is the strongest grouping signal in snapshot `024`. Robert changed 172 aliases from the generated snapshot `005` but intentionally changed relatively little category/family metadata. Therefore, existing `category`, `family`, draft tags, and generated notes remain useful context but must not override the more specific alias during later normalization.

No requested sprite is removed here. Snapshot `024` still contains all 499 accepted addresses.

## Alias-Derived Top-Level Groups

The 486 records not currently marked for removal group by first alias token as follows:

| Alias head | Count |
|---|---:|
| `dungeon` | 129 |
| `deco` | 105 |
| `weapon` | 51 |
| `actor` | 50 |
| `overworld` | 38 |
| `equipment` | 36 |
| `floor` | 17 |
| `armor` | 14 |
| `hit` | 13 |
| `forest` | 12 |
| `shield` | 8 |
| `item` | 6 |
| `ladder` | 2 |
| `consumable` | 2 |
| `ground` | 1 |
| `projectile` | 1 |
| `unknown` | 1 |

These counts are descriptive evidence, not a finalized runtime taxonomy.

## Stronger Alias Families

Repeated human-facing families now visible in the aliases include:

| Alias prefix | Count |
|---|---:|
| `dungeon_tile` | 118 |
| `deco_structure` | 58 |
| `overworld_structure` | 31 |
| `deco_furniture` | 24 |
| `weapon_blade` | 20 |
| `hit_effect` | 13 |
| `floor_outer` | 12 |
| `forest_vegetation` | 12 |
| `armor_headgear` | 10 |
| `dungeon_deco` | 9 |
| `equipment_necklace` | 8 |
| `weapon_battleaxe` | 7 |
| `overworld_detail` | 7 |
| `deco_container` | 7 |
| `equipment_piece` | 6 |
| `weapon_staff` | 6 |
| `equipment_bow` | 6 |
| `item_consumable` | 6 |
| `floor_inner` | 5 |
| `weapon_wand` | 5 |
| `equipment_boots` | 4 |
| `equipment_gloves` | 4 |
| `equipment_ring` | 4 |
| `equipment_crossbow` | 2 |
| `weapon_spear` | 2 |
| `weapon_hammer` | 2 |
| `consumable_food` | 2 |

Actor names retain the approved `actor_NNN_name` structure and should be grouped through their `actor` head rather than treating every numbered prefix as a distinct family.

## Removal Requests

Thirteen records carry `remove_requested: true`:

```text
atlas_x08_y00  overworld_remove_000
atlas_x09_y00  overworld_remove_001
atlas_x10_y00  overworld_remove_002
atlas_x11_y00  overworld_remove_003
atlas_x12_y00  overworld_remove_004
atlas_x08_y02  dungeon_tile_014
atlas_x09_y02  dungeon_tile_015
atlas_x10_y02  dungeon_tile_016
atlas_x11_y02  dungeon_tile_017
atlas_x12_y02  dungeon_tile_018
atlas_x31_y06  actor_040_unnamed
atlas_x12_y12  dungeon_tile_067
atlas_x04_y14  dungeon_tile_083
```

Removal remains a requested future reconciliation. The catalog, static lookup, selection history, and atlas are unchanged.

## Validated State

- Snapshot: `semantic_aliases_024.json`
- SHA-256: `cc3d0dd62f49ff0524c3b55b305957e01336c13aec07f11c841ddc7aa5ec2c95`
- Sequence / aliases / records: `24 / 499 / 499`
- Alias changes relative to generated snapshot `005`: `172`
- Removal requests: `13`
- Duplicate aliases: `0`
- Empty aliases: `0`
- Missing or added addresses relative to the accepted catalog: `0 / 0`
- All `remove_requested` values are explicit Booleans.
- Snapshots `001` through `024` are present without a sequence gap.
- `SemanticNamingTool.tscn` reloads snapshot `024` without errors.

The next logical checkpoint is separately authorized removal reconciliation plus alias-derived metadata normalization. It must preserve snapshot `024` and produce a new catalog/semantic generation rather than rewriting history.
