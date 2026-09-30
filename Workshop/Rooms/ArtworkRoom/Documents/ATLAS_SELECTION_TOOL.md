# ArtworkRoom Atlas Selection Tool
Updated: 2026-09-29
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasSelectionTool]`
Implementation baseline/evidence: `AtlasSelectionTool.tscn` and `atlas_selection_tool.gd` agent-validated with Godot 4.4.1; Rob's F6 interaction produced validated `atlas_selection_001.json` on 2026-09-29.

## Rapid Shape

The tool converts Rob's direct visual choices into lossless, append-only selection snapshots. It displays the validated packed atlas, maps each click to one exact 16-by-16 cell, and saves sorted coordinates plus derived frames and pixel regions. Descriptive candidate prose is supporting context only; a human-produced validated snapshot is authoritative for Human Catalog Selection.

## Current Locations And Structure

- F6 scene: [`../Tables/AtlasCatalogTable/AtlasSelectionTool.tscn`](../Tables/AtlasCatalogTable/AtlasSelectionTool.tscn)
- Tool script: [`../Tables/AtlasCatalogTable/Tools/atlas_selection_tool.gd`](../Tables/AtlasCatalogTable/Tools/atlas_selection_tool.gd)
- Append-only snapshot directory: [`../Tables/AtlasCatalogTable/Selections/`](../Tables/AtlasCatalogTable/Selections/)
- Read-only source: [`../Assets/Possible_Artwork/colored-transparent_packed.png`](../Assets/Possible_Artwork/colored-transparent_packed.png)

## Entry Points And Flow

1. Open `AtlasSelectionTool.tscn` in Godot and press F6.
2. Left-click a sprite cell to select it; left-click it again to deselect it.
3. Middle-drag to pan. Use the mouse wheel for bounded integer zoom levels `1x`, `2x`, `4x`, and `8x`.
4. Read the hover line for exact `(x, y)`, derived frame, and selection state.
5. Press Space to save the entire current selection to the next unused `atlas_selection_NNN.json` path.
6. Report the saved filename to Cody for exact validation and catalog reconciliation.

## Component Contracts

- The tool refuses to enable saving unless the source exists, is `784x352`, and has SHA-256 `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`.
- `(0, 0)` is the top-left cell. `x` increases rightward and `y` increases downward.
- `frame = y * 49 + x`.
- `region = [x * 16, y * 16, 16, 16]`.
- Selection snapshots record schema version, source path/hash, atlas and cell dimensions, grid dimensions, save sequence, selected count, and cells sorted by `y` then `x`.
- Space allocates a new filename and never overwrites an existing snapshot or temporary file.
- Before finalization, output JSON is validated in memory, written to a unique temporary path, read back and parsed, then renamed to its final numbered path. A failed temporary artifact is retained and reported rather than silently discarded.
- An empty selection may be intentionally saved and is recorded with a zero count.

## Validation And Current Limits

- Godot 4.4.1 loaded the scene and script without parse or runtime-startup errors.
- Headless self-test passed source validation, screen-to-cell mapping, deterministic coordinate sorting, frame derivation, pixel-region derivation, JSON round-trip validation, and unused snapshot-name allocation.
- A separate short launch of the actual scene exited successfully.
- The packed atlas SHA-256 remained unchanged after validation.
- Automated tests intentionally created no selection snapshot; they do not impersonate human selection.
- Rob confirmed actual F6 selection and saved `atlas_selection_001.json` with 497 selected cells.
- Snapshot validation found 497 declared, present, and unique entries; correct `y`-then-`x` ordering; valid bounds; exact derived frames and pixel regions; matching schema and source hash; and SHA-256 `c76bffb4a3fa17342275cc84d39ec6fb608dba0d9a6ba242a90f6b817e389f1f` for the snapshot itself.
- The Selection Tool Box is complete. Rob has not accepted snapshot `001` as the final catalog because some selected cells may be useless pieces of larger kits; that uncertainty belongs to Human Catalog Selection.
