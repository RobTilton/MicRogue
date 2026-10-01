# ArtworkRoom Current State
Updated: 2026-10-01
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[DurableAssetPromotionAndDocumentationNormalization]`
Implementation baseline/evidence: Godot 4.4.1 validated the durable WorkshopAssets package and the ToolShed workflow against 486 catalog entries after relocation.

## Rapid Shape

ArtworkRoom is complete. It produced a curated fantasy sprite library and a reusable atlas-curation workflow. Current consumers use the durable package under `Workshop/WorkshopAssets/FantasySpriteCatalog/`; they do not use Room paths.

The Room now contains provenance only: review snapshots, development tools, visual evidence, and detailed completion records. It owns no active runtime or Workshop asset contract and may be deleted after explicit authorization.

## Current Owners

- Sprite library: `Workshop/WorkshopAssets/FantasySpriteCatalog/`
- Reusable selection and naming workflow: `Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/`
- Production: no adoption exists
- Downstream rendering, TileSets, animation, decoration, and population: unassigned future consumer Rooms

## What The Durable Package Provides

- One transparent `784×352` atlas arranged as 49 columns by 22 rows of 16-by-16 cells.
- Exactly 486 accepted coordinate IDs and pixel regions.
- Exactly 486 unique semantic aliases with category, family, tags, and notes.
- A typed static Godot API that returns entries and cached clipped `AtlasTexture` instances.
- A retained accepted-selection fixture and an exhaustive package validator.

The package README owns exact paths, APIs, hashes, mutation rules, and limitations.

## Validation And Limits

- The package validator passed catalog geometry, semantic alignment, generated lookup equality, atlas regions, and cached API textures.
- The ToolShed validator passed configured authority, invalid-hash refusal, catalog derivation, selection preload, and semantic preload using only WorkshopAssets.
- A workspace search found no current dependency outside ArtworkRoom that still requires an ArtworkRoom path.
- No source pixels changed and nothing entered Production.
- Room deletion has not occurred and is not authorized by this document.
