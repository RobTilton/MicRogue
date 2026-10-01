# ArtworkRoom Semantic Naming Pass 01
Updated: 2026-09-30
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[SemanticNamingPass01]`
Implementation baseline/evidence: A ten-alias conservative equipment draft was generated from human snapshot `003`, validated exactly, and loaded through the F6 tool. Human review remains pending.

## Rapid Shape

This pass proves that semantic naming can proceed in small visual batches without re-reading the full atlas. The reviewed crop was limited to accepted cells inside `x37–48, y2–8`; only ten high-confidence objects in rows `y2–3` received draft names. Forty-nine other accepted cells in the crop remain untouched because their exact identity or best vocabulary was not sufficiently clear.

## Inputs And Outputs

- Preserved human baseline: [`../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_003.json`](../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_003.json), SHA-256 `5c5fc50ae99b44ccb5315ba915ac22deab7ca7ea3e883cbc5a6a1ffd63dcef51`
- Draft snapshot: [`../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_004.json`](../Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_004.json), SHA-256 `2dfe06388be1ce6ea84eca8ed88254bac4e4fadd84390ef97bdd7e95b7004262`
- Bounded generator: [`../Tables/AtlasCatalogTable/Tools/generate_semantic_naming_batch_01.gd`](../Tables/AtlasCatalogTable/Tools/generate_semantic_naming_batch_01.gd)
- Exact validator: [`../Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_semantic_naming_batch_01.gd`](../Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_semantic_naming_batch_01.gd)
- Review surface: [`../Tables/AtlasCatalogTable/SemanticNamingTool.tscn`](../Tables/AtlasCatalogTable/SemanticNamingTool.tscn)

## Draft Aliases

| Frame | Address | Draft alias |
|---:|---|---|
| 135 | `atlas_x37_y02` | `shield_round_brown_000` |
| 136 | `atlas_x38_y02` | `shield_round_gray_000` |
| 137 | `atlas_x39_y02` | `shield_round_brown_001` |
| 138 | `atlas_x40_y02` | `shield_round_gray_001` |
| 141 | `atlas_x43_y02` | `armor_crown_000` |
| 142 | `atlas_x44_y02` | `armor_crown_001` |
| 184 | `atlas_x37_y03` | `shield_tall_brown_000` |
| 185 | `atlas_x38_y03` | `shield_tall_gray_000` |
| 186 | `atlas_x39_y03` | `shield_tall_gray_001` |
| 187 | `atlas_x40_y03` | `shield_tall_brown_001` |

Color words are descriptive visual placeholders, not claims about material or gameplay properties. `round` and `tall` distinguish visible silhouettes without asserting a specialized historical shield type.

## Human Review

Open `SemanticNamingTool.tscn` with F6 and filter for `Batch 01`. The tool now searches notes as well as address, alias, category, family, and tags, so the ten draft records appear together. Correct any alias or metadata that does not match the art, then save a new numbered snapshot. No change is required merely to accept a draft name; saving the reviewed state provides the durable human checkpoint.

## Validation And Current Limits

- All 20 source records from snapshot `003`, including `Tree number 2`, are structurally identical in draft snapshot `004`.
- Exactly ten new accepted addresses were added; all lie within rows `y2–3` of the approved crop.
- All 29 named aliases are unique; snapshot `004` contains 30 total semantic records and sequence `4`.
- The draft generator refuses changed source hashes, conflicts, and overwrite of an existing target.
- The exact batch validator passed, and the F6 tool loads snapshot `004` without parse or runtime errors.
- These ten names remain drafts until Rob's F6 review. No runtime alias lookup, source-pixel edit, catalog-membership change, or Production write occurred.
