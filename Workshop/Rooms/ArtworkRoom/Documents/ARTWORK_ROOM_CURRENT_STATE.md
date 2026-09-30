# ArtworkRoom Current State
Updated: 2026-09-30
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[HumanCatalogSelection]`
Implementation baseline/evidence: Uncommitted Room files, validated intake/classification and selection tooling, plus human-accepted resolved snapshot `003` and its derived 497-entry catalog; source atlas and prior snapshot hashes remain unchanged.

## Rapid Shape

ArtworkRoom contains a preserved setup scene, validated review evidence, completed human-validated selection tooling, and a human-accepted catalog of 497 exact atlas cells. Snapshot `003` resolves every cell to keep and the derived catalog gives each entry a stable coordinate ID and honest broad category. Godot consumer resources remain unimplemented and require a separate contract. `DOTS.md` is authoritative for authorization, dependencies, and traversal.

## Current Locations And Structure

```text
Workshop/Rooms/ArtworkRoom/
├── Assets/
│   ├── .gitkeep
│   └── Possible_Artwork/
│       ├── colored-transparent.png
│       ├── colored-transparent.png.import
│       ├── colored-transparent_packed.png
│       └── colored-transparent_packed.png.import
├── Documents/
│   ├── ARTWORK_ROOM_CURRENT_STATE.md
│   ├── ATLAS_INTAKE.md
│   ├── ATLAS_SELECTION_TOOL.md
│   └── FANTASY_CANDIDATES.md
├── DOTS.md
├── SpriteTest.tscn
└── Tables/
    ├── AtlasCatalogTable/
    │   ├── AtlasSelectionTool.tscn
    │   ├── Catalog/
    │   │   └── fantasy_sprite_catalog.json
    │   ├── Evidence/
    │   │   ├── atlas_cells.csv
    │   │   └── ContactSheets/ (four labeled PNGs)
    │   ├── Selections/
    │   │   ├── .gitkeep
    │   │   ├── atlas_selection_001.json
    │   │   ├── atlas_selection_002.json
    │   │   └── atlas_selection_003.json
    │   └── Tools/
    │       ├── atlas_selection_tool.gd
    │       └── generate_atlas_intake.gd
    └── SpriteTestTable/
        └── SpriteTest.tscn
