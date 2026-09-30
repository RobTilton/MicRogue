# ArtworkRoom Final Fantasy Sprite Catalog
Updated: 2026-09-30
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[HumanCatalogSelection]`
Implementation baseline/evidence: Rob resolved both uncertain marks as interaction tests and directed that they remain kept; resolved snapshot `003` and the derived catalog were validated on 2026-09-30.

## Rapid Shape

The accepted catalog contains 497 exact atlas cells. Every entry is retained, has a stable coordinate-derived identifier, and maps losslessly to the validated packed atlas. This catalog decides membership only. It does not invent semantic roles or claim that every retained cell must be used by a final game consumer.

## Current Locations And Structure

- Accepted selection: [`../Tables/AtlasCatalogTable/Selections/atlas_selection_003.json`](../Tables/AtlasCatalogTable/Selections/atlas_selection_003.json)
- Machine-readable catalog: [`../Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json`](../Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json)
- Packed atlas: [`../Assets/Possible_Artwork/colored-transparent_packed.png`](../Assets/Possible_Artwork/colored-transparent_packed.png)
- Prior human evidence: snapshots `001` and `002` remain preserved in the same `Selections/` directory.

## Component Contracts

- Snapshot `003` uses schema 2, save sequence 3, and contains 497 cells, all with `review_state: "keep"`.
- Catalog entries are sorted by `y`, then `x`.
- Stable identifier format is `atlas_xXX_yYY`, using zero-padded, zero-based atlas coordinates. Example: `(16, 0)` is `atlas_x16_y00`.
- Every entry records `category: "curated_fantasy"`, exact `(x, y)`, derived row-major frame, and pixel region.
- The broad category records approved membership without asserting an unsupported semantic subtype. Terrain-kit, prop, equipment, effect, or animation ownership belongs to the later consumer-resource contract.
- `frame = y * 49 + x` and `region = [x * 16, y * 16, 16, 16]`.
- Atlas SHA-256 is `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`.

## Validation And Current Limits

- Resolved snapshot `003` SHA-256: `a3059f94824af3d9e8d37b7206283317e6950802a876d03f38d0e2700cf8baa6`.
- Catalog SHA-256: `d532acd66182a71c3b555972f71cf079413838f1f1795cc2a7cf3ababa07c0a5`.
- All 497 coordinates are unique, in bounds, strictly sorted, and matched to their exact frame and region.
- All 497 catalog identifiers are unique.
- Godot self-test passed after finalization, and the actual scene loaded all 497 cells from snapshot `003`.
- Snapshots `001`, `002`, and the packed atlas remained unchanged during finalization.
- Catalog membership is human-accepted. Consumer roles, TileSet composition, animation grouping, runtime resources, and Production adoption remain unimplemented and unapproved.
