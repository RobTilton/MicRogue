# ArtworkRoom Current State
Updated: 2026-09-30
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[SemanticSpriteAliases]`
Implementation baseline/evidence: Human-accepted 499-entry catalog, deterministic typed static lookup, and human-validated semantic naming workflow with 19 confirmed aliases and one note-only record as of 2026-09-30.

## Rapid Shape

ArtworkRoom contains a preserved setup scene, validated review evidence, completed human selection tooling, and a human-accepted catalog of 499 exact atlas cells. A typed static Godot lookup returns cached 16-by-16 `AtlasTexture` regions for every accepted ID. Optional semantic aliases are now recorded in append-only snapshots and edited through an F6 tool; 19 user-confirmed names are seeded. Runtime alias lookup, TileSet composition, and animation consumers remain unimplemented. `DOTS.md` is authoritative for authorization, dependencies, and traversal.

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
│   ├── FANTASY_CANDIDATES.md
│   ├── FINAL_FANTASY_CATALOG.md
│   ├── SEMANTIC_SPRITE_ALIASES.md
│   └── STATIC_ATLAS_LOOKUP.md
├── DOTS.md
├── SpriteTest.tscn
└── Tables/
    ├── AtlasCatalogTable/
    │   ├── AtlasSelectionTool.tscn
    │   ├── SemanticNamingTool.tscn
    │   ├── Catalog/
    │   │   └── fantasy_sprite_catalog.json
    │   ├── GodotConsumers/
    │   │   ├── fantasy_sprite_catalog.gd
    │   │   ├── fantasy_sprite_entry.gd
    │   │   ├── static_atlas_lookup_preview.gd
    │   │   ├── StaticAtlasLookupPreview.tscn
    │   │   ├── Generated/
    │   │   │   └── fantasy_sprite_regions.gd
    │   │   └── Tests/
    │   │       ├── validate_semantic_aliases.gd
    │   │       └── validate_static_atlas_lookup.gd
    │   ├── Evidence/
    │   │   ├── atlas_cells.csv
    │   │   └── ContactSheets/ (four labeled PNGs)
    │   ├── Selections/
    │   │   ├── .gitkeep
    │   │   ├── atlas_selection_001.json
    │   │   ├── atlas_selection_002.json
    │   │   ├── atlas_selection_003.json
    │   │   └── atlas_selection_004.json
    │   ├── SemanticAliases/
    │   │   ├── semantic_aliases_001.json
    │   │   ├── semantic_aliases_002.json
    │   │   └── semantic_aliases_003.json
    │   └── Tools/
    │       ├── atlas_selection_tool.gd
    │       ├── generate_atlas_intake.gd
    │       ├── generate_static_atlas_lookup.gd
    │       └── semantic_naming_tool.gd
    └── SpriteTestTable/
        └── SpriteTest.tscn
```

The two `SpriteTest.tscn` files are distinct current files. The Table scene is the preserved one-node setup input. The root scene is a later user addition whose `Sprite2D` now references the validated packed atlas.

## Entry Points And Flow

The intake generator reads the packed atlas, validates its exact dimensions, emits per-cell geometry evidence, and renders four enlarged review sheets. Classification provides optional review context. The F6 tool owns exact human input: it validates and preloads the newest snapshot, Rob distinguishes keep from uncertain cells, Space writes a new lossless snapshot, and Cody validates that snapshot before catalog reconciliation.

## Component Contracts

