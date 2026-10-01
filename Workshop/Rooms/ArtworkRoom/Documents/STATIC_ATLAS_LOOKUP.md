# Static Atlas Lookup
Updated: 2026-10-01
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[DurableAssetPromotionAndDocumentationNormalization]`
Implementation baseline/evidence: The relocated typed lookup passed exhaustive validation against the durable 486-entry JSON catalog and atlas.

## What It Is

The static lookup is the Godot-facing adapter inside [Fantasy Sprite Catalog](../../../WorkshopAssets/FantasySpriteCatalog/README.md). It exposes stable sprite entries and cached, clipped 16-by-16 `AtlasTexture` objects without runtime JSON parsing.

## How It Works

`FantasySpriteCatalog` lazily constructs entries from deterministic generated data. `texture_for(id)` points an `AtlasTexture` at the package atlas, applies the exact catalog region, enables clipping, caches the result, and returns the same object for later requests.

The durable package README owns the current paths, public API, hashes, validation, and limitations. Room-local generators and preview scenes are retained provenance and are not current consumer dependencies.
