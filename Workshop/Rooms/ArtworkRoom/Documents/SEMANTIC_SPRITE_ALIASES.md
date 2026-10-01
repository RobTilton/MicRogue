# ArtworkRoom Semantic Sprite Aliases
Updated: 2026-09-30
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[SemanticSpriteAliases]`
Implementation baseline/evidence: Snapshot `004` supplies 499 accepted cells; `semantic_aliases_003.json` preserves 19 confirmed names plus one note-only record. Automated validation and Rob's F6 visual/edit/save pass completed on 2026-09-30.

## Rapid Shape

Semantic aliases are optional, human-readable names layered over immutable `atlas_xXX_yYY` addresses. Unnamed catalog members remain valid. A semantic alias may be edited without moving or replacing the underlying atlas address. The F6 naming tool loads the newest valid semantic snapshot, exposes only the 499 accepted sprites, and saves a new numbered snapshot rather than rewriting prior evidence.

## Current Locations And Structure

- Naming surface: [`../Tables/AtlasCatalogTable/SemanticNamingTool.tscn`](../Tables/AtlasCatalogTable/SemanticNamingTool.tscn)
- Tool implementation: [`../Tables/AtlasCatalogTable/Tools/semantic_naming_tool.gd`](../Tables/AtlasCatalogTable/Tools/semantic_naming_tool.gd)
- First semantic snapshot: [`../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_001.json`](../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_001.json)
- Current semantic snapshot: [`../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_003.json`](../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_003.json)
- Validator: [`../Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_semantic_aliases.gd`](../Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_semantic_aliases.gd)
- Accepted membership catalog: [`../Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json`](../Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json)

## Naming Contract

- Names use lowercase `snake_case` and must be unique.
- Ordinary visual families use a zero-based, three-digit UID: `000`, `001`, ... `999`.
- Connected terrain uses role/topology/material/set/direction rather than an arbitrary UID, as in `floor_outer_stone_a_nw`.
- Shared directions are `n`, `ne`, `e`, `se`, `s`, `sw`, `w`, and `nw`.
- Directional diagonals preserve both ordered ends: `nw2se`, `se2nw`, `ne2sw`, and `sw2ne`.
- A name describes supported visible identity. Category, family, tags, and notes carry relationships or usage context.
- Biome/context terms such as `overworld`, `forest`, `desert`, and `dungeon` may be searchable tags even when also useful in an alias.
- Ambiguous entries remain unnamed. The tool does not invent aliases to force full coverage.
- Notes and other review metadata may be preserved before an alias is assigned; named-alias count and total semantic-record count are tracked separately.
- Coordinate addresses remain authoritative and immutable. An existing alias must never silently move to another address.

Established ordinary-family forms are:

```text
forest_tree_NNN
desert_cactus_NNN
actor_NNN_name
weapon_type_NNN
armor_type_NNN
deco_type_NNN
overworld_house_material_NNN
```

The broader default is `item-type_variance-UID`, omitting only fields that do not add meaning. `overworld` is also retained as a tag for overworld assets. Water, river, and coastline topology vocabulary remains deliberately open until a complete visual kit is reviewed.

## F6 Workflow

1. Open `SemanticNamingTool.tscn` and press F6.
2. Use the left filter to search addresses, aliases, categories, families, or tags. The list contains only accepted catalog members.
3. Inspect the active sprite at 16× nearest-neighbor scale and use the whole-atlas context highlight to preserve kit relationships.
4. Edit alias, category, family, comma-separated tags, and note. `Previous`/`Next` or Ctrl+Left/Ctrl+Right navigate by accepted atlas order.
5. Ctrl+S or `Save New Snapshot` validates the entire working set, refuses invalid or duplicate aliases, and writes the next unused `semantic_aliases_NNN.json` file.
6. Clearing an alias removes only the working semantic record. It never removes the accepted coordinate from the catalog.

During the full naming pass, `Request Remove` adds an optional Boolean review flag. It marks an address for later reconciliation without removing catalog membership. Older snapshots omit the field and load as `false`; new saves normalize an explicit Boolean value for each semantic record.

## Accepted Seed Mapping

- Frames `18`, `19`, `20`, `67`, `68`, `69`, `116`, `117`, `118`, `165`, `166`, `167`, `168`, `214`, `215`, `216`, and `217` form the confirmed `floor_*_stone_a_*` family.
- Frame `145`, address `atlas_x47_y02`, is `armor_hood_000`.
- Frame `192`, address `atlas_x45_y03`, is `armor_belt_000`.
- Snapshot `001` contains exactly these 19 aliases. Its SHA-256 is `96a084a0924a7a9955f90fb0cab29e94a68d1d502dbd8c202f55280f3c178719`.
- Snapshot `002` is the preserved first F6 save test. It exposed that a note-only edit was not retained, prompting the in-scope persistence correction rather than a false completion claim.
- Snapshot `003`, SHA-256 `5c5fc50ae99b44ccb5315ba915ac22deab7ca7ea3e883cbc5a6a1ffd63dcef51`, proves the correction: it contains 19 named aliases and 20 total records, including exact note-only record `atlas_x01_y01` / `Tree number 2`.

## Validation And Current Limits

- Selection snapshot `004`, SHA-256 `a574fa00b2018ccdfef122202e42d406d0724a790a401ca3a22fe69ba43fd3e9`, is schema 2 / sequence 4 with 499 unique `keep` cells.
- Its exact difference from snapshot `003` is frame `145` at `(47,2)` and frame `192` at `(45,3)`; no prior coordinate or state was removed or changed.
- The 499-entry catalog is an exact index-by-index reconciliation of snapshot `004`.
- Godot validation passed selection/catalog equality, exact alias-to-frame mapping, accepted-address ownership, uniqueness, syntax, required metadata, and declared counts.
- Static lookup generation remained deterministic and its exhaustive 499-entry validator passed.
- The naming scene starts and reloads newest snapshot `003` without parse, validation, or runtime errors.
- Rob confirmed the enlarged sprite, whole-atlas context, and selected-cell indicator were visible and tracked selection correctly.
- Rob created snapshots `002` and `003`; the final save preserves the note-only edit exactly. The F6 workflow is human-validated and this checkpoint is complete.
- Semantic names are workshop metadata at this checkpoint; a runtime alias lookup is not yet claimed.
