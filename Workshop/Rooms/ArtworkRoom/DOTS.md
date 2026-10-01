# ArtworkRoom DOTS
Updated: 2026-10-01
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[DurableAssetPromotionAndDocumentationNormalization]`
Implementation baseline/evidence: The durable package under `Workshop/WorkshopAssets/FantasySpriteCatalog/` passed Godot validation after relocation; Room-local material is retained only as provenance pending explicit deletion authorization.

## Room Contract

- Room: ArtworkRoom
- Outcome: Produce a human-curated fantasy sprite catalog from the supplied uniform atlas and preserve the reusable curation workflow.
- Scope / prohibited territory: Atlas intake, human selection, semantic naming, catalog generation, exact region lookup, validation, and reusable-tool preservation. No source-pixel edits, Production adoption, map rendering, TileSet design, animation design, or gameplay placement.
- Acceptance: Durable consumers receive one validated packed atlas, 486 stable catalog entries, matching semantic metadata, and an optional typed Godot lookup. Reusable curation tooling remains independently available.
- Authority evidence: Robert approved each execution checkpoint through Alignment Check and Execute, confirmed the final catalog purpose, authorized ToolShed preservation, and authorized relocation of current assets into WorkshopAssets.
- Starting state: The Room began from an uncommitted `SpriteTest.tscn`; no user-supplied Git checkpoint was available.

## Current Traversal

- Last completed checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[DurableAssetPromotionAndDocumentationNormalization]`
- Active/interrupted checkpoint: none
- Next eligible action: no implementation work remains; the Room may be deleted only after Robert explicitly authorizes deletion of its exact path
- Human acceptance / Git checkpoint: Catalog membership and naming review are accepted; durable relocation is agent-validated; no Git checkpoint is known

## Mandatory Box List

| Checkpoint: [Room]+[Table]+[Box] | Responsibility | Depends on | Completion condition | Status | Outputs / evidence |
|---|---|---|---|---|---|
| `[ArtworkRoom]+[SpriteTestTable]+[BasicDirectorySetup]` | Establish the isolated Room and preserve its starting scene. | none | Required Room structure and starting evidence exist. | complete | Room structure and preserved scene |
| `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasIntake]` | Establish exact atlas/grid identity. | BasicDirectorySetup | Dimensions, cells, coordinates, and source hash validate. | complete | Intake evidence and contact sheets |
| `[ArtworkRoom]+[AtlasCatalogTable]+[FantasyCandidateClassification]` | Bound the relevant fantasy candidates. | AtlasIntake | Candidate review packet covers approved categories and uncertainty. | complete | `Documents/FANTASY_CANDIDATES.md` |
| `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasSelectionTool]` | Capture exact human cell selections. | FantasyCandidateClassification | Visual selection and lossless snapshots validate. | complete | Selection tool and snapshots |
| `[ArtworkRoom]+[AtlasCatalogTable]+[AtlasSelectionToolRefinement]` | Preserve keep/uncertain review states. | AtlasSelectionTool | Schema compatibility and human interaction validate. | complete | Schema-2 snapshots |
| `[ArtworkRoom]+[AtlasCatalogTable]+[HumanCatalogSelection]` | Convert accepted selection into stable catalog membership. | AtlasSelectionToolRefinement | IDs, coordinates, frames, regions, and acceptance align. | complete | Accepted catalog lineage |
| `[ArtworkRoom]+[SpriteTestTable]+[PackedAtlasReferenceFix]` | Verify exact 16-by-16 packed-atlas framing. | AtlasIntake | Godot scene loads the packed source with correct grid geometry. | complete | Preserved visual evidence |
| `[ArtworkRoom]+[AtlasCatalogTable]+[StaticAtlasLookup]` | Provide typed cached region lookup. | HumanCatalogSelection | All accepted IDs and textures validate. | complete | Durable Godot lookup package |
| `[ArtworkRoom]+[AtlasCatalogTable]+[SemanticSpriteAliases]` | Add optional human-readable metadata without replacing stable IDs. | StaticAtlasLookup | Alias format, uniqueness, snapshots, and visual editing validate. | complete | Semantic workflow |
| `[ArtworkRoom]+[AtlasCatalogTable]+[SemanticNamingPass01]` | Prove the bounded naming method. | SemanticSpriteAliases | Human review confirms the method is workable. | complete | Naming-pass evidence |
| `[ArtworkRoom]+[AtlasCatalogTable]+[SemanticNamingFullPass]` | Complete semantic review for every selected address. | SemanticNamingPass01 | Every address has one validated alias. | complete | Full-pass semantic evidence |
| `[ArtworkRoom]+[AtlasCatalogTable]+[SemanticNamingFullPass]+[RemovalRequestFlag]` | Capture removal intent without implicit deletion. | SemanticNamingFullPass | Boolean requests save and reload exactly. | complete | Removal-request evidence |
| `[ArtworkRoom]+[AtlasCatalogTable]+[RemovalReconciliationAndMetadataNormalization]` | Apply exact removal requests and normalize retained metadata. | RemovalRequestFlag | Current selection, catalog, semantics, and lookup align at 486 entries. | complete | Reconciled durable data |
| `[ArtworkRoom]+[AtlasCatalogTable]+[ToolShedPromotionAndRoomCloseout]` | Preserve the reusable workflow independently. | RemovalReconciliationAndMetadataNormalization | Configured tools and validation no longer depend on Room implementation. | complete | `Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/` |
| `[ArtworkRoom]+[AtlasCatalogTable]+[DurableAssetPromotionAndDocumentationNormalization]` | Move current consumer assets to stable ownership and remove historical weight from active documentation. | ToolShedPromotionAndRoomCloseout | Durable package and ToolShed validate without Room paths; active documents describe present contracts. | complete | `Workshop/WorkshopAssets/FantasySpriteCatalog/` |
| `[ArtworkRoom]+[AtlasCatalogTable]+[GodotConsumerResources]` | Build downstream concrete consumers. | HumanCatalogSelection | Consumer-specific integration validates. | superseded | Owned by future consumer Rooms, not ArtworkRoom |

## Current References And Disposition

- Durable package authority: [../../WorkshopAssets/FantasySpriteCatalog/README.md](../../WorkshopAssets/FantasySpriteCatalog/README.md)
- Reusable workflow authority: [../../ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/BuildReadme.md](../../ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/BuildReadme.md)
- Concise closeout state: [Documents/ARTWORK_ROOM_CURRENT_STATE.md](Documents/ARTWORK_ROOM_CURRENT_STATE.md)
- Document routing: [Documents/README.md](Documents/README.md)
- Room-local documents, snapshots, tools, and evidence are provenance only. No external current contract depends on them.
- Nothing was promoted to Production. Room deletion remains a separate destructive action requiring explicit authorization.
