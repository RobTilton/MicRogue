# ArtworkRoom Semantic Naming Full Pass
Updated: 2026-09-30
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[SemanticNamingFullPass]`
Implementation baseline/evidence: Selected-only evidence was generated from the 499-entry accepted catalog. Draft snapshot `005` supplies a unique alias and complete semantic record for every accepted address; automated validation and scene loading pass. Robert's comprehensive review remains pending.

## Rapid Shape

This is a complete review draft, not final semantic authority. It preserves the 29 previously named aliases, losslessly enriches the one prior note-only record, and gives the remaining 470 cells conservative family-level names. It deliberately favors honest broad labels over invented subtype, material, gameplay, or lore claims.

## Inputs And Outputs

- Accepted catalog: [`../Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json`](../Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json), 499 entries
- Preserved source: [`../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_004.json`](../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_004.json), SHA-256 `2dfe06388be1ce6ea84eca8ed88254bac4e4fadd84390ef97bdd7e95b7004262`
- Full draft: [`../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_005.json`](../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_005.json), SHA-256 `407ab8ec2f71744bc3a8ccb10fd890c4e1eebd7c607cb1d396672ec09b34c670`
- Selected-only evidence: [`../Tables/AtlasCatalogTable/Evidence/SelectedReviewSheets/`](../Tables/AtlasCatalogTable/Evidence/SelectedReviewSheets/)
- Evidence generator: [`../Tables/AtlasCatalogTable/Tools/generate_selected_review_sheets.gd`](../Tables/AtlasCatalogTable/Tools/generate_selected_review_sheets.gd)
- Draft generator: [`../Tables/AtlasCatalogTable/Tools/generate_semantic_naming_full_pass.gd`](../Tables/AtlasCatalogTable/Tools/generate_semantic_naming_full_pass.gd)
- Validator: [`../Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_semantic_naming_full_pass.gd`](../Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_semantic_naming_full_pass.gd)
- Human review surface: [`../Tables/AtlasCatalogTable/SemanticNamingTool.tscn`](../Tables/AtlasCatalogTable/SemanticNamingTool.tscn)

## Draft Strategy

The four selected-only sheets show only accepted cells while retaining coordinate and frame labels. Established candidate clusters and the visible family layout route remaining cells into broad families such as:

```text
actor_NNN_unnamed
armor_headgear_NNN
armor_piece_NNN
deco_container_NNN
deco_furniture_NNN
deco_object_NNN
deco_structure_NNN
dungeon_tile_NNN
effect_guard_NNN
effect_hit_NNN
effect_magic_NNN
equipment_piece_NNN
forest_vegetation_NNN
item_consumable_NNN
overworld_structure_NNN
weapon_blade_NNN
weapon_unknown_NNN
```

All ordinary UIDs are deterministic, zero-based, three-digit values assigned in accepted atlas order. Previously confirmed terrain topology names and Batch 01 equipment names remain unchanged.

## Review Status

- `full_pass`: generated or enriched during this full pass; 470 records.
- `draft`: visually stronger cluster assignment; 157 records.
- `review_required`: mixed, broad, or fallback assignment; 313 records.
- Previously named aliases are preserved without retroactively adding these tags.

The status is carried as a searchable tag. It indicates semantic confidence only; every coordinate and atlas region is already exact.

## One-Pass F6 Review

1. Open `SemanticNamingTool.tscn` and press F6. It loads snapshot `005` automatically.
2. Leave the filter empty to review all 499 records in atlas order.
3. Filter `review_required` to inspect the 313 least-specific names first, or `full_pass` to isolate all 470 newly generated records.
4. Previous/Next and Ctrl+Left/Ctrl+Right follow the filtered list.
5. Correct alias, category, family, tags, or notes as needed. Keep aliases lowercase `snake_case` and unique.
6. Save periodically if desired; each Ctrl+S produces a new immutable numbered snapshot. The last saved snapshot after the complete once-over becomes the human candidate.

## Validation And Current Limits

- Snapshot `005` contains exactly 499 records and 499 non-empty unique aliases in catalog order.
- All addresses match the accepted catalog one-for-one; every alias passes lowercase `snake_case` syntax.
- All 29 previously named records are byte-equivalent at the parsed-record level.
- The prior `atlas_x01_y01` note `Tree number 2` is retained while that record receives a draft alias and metadata.
- Exactly 470 records carry `full_pass`; each carries exactly one of `draft` or `review_required`.
- Counts are 157 `draft` and 313 `review_required`.
- The generator refuses changed hashes and overwrite of snapshot `005`. The validator passed and the F6 tool loads the full snapshot without errors.
- Broad family assignment is not a claim of exact subtype. Runtime alias lookup and Production adoption remain outside this checkpoint.
- The checkpoint remains incomplete until Robert finishes the once-over and identifies the final saved snapshot.
