# ArtworkRoom Static Atlas Lookup
Updated: 2026-09-30
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[StaticAtlasLookup]`
Implementation baseline/evidence: Regenerated from accepted 499-entry catalog SHA-256 `438b01aebe34ed75e5720a70eb129adb0c48273f31eb4cb42ad965a6f12597f2`; exhaustive Godot 4.4.1 validation passed, while Rob's prior six-sprite F6 preview remains the visual geometry evidence.

## Rapid Shape

The static lookup turns each accepted coordinate ID into a typed Godot entry and cached 16-by-16 `AtlasTexture`. It follows the project's lightweight static `RefCounted` catalog pattern, requires no autoload, and performs no runtime JSON parsing. The accepted JSON remains human-selection authority; deterministic generated GDScript is the Godot runtime lookup input.

## Current Locations And Structure

- Accepted source: [`../Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json`](../Tables/AtlasCatalogTable/Catalog/fantasy_sprite_catalog.json)
- Generator: [`../Tables/AtlasCatalogTable/Tools/generate_static_atlas_lookup.gd`](../Tables/AtlasCatalogTable/Tools/generate_static_atlas_lookup.gd)
- Entry type: [`../Tables/AtlasCatalogTable/GodotConsumers/fantasy_sprite_entry.gd`](../Tables/AtlasCatalogTable/GodotConsumers/fantasy_sprite_entry.gd)
- Catalog API: [`../Tables/AtlasCatalogTable/GodotConsumers/fantasy_sprite_catalog.gd`](../Tables/AtlasCatalogTable/GodotConsumers/fantasy_sprite_catalog.gd)
- Generated regions: [`../Tables/AtlasCatalogTable/GodotConsumers/Generated/fantasy_sprite_regions.gd`](../Tables/AtlasCatalogTable/GodotConsumers/Generated/fantasy_sprite_regions.gd)
- Exhaustive validator: [`../Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_static_atlas_lookup.gd`](../Tables/AtlasCatalogTable/GodotConsumers/Tests/validate_static_atlas_lookup.gd)
- F6 preview: [`../Tables/AtlasCatalogTable/GodotConsumers/StaticAtlasLookupPreview.tscn`](../Tables/AtlasCatalogTable/GodotConsumers/StaticAtlasLookupPreview.tscn)

## Entry Points And Flow

1. The generator validates the accepted catalog hash, packed-atlas hash, metadata, exact count, stable IDs, unique coordinates, sorting, frames, regions, and broad category.
2. It emits deterministic `Generated/fantasy_sprite_regions.gd`. An identical existing file is accepted without mutation; a differing existing output is refused rather than overwritten.
3. `FantasySpriteCatalog` lazily constructs `FantasySpriteEntry` objects from generated data.
4. `texture_for(id)` creates one clipped `AtlasTexture` for an accepted ID, caches it, and returns the same object on repeated lookup.
5. Consumers use the static API directly; no autoload or JSON parsing is required.

Public API:

```gdscript
FantasySpriteCatalog.has(id)
FantasySpriteCatalog.entry(id)
FantasySpriteCatalog.texture_for(id)
FantasySpriteCatalog.atlas_coords_for(id)
FantasySpriteCatalog.frame_for(id)
FantasySpriteCatalog.all_ids()
FantasySpriteCatalog.entry_count()
```

Example:

```gdscript
var texture := FantasySpriteCatalog.texture_for(&"atlas_x32_y04")
$Sprite2D.texture = texture
```

## Component Contracts

- The sole texture source is `colored-transparent_packed.png`, SHA-256 `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`.
- The grid is 49 columns by 22 rows with 16-by-16 cells.
- Exactly 499 accepted IDs exist. Coordinate ID, frame, and region contracts remain `atlas_xXX_yYY`, `y * 49 + x`, and `[x * 16, y * 16, 16, 16]`.
- Every returned `AtlasTexture` has a 16-by-16 region, references the packed atlas, and enables `filter_clip`.
- Texture instances are cached by stable ID.
- `has()` returns false for an unknown ID. APIs requiring an entry report an origin-qualified error and return a safe sentinel (`null`, `-1`, or `Vector2i(-1, -1)`).
- Generated output is not hand-edited and records its owning generator and source catalog hash.

## Validation And Current Limits

- The current generation contains exactly 499 entries; a rerun confirmed byte-identical deterministic output.
- Generated GDScript SHA-256 is `ddd9e68c6e530aa72b0851428747c798af8e59acc5cccd554f0b090f8304ee36`.
- The exhaustive Godot validator compared every generated entry to the accepted JSON and passed IDs, ordering, categories, coordinates, frames, regions, texture size, atlas ownership, `filter_clip`, caching, and unknown-ID refusal.
- The actual preview scene started through Godot without parse or runtime errors.
- The atlas, all four selection snapshots, and preserved Table scene remain intact. No temporary generator output remains.
- Rob confirmed that all six titled preview sprites were visually clear and showed no neighboring-cell bleed. The titles intentionally display stable coordinate IDs; semantic aliases remain outside this Box.
- Semantic alias tooling is owned by its separate checkpoint. Runtime alias lookup, TileSet composition, animations, Production integration, and runtime adoption remain outside this Box.