```

The two `SpriteTest.tscn` files are distinct current files. The Table scene is the preserved one-node setup input. The root scene is a later user addition containing a `Sprite2D` configured against the original atlas.

## Entry Points And Flow

The intake generator reads the packed atlas, validates its exact dimensions, emits per-cell geometry evidence, and renders four enlarged review sheets. Classification provides optional review context. The F6 tool owns exact human input: it validates and preloads the newest snapshot, Rob distinguishes keep from uncertain cells, Space writes a new lossless snapshot, and Cody validates that snapshot before catalog reconciliation.

## Component Contracts

- `DOTS.md`: authoritative Room outcome, authorization, Box dependencies, status, and next-action record.
- `Assets/Possible_Artwork/colored-transparent.png`: original `832x373` indexed-color PNG, SHA-256 `532cf2ec79419cfabc6a757611737bcba43e24aed61d810aa6dda7ce69307b9b`. Its dimensions are not an exact 49-by-22 grid of 16-by-16 cells.
- `Assets/Possible_Artwork/colored-transparent_packed.png`: packed `784x352` indexed-color PNG, SHA-256 `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`. Its dimensions exactly equal 49 columns by 22 rows of 16-by-16 cells. Intake validation is complete; canonical runtime use remains pending human catalog and consumer acceptance.
- `SpriteTest.tscn`: user-added test scene, SHA-256 `4b9ded4716e87a44eadb262f474786f3b1d5b190be73a04ece37bc0e586e6301`. Its `Sprite2D` references `colored-transparent.png`, sets `hframes = 49`, `vframes = 22`, and `frame = 1`, and carries `region_rect = Rect2(18, 0, 16, 16)`. Because the referenced source is not grid-exact, this is observed draft configuration rather than validated lookup behavior.
- `Tables/SpriteTestTable/SpriteTest.tscn`: preserved setup scene with a single `Node2D` named `SpriteTest`, Godot UID `uid://dxcv5icjdvsyn`, and SHA-256 `56d182042fa742869fc2b88cc0b46323384e86f889db98d922097b68b5dd334e`.
- `Documents/ATLAS_INTAKE.md`: authoritative grid, coordinate, output, and intake-validation reference.
- `Tables/AtlasCatalogTable/Tools/generate_atlas_intake.gd`: validated generation tool for contact sheets and cell geometry evidence; it is editor/workshop tooling, not runtime code.
- `Tables/AtlasCatalogTable/Evidence/`: retained review evidence consisting of four labeled PNGs and a 1,078-row cell manifest.
- `Documents/FANTASY_CANDIDATES.md`: current human-review packet containing 31 candidate clusters, confidence boundaries, exclusions, and the selection contract.
- `Tables/AtlasCatalogTable/AtlasSelectionTool.tscn` and `Tools/atlas_selection_tool.gd`: F6 selection surface and implementation. They validate the atlas and newest snapshot before preload, map clicks to cells and keep/uncertain states, render distinct overlays, and save append-only schema-2 snapshots.
- `Documents/ATLAS_SELECTION_TOOL.md`: authoritative use, saved-data, validation, and current human-check contract.
- `Tables/AtlasCatalogTable/Selections/atlas_selection_001.json`: first human-produced broad candidate pool; 497 exact, unique, sorted, in-bounds cells with validated frames, regions, schema, and atlas hash. It is not yet the accepted final catalog.
- `Tables/AtlasCatalogTable/Selections/atlas_selection_002.json`: current authoritative review snapshot; schema 2 with the same 497 coordinates, 495 `keep`, and uncertain cells `(16, 0)` and `(17, 0)`.
- `Tables/AtlasCatalogTable/Selections/atlas_selection_003.json`: accepted resolved selection; schema 2 with all 497 coordinates set to `keep`.
- `Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json`: accepted membership catalog with 497 unique `atlas_xXX_yYY` identifiers, broad `curated_fantasy` category, and exact coordinate/frame/region mappings.
- `Documents/FINAL_FANTASY_CATALOG.md`: authoritative human-selection result, mapping contract, evidence, and remaining consumer limits.

## Required Outside Data

Rob's visual judgment is required to accept or reject candidate sprites and to resolve genuinely ambiguous semantics. A later Godot consumer-resource Box also requires an approved contract stating which catalog entries serve terrain, static item art, effects, animation, or another concrete consumer.

## Validation And Current Limits

- Direct file inspection confirmed both PNG dimensions, both scene definitions, Godot import sidecars, and the SHA-256 values recorded here.
- Arithmetic confirms `784 / 49 = 16` and `352 / 22 = 16`; the same contract does not hold for `832x373`.
- Four derived contact sheets and the cell manifest were generated successfully; the source image hash remained unchanged.
- Thirty-one sprite clusters have been classified for review; none has been human-accepted, assigned a final game-facing identifier, or wired into a Godot consumer.
- The selection tool's headless self-test and scene-start check passed. Rob's F6 test then created snapshot `001`, which passed full structural and source-contract validation.
- Refinement self-test passed schema-1 preload, schema-2 review states and round-trip, invalid duplicate refusal, and unique target naming. Actual scene startup loaded all 497 cells from snapshot `001`.
- Rob confirmed all refined F6 functionality and saved snapshot `002`; it passed full structural and source-contract validation.
- Snapshot `001` and the atlas remain byte-identical. Snapshot `002` preserves all 497 coordinates while identifying two uncertain cells.
- Rob resolved both uncertain marks as interaction tests and directed that both remain kept. Snapshot `003` and the derived 497-entry catalog passed exact validation.
- Human Catalog Selection is complete. Consumer roles and Godot resources remain pending a separate Alignment/Execute contract.
- Human acceptance and Git checkpointing remain pending.
