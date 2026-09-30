# ArtworkRoom Atlas Selection Tool
Updated: 2026-09-30
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasSelectionToolRefinement]`
Implementation baseline/evidence: Original tool and schema-2 refinement human-validated; snapshot `002` structurally validated on 2026-09-30.

## Rapid Shape

The tool converts Rob's direct visual choices into lossless, append-only selection snapshots. It validates and preloads the highest-numbered snapshot, preserving prior selections for refinement. Each selected cell is either `keep` or `uncertain`; both states retain exact coordinates, frames, and regions. Descriptive candidate prose is supporting context only; a human-produced validated snapshot is authoritative for Human Catalog Selection.

## Current Locations And Structure

- F6 scene: [`../Tables/AtlasCatalogTable/AtlasSelectionTool.tscn`](../Tables/AtlasCatalogTable/AtlasSelectionTool.tscn)
- Tool script: [`../Tables/AtlasCatalogTable/Tools/atlas_selection_tool.gd`](../Tables/AtlasCatalogTable/Tools/atlas_selection_tool.gd)
- Append-only snapshot directory: [`../Tables/AtlasCatalogTable/Selections/`](../Tables/AtlasCatalogTable/Selections/)
- Read-only source: [`../Assets/Possible_Artwork/colored-transparent_packed.png`](../Assets/Possible_Artwork/colored-transparent_packed.png)

## Entry Points And Flow

1. Open `AtlasSelectionTool.tscn` in Godot and press F6.
2. The newest snapshot is fully validated and loaded before its cells may populate the tool. Snapshot `001` should report 497 total and 497 keep cells.
3. Left-click a sprite cell to select it as `keep`; left-click a selected cell to deselect it.
4. Right-click a selected cell to toggle between `keep` and `uncertain`. Right-clicking an unselected cell selects it as `uncertain`.
5. Cyan means `keep`; yellow means `uncertain`.
6. Middle-drag to pan. Use the mouse wheel for bounded integer zoom levels `1x`, `2x`, `4x`, and `8x`.
7. Read the HUD for total, keep, uncertain, zoom, and loaded-snapshot values. Hover reports exact `(x, y)`, derived frame, and review state.
8. Press Space to save the entire current selection to the next unused `atlas_selection_NNN.json` path.
9. Report the saved filename to Cody for exact validation and catalog reconciliation.

## Component Contracts

- The tool refuses to enable saving unless the source exists, is `784x352`, and has SHA-256 `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`.
- `(0, 0)` is the top-left cell. `x` increases rightward and `y` increases downward.
- `frame = y * 49 + x`.
- `region = [x * 16, y * 16, 16, 16]`.
- Schema-1 snapshots remain readable; every schema-1 selected cell loads as `keep`.
- New schema-2 snapshots record source path/hash, atlas and cell dimensions, grid dimensions, save sequence, selected count, and cells sorted by `y` then `x`.
- Each schema-2 selected cell records `review_state` as exactly `keep` or `uncertain`.
- The highest-numbered snapshot is authoritative for preload. If it is invalid, the tool refuses it, does not fall back silently, clears in-memory selection, and disables saving.
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
- Refinement self-test passed schema-1 loading and conversion of all 497 cells to `keep`, keep/uncertain transitions, count/state preservation, schema-2 sorting and JSON round-trip, duplicate-cell refusal, and allocation of `atlas_selection_002.json` as the next target.
- The actual scene launch preloaded 497 cells from snapshot `001` successfully.
- Snapshot `001` and the packed atlas remained byte-identical after agent validation; no schema-2 snapshot was fabricated.
- Rob confirmed all refined F6 functionality and saved `atlas_selection_002.json`.
- Snapshot `002` passed schema, sequence, count, uniqueness, bounds, ordering, frame, region, state, and atlas-hash validation. It contains 497 cells: 495 `keep` and 2 `uncertain` at `(16, 0)` and `(17, 0)`.
- Snapshot `002` preserved exactly the coordinate set from snapshot `001`. Snapshot `001` retained SHA-256 `c76bffb4a3fa17342275cc84d39ec6fb608dba0d9a6ba242a90f6b817e389f1f`; snapshot `002` has SHA-256 `6bdf3c63aab5345bd1fba3f38fc238a8ebaba46b7bb9c34e1a965273e10df2af`; the atlas hash remains unchanged.
- Atlas Selection Tool Refinement is complete. Human Catalog Selection now owns the two uncertain-cell decisions and final catalog acceptance.
- Rob identified the two uncertain states as interaction tests and directed that both remain kept. Resolved snapshot `003` contains 497 keep cells, loads successfully through the actual scene, and is the accepted selection input recorded by `FINAL_FANTASY_CATALOG.md`.
- The self-test now checks protected schema-1 snapshot `001` directly while validating whichever legitimate snapshot is newest; it no longer assumes `001` must remain newest.
