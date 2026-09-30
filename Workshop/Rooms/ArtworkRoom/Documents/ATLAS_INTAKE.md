# ArtworkRoom Atlas Intake
Updated: 2026-09-29
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasIntake]`
Implementation baseline/evidence: `colored-transparent_packed.png`, SHA-256 `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`; inspected and processed with Godot 4.4.1 on 2026-09-29.

## Rapid Shape

The packed atlas is a valid 49-column by 22-row grid containing 1,078 cells of exactly 16 by 16 pixels. Zero-based `(x, y)` atlas coordinates are authoritative for review. A derived row-major frame is `frame = y * 49 + x`. Four enlarged, coordinate-labeled contact sheets and a per-cell evidence manifest provide the review surface for fantasy-candidate classification.

## Current Locations And Structure

- Source candidate: [`../Assets/Possible_Artwork/colored-transparent_packed.png`](../Assets/Possible_Artwork/colored-transparent_packed.png)
- Generator: [`../Tables/AtlasCatalogTable/Tools/generate_atlas_intake.gd`](../Tables/AtlasCatalogTable/Tools/generate_atlas_intake.gd)
- Cell evidence: [`../Tables/AtlasCatalogTable/Evidence/atlas_cells.csv`](../Tables/AtlasCatalogTable/Evidence/atlas_cells.csv)
- Contact sheets:
  - [`atlas_x00-24_y00-10.png`](../Tables/AtlasCatalogTable/Evidence/ContactSheets/atlas_x00-24_y00-10.png)
  - [`atlas_x25-48_y00-10.png`](../Tables/AtlasCatalogTable/Evidence/ContactSheets/atlas_x25-48_y00-10.png)
  - [`atlas_x00-24_y11-21.png`](../Tables/AtlasCatalogTable/Evidence/ContactSheets/atlas_x00-24_y11-21.png)
  - [`atlas_x25-48_y11-21.png`](../Tables/AtlasCatalogTable/Evidence/ContactSheets/atlas_x25-48_y11-21.png)

## Component Contracts

- Atlas coordinates are zero-based: `(0, 0)` is the top-left cell, `x` increases rightward, and `y` increases downward.
- Each contact-sheet label is `xx,yy`. The displayed sprite is enlarged four times with nearest-neighbor scaling and composited over a checkerboard only in the derived review image.
- `atlas_cells.csv` has one row per atlas cell and records coordinate, derived frame, nontransparent-pixel count, and the occupied bounding box local to the 16-by-16 cell.
- Generated evidence does not alter or replace the source atlas.

## Validation And Current Limits

- Godot 4.4.1 executed the generator successfully and produced four PNG sheets plus the CSV manifest.
- The manifest contains 1,078 data rows: 1,077 occupied cells and one empty cell at `(0, 0)`.
- All four PNGs were opened at original detail and their coordinate labels, nearest-neighbor pixels, page coverage, and transparency checkerboards were visually inspected.
- The source SHA-256 remained `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74` after generation.
- Godot emitted an expected editor-tool warning because the script loads the source PNG directly as an `Image`; the generator is not runtime/export code.
- Intake establishes geometry and review evidence only. It does not establish sprite semantics or human acceptance.
