# ArtworkRoom DOTS
Updated: 2026-09-29
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasSelectionTool]`
Implementation baseline/evidence: Uncommitted Room files inspected on 2026-09-29; exact paths, dimensions, scene wiring, and SHA-256 values are recorded below.

## Room Contract

- Room: ArtworkRoom
- Outcome: Curate the supplied sprite atlas into a focused, human-approved fantasy-game library and then prepare only the Godot consumer resources justified by that catalog.
- Scope / prohibited territory: Work is contained to `Workshop/Rooms/ArtworkRoom/`. Relevant subjects are fantasy overworld and dungeon terrain, walls, floors, hit effects, containers, melee and other non-gun weapons, armor, shields, and staffs. Exclude exhaustive cataloging, guns, modern or science-fiction material, irrelevant sprites, Production writes, and unapproved modification of source atlas pixels.
- Acceptance: The exact 16-by-16 atlas grid is evidenced; relevant candidates are identified by stable atlas coordinates; Rob explicitly selects the retained catalog; and any later Godot resources use only that accepted catalog and are validated for their stated consumers.
- Authority evidence: Rob confirmed the basic-setup Alignment Check with `Execute` on 2026-09-29. Rob confirmed the documentation-reconciliation Alignment Check with `execute` on 2026-09-29. Rob confirmed the Atlas Intake and Candidate Classification Alignment Check with `Execute` on 2026-09-29. Rob confirmed the Atlas Selection Tool Alignment Check with `Execute` on 2026-09-29. Human catalog selection and Godot-resource implementation remain governed by their documented review gates.
- Starting state: The original setup began from uncommitted `SpriteTest.tscn`, SHA-256 `56d182042fa742869fc2b88cc0b46323384e86f889db98d922097b68b5dd334e`; no user-supplied Git checkpoint was available. Current uncommitted additions are recorded under Current References And Unresolved State.

## Current Traversal

- Last completed checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasSelectionTool]`
- Active/interrupted checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[HumanCatalogSelection]` awaiting refinement or explicit acceptance of snapshot `atlas_selection_001.json`
- Next eligible action: preserve snapshot `001` as the exact broad candidate pool, then resolve Rob's stated uncertainty about kit-support and possibly useless cells before declaring the retained catalog final
- Human acceptance / Git checkpoint: Atlas Selection Tool is human-validated; snapshot `001` is exact but Rob has not accepted its 497 cells as the final retained catalog; no Git checkpoint is known

## Mandatory Box List

| Checkpoint: [Room]+[Table]+[Box] | Responsibility | Depends on | Completion condition | Status | Outputs / evidence |
|---|---|---|---|---|---|
| `[ArtworkRoom]+[SpriteTestTable]+[BasicDirectorySetup]` | Create the Room records and durable basic directories, then isolate the original scene in its Table directory. | none | Root DOTS and the `Documents/`, `Assets/`, and `Tables/` directories exist; the original scene is preserved in its Table; and its SHA-256 matches the starting file. | complete | `DOTS.md`; `Documents/ARTWORK_ROOM_CURRENT_STATE.md`; `Assets/.gitkeep`; `Tables/SpriteTestTable/SpriteTest.tscn`; matching SHA-256 `56d182042fa742869fc2b88cc0b46323384e86f889db98d922097b68b5dd334e` |
| `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasIntake]` | Verify the packed atlas contract and produce a labeled visual reference suitable for coordinate-based review. | `[ArtworkRoom]+[SpriteTestTable]+[BasicDirectorySetup]` | The canonical candidate atlas, dimensions, 16-by-16 grid, coordinate convention, and derived contact-sheet evidence are documented; source assets remain unchanged. | complete | `Documents/ATLAS_INTAKE.md`; four labeled contact sheets; `atlas_cells.csv` with 1,078 cells; source hash unchanged |
| `[ArtworkRoom]+[AtlasCatalogTable]+[FantasyCandidateClassification]` | Identify only likely in-scope fantasy sprites and classify ambiguous entries honestly. | `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasIntake]` | A reviewable candidate list covers the approved subject categories using exact atlas coordinates, excludes obvious dead weight, and marks uncertainty instead of inventing semantics. | complete | `Documents/FANTASY_CANDIDATES.md`; 31 bounded candidate clusters; four source review sheets inspected at original detail |
| `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasSelectionTool]` | Provide a lossless F6 visual selector that records Rob's exact cell choices in preserved numbered snapshots. | `[ArtworkRoom]+[AtlasCatalogTable]+[FantasyCandidateClassification]` | Atlas/hash validation, click mapping, selection overlay, hover evidence, bounded zoom/pan, deterministic unique snapshots, sorted coordinate/frame/region data, JSON round-trip, and source preservation are agent-validated; Rob then confirms actual F6 interaction. | complete | Self-test and scene launch passed; Rob selected/deselected cells and saved `Selections/atlas_selection_001.json`; 497 declared/present/unique cells; bounds, ordering, frames, regions, schema, and atlas hash all validated |
| `[ArtworkRoom]+[AtlasCatalogTable]+[HumanCatalogSelection]` | Reconcile Rob's exact saved selection into the retained game-facing catalog. | `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasSelectionTool]` | A human-produced validated snapshot is recorded; every retained entry has a stable identifier, category, and exact atlas coordinate; human acceptance scope is explicit. | active | `atlas_selection_001.json` is a valid broad candidate pool; Rob reports that some cells may be useless kit pieces, so final acceptance remains unresolved |
| `[ArtworkRoom]+[AtlasCatalogTable]+[GodotConsumerResources]` | Build only the TileSet, static atlas-region, animation, or lookup resources required by approved consumers. | `[ArtworkRoom]+[AtlasCatalogTable]+[HumanCatalogSelection]` | A separately approved consumer contract is implemented and validated against the accepted catalog without modifying source atlas pixels. | planned | Requires later Alignment/Execute and an approved consumer contract; no output yet |

## Current References And Unresolved State

- Current-state reference: [Documents/ARTWORK_ROOM_CURRENT_STATE.md](Documents/ARTWORK_ROOM_CURRENT_STATE.md)
- Completed intake reference: [Documents/ATLAS_INTAKE.md](Documents/ATLAS_INTAKE.md)
- Candidate-selection reference: [Documents/FANTASY_CANDIDATES.md](Documents/FANTASY_CANDIDATES.md)
- Selection-tool reference: [Documents/ATLAS_SELECTION_TOOL.md](Documents/ATLAS_SELECTION_TOOL.md)
- Human selection candidate: [Tables/AtlasCatalogTable/Selections/atlas_selection_001.json](Tables/AtlasCatalogTable/Selections/atlas_selection_001.json), SHA-256 `c76bffb4a3fa17342275cc84d39ec6fb608dba0d9a6ba242a90f6b817e389f1f`
- Preserved setup scene: [Tables/SpriteTestTable/SpriteTest.tscn](Tables/SpriteTestTable/SpriteTest.tscn)
- User-added test scene: [SpriteTest.tscn](SpriteTest.tscn), SHA-256 `4b9ded4716e87a44eadb262f474786f3b1d5b190be73a04ece37bc0e586e6301`
- Original atlas candidate: [Assets/Possible_Artwork/colored-transparent.png](Assets/Possible_Artwork/colored-transparent.png), `832x373`, SHA-256 `532cf2ec79419cfabc6a757611737bcba43e24aed61d810aa6dda7ce69307b9b`
- Packed atlas candidate: [Assets/Possible_Artwork/colored-transparent_packed.png](Assets/Possible_Artwork/colored-transparent_packed.png), `784x352`, SHA-256 `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`
- The packed dimensions exactly support 49 columns by 22 rows of 16-by-16 cells. It is the validated intake source and proposed canonical runtime atlas, pending human catalog and consumer acceptance.
- The user-added root test scene currently references the `832x373` original atlas while setting `hframes = 49` and `vframes = 22`; that source does not divide into 16-by-16 cells and must not be treated as validated lookup behavior.
- Four validated contact sheets and a candidate-classification packet exist. No reconciled catalog, consumer-resource architecture, runtime validation, human atlas selection, or Production adoption is claimed.
- All current outputs remain retained in ArtworkRoom. No files are authorized for deletion or promotion.
