# ArtworkRoom Final Fantasy Sprite Catalog
Updated: 2026-09-30
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[HumanCatalogSelection]`
Implementation baseline/evidence: Rob retained the 497 cells from snapshot `003`, added a hood and belt in snapshot `004`, and the derived 499-entry catalog was validated on 2026-09-30.

## Rapid Shape

The accepted catalog contains 499 exact atlas cells. Every entry is retained, has a stable coordinate-derived identifier, and maps losslessly to the validated packed atlas. This catalog decides membership only. Semantic names remain a separate layer and do not replace coordinate identity.

## Current Locations And Structure

- Accepted selection: [`../Tables/AtlasCatalogTable/Selections/atlas_selection_004.json`](../Tables/AtlasCatalogTable/Selections/atlas_selection_004.json)
- Machine-readable catalog: [`../Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json`](../Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json)
- Packed atlas: [`../Assets/Possible_Artwork/colored-transparent_packed.png`](../Assets/Possible_Artwork/colored-transparent_packed.png)
- Prior human evidence: snapshots `001`, `002`, and `003` remain preserved in the same `Selections/` directory.

## Component Contracts

- Snapshot `004` uses schema 2, save sequence 4, and contains 499 cells, all with `review_state: "keep"`.
- Catalog entries are sorted by `y`, then `x`.
- Stable identifier format is `atlas_xXX_yYY`, using zero-padded, zero-based atlas coordinates. Example: `(16, 0)` is `atlas_x16_y00`.
- Every entry records `category: "curated_fantasy"`, exact `(x, y)`, derived row-major frame, and pixel region.
- The broad category records approved membership without asserting an unsupported semantic subtype. Terrain-kit, prop, equipment, effect, or animation ownership belongs to the later consumer-resource contract.
- `frame = y * 49 + x` and `region = [x * 16, y * 16, 16, 16]`.
- Atlas SHA-256 is `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`.

## Validation And Current Limits

- Accepted snapshot `004` SHA-256: `a574fa00b2018ccdfef122202e42d406d0724a790a401ca3a22fe69ba43fd3e9`.
- Catalog SHA-256: `438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2`.
- All 499 coordinates are unique, in bounds, strictly sorted, and matched to their exact frame and region.
- Snapshot `004` differs from `003` only by frame `145` `(47,2)` and frame `192` `(45,3)`.
- All 499 catalog identifiers are unique, and automated validation confirmed exact index-by-index equality with snapshot `004`.
- Snapshots `001` through `004` and the packed atlas remain preserved.
- Catalog membership is human-accepted. Consumer roles, TileSet composition, animation grouping, runtime resources, and Production adoption remain unimplemented and unapproved.
