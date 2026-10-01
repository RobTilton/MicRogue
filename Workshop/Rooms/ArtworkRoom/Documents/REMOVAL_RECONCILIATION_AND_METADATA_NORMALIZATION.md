# ArtworkRoom Removal Reconciliation And Metadata Normalization
Updated: 2026-10-01
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[RemovalReconciliationAndMetadataNormalization]`

## Rapid Shape

The 13 removal requests recorded by Robert in semantic snapshot `024` are now applied exactly. The current accepted catalog, selection, semantic layer, and generated Godot lookup contain the same 486 retained atlas addresses. The former 499-entry catalog and every prior selection and semantic snapshot remain preserved as historical evidence.

## Current Outputs

- Selection snapshot `005`: 486 cells, SHA-256 `de185289097da67cf22a9fb6b621a4786ad6da9ce3d4e2d1142268a446e6cb88`
- Accepted catalog: 486 entries, SHA-256 `48e5a186b5ea1abdc666c4d4ec911ddd956aed668552259e735cb7ec3a809285`
- Semantic snapshot `025`: 486 aliases and records, SHA-256 `cdae69a748fbb90d5964b2e92662b8b6dfc427b302a7a6acf3e74b5df2174f56`
- Generated static lookup: 486 entries, SHA-256 `1df01630817e55f58b114446f76f69fed47c82a7fa961713179b8fb8fea1af39`
- Archived 499-entry catalog: `Catalog/History/fantasy_sprite_catalog_499_snapshot024.json`, SHA-256 `438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2`

Snapshot `024` remains the authoritative human-review record. Snapshot `025` is the current consumer-facing semantic state derived from it after exact removal and mechanical metadata normalization; retained aliases are byte-for-byte unchanged.

## Exact Removed Addresses

`atlas_x08_y00`, `atlas_x09_y00`, `atlas_x10_y00`, `atlas_x11_y00`, `atlas_x12_y00`, `atlas_x08_y02`, `atlas_x09_y02`, `atlas_x10_y02`, `atlas_x11_y02`, `atlas_x12_y02`, `atlas_x31_y06`, `atlas_x12_y12`, and `atlas_x04_y14`.

No other address was removed or added.

## Metadata Normalization

- Category is routed mechanically from each retained alias: actors, armor, weapons/projectiles, equipment, shields, effects, items/consumables, decoration, terrain, and structures receive their corresponding consumer category; unmatched aliases remain `unresolved`.
- Family is derived from the alias without changing it: actor families use `actor`; floor topology uses `floor_material_set`; ordinary numeric variants drop their trailing numeric suffix; remaining names use their first two tokens.
- Workflow-only tags `full_pass`, `draft`, and `review_required` were removed.
- Human-authored notes were preserved. Generated notes beginning `Full Pass draft |` were removed.
- Removal flags are false in the retained set because the requested removals are no longer members.

Current category counts are: actor 50, armor 14, deco 105, effect 13, equipment 36, item 8, shield 8, structure 33, terrain 166, unresolved 1, and weapon 52.

## Validation And Limits

- The reconciliation validator passed exact 486-entry alignment across selection `005`, the accepted catalog, and semantic snapshot `025`; all 13 and only those 13 requested addresses are absent.
- It also passed retained-alias preservation, normalized metadata rules, hashes, ordering, bounds, frames, and regions.
- The static lookup validator passed all 486 entries, exact geometry, packed-atlas ownership, caching, and unknown-ID refusal.
- The naming scene reloads snapshot `025`; the static preview scene starts; deterministic regeneration reports the generated lookup already current.
- Historical snapshot-024 and full-pass validators still pass against the archived 499-entry catalog.
- The packed atlas pixels were not modified. Nothing was written to Production, and no runtime semantic lookup, TileSet, or animation consumer is claimed by this checkpoint.