- `DOTS.md`: authoritative Room outcome, authorization, Box dependencies, status, and next-action record.
- `Assets/Possible_Artwork/colored-transparent.png`: original `832x373` indexed-color PNG, SHA-256 `532cf2ec79419cfabc6a757611737bcba43e24aed61d810aa6dda7ce69307b9b`. Its dimensions are not an exact 49-by-22 grid of 16-by-16 cells.
- `Assets/Possible_Artwork/colored-transparent_packed.png`: packed `784x352` indexed-color PNG, SHA-256 `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`. Its dimensions exactly equal 49 columns by 22 rows of 16-by-16 cells. Intake and human catalog acceptance are complete; broader runtime adoption remains pending the consumer-resource contract.
- `SpriteTest.tscn`: corrected user-added test scene, SHA-256 `b17b1340e7aa01934156fc957652d02421beb43edba2313bcb9e631aa359b58d`. Its `Sprite2D` references `colored-transparent_packed.png` with UID `uid://cbkktuubutlil`, retains `hframes = 49`, `vframes = 22`, `frame = 1`, and `region_rect = Rect2(18, 0, 16, 16)`, and resolves exact 16-by-16 frames.
- `Tables/SpriteTestTable/SpriteTest.tscn`: preserved setup scene with a single `Node2D` named `SpriteTest`, Godot UID `uid://dxcv5icjdvsyn`, and SHA-256 `56d182042fa742869fc2b88cc0b46323384e86f889db98d922097b68b5dd334e`.
- `Documents/ATLAS_INTAKE.md`: authoritative grid, coordinate, output, and intake-validation reference.
- `Tables/AtlasCatalogTable/Tools/generate_atlas_intake.gd`: validated generation tool for contact sheets and cell geometry evidence; it is editor/workshop tooling, not runtime code.
- `Tables/AtlasCatalogTable/Evidence/`: retained review evidence consisting of four labeled PNGs and a 1,078-row cell manifest.
- `Documents/FANTASY_CANDIDATES.md`: current human-review packet containing 31 candidate clusters, confidence boundaries, exclusions, and the selection contract.
- `Tables/AtlasCatalogTable/AtlasSelectionTool.tscn` and `Tools/atlas_selection_tool.gd`: F6 selection surface and implementation. They validate the atlas and newest snapshot before preload, map clicks to cells and keep/uncertain states, render distinct overlays, and save append-only schema-2 snapshots.
- `Documents/ATLAS_SELECTION_TOOL.md`: authoritative use, saved-data, validation, and current human-check contract.
- `Tables/AtlasCatalogTable/Selections/atlas_selection_001.json`: first human-produced broad candidate pool; 497 exact, unique, sorted, in-bounds cells with validated frames, regions, schema, and atlas hash. It is not yet the accepted final catalog.
- `Tables/AtlasCatalogTable/Selections/atlas_selection_002.json`: preserved intermediate review snapshot; schema 2 with the same 497 coordinates, 495 `keep`, and uncertain cells `(16, 0)` and `(17, 0)`.
- `Tables/AtlasCatalogTable/Selections/atlas_selection_003.json`: accepted resolved selection; schema 2 with all 497 coordinates set to `keep`.
- `Tables/AtlasCatalogTable/Selections/atlas_selection_004.json`: current accepted selection; preserves all prior members and adds hood frame `145` `(47,2)` plus belt frame `192` `(45,3)`, for 499 `keep` cells.
- `Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json`: accepted membership catalog with 499 unique `atlas_xXX_yYY` identifiers and exact coordinate/frame/region mappings.
- `Documents/FINAL_FANTASY_CATALOG.md`: authoritative human-selection result, mapping contract, evidence, and remaining consumer limits.
- `Tables/AtlasCatalogTable/GodotConsumers/fantasy_sprite_catalog.gd`: typed static lookup API that lazily creates entries and caches exact `AtlasTexture` regions by accepted ID.
- `GodotConsumers/Generated/fantasy_sprite_regions.gd`: deterministic 499-entry Godot data generated from the accepted JSON.
- `GodotConsumers/StaticAtlasLookupPreview.tscn`: six-entry nearest-neighbor F6 validation surface using only the public lookup API.
- `Documents/STATIC_ATLAS_LOOKUP.md`: authoritative API, generation, contracts, validation, and remaining human-check reference.
- `Tables/AtlasCatalogTable/SemanticNamingTool.tscn` and `Tools/semantic_naming_tool.gd`: F6 semantic editor with accepted-only filtering, enlarged sprite and atlas context, metadata fields, validation, and append-only saves.
- `Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_001.json`: first semantic snapshot with the 17 confirmed stone-floor names plus `armor_hood_000` and `armor_belt_000`.
- `Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_002.json`: preserved first human save test; its unchanged semantic values exposed the original note-only persistence defect.
- `Tables/AtlasCatalogTable/SemanticAliases/semantic_aliases_003.json`: current human snapshot with 19 aliases and one exact note-only record, `atlas_x01_y01` / `Tree number 2`.
- `Documents/SEMANTIC_SPRITE_ALIASES.md`: naming syntax, tool workflow, seed mapping, evidence, and current human-validation boundary.

## Required Outside Data

Rob's visual judgment is required to accept or reject candidate sprites and to resolve genuinely ambiguous semantics. A later Godot consumer-resource Box also requires an approved contract stating which catalog entries serve terrain, static item art, effects, animation, or another concrete consumer.

## Validation And Current Limits

- Direct file inspection confirmed both PNG dimensions, both scene definitions, Godot import sidecars, and the SHA-256 values recorded here.
- Arithmetic confirms `784 / 49 = 16` and `352 / 22 = 16`; the same contract does not hold for `832x373`.
- Four derived contact sheets and the cell manifest were generated successfully; the source image hash remained unchanged.
- Thirty-one early sprite clusters remain supporting review evidence; exact human selection supersedes them as membership authority.
- The selection tool's headless self-test and scene-start check passed. Rob's F6 test then created snapshot `001`, which passed full structural and source-contract validation.
- Refinement self-test passed schema-1 preload, schema-2 review states and round-trip, invalid duplicate refusal, and unique target naming. Actual scene startup loaded all 497 cells from snapshot `001`.
- Rob confirmed all refined F6 functionality and saved snapshot `002`; it passed full structural and source-contract validation.
- Snapshot `001` and the atlas remain byte-identical. Snapshot `002` preserves all 497 coordinates while identifying two uncertain cells.
- Rob resolved both uncertain marks as interaction tests and directed that both remain kept. He later saved snapshot `004` with a hood and belt; its 499 entries and the reconciled catalog pass exact equality validation.
- Human Catalog Selection is complete at 499 accepted cells. Earlier snapshots remain preserved.
- Godot loaded the corrected root test scene successfully. The scene diff changed only its texture ext-resource UID/path; the packed atlas and preserved Table scene hashes remained unchanged.
- Static lookup generation and deterministic rerun passed. Exhaustive Godot validation passed all 499 entries, exact textures, caching, and unknown-ID refusal; the preview scene starts cleanly.
- Rob confirmed all six titled F6 preview sprites were visually clear and free of neighboring-cell bleed. Static Atlas Lookup is complete; its titles remain coordinate IDs by approved scope.
- The semantic validator passed the 499-entry membership chain, all 19 exact alias mappings, and the note-only round trip. Rob confirmed visible enlarged/context imagery and tracking, then produced snapshot `003`; the tool reloads it cleanly.
- Git checkpointing remains pending.
