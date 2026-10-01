# Sprite Atlas Curation
Updated: 2026-10-01

## What It Is

Sprite Atlas Curation is a configurable Godot workflow for selecting cells from one uniform rectangular sprite atlas, deriving a stable coordinate catalog, and editing searchable semantic metadata through append-only JSON snapshots.

Status: Proven for Godot 4.4.1 and the documented rectangular-grid contract.

## How It Works

1. Create a `SpriteAtlasCurationConfig` resource with the atlas path and hash, cell size, column and row counts, output directories, address prefix, and catalog information.
2. Assign it to `AtlasSelectionTool.tscn`. Use left-click to select, right-click to toggle `keep`/`uncertain`, middle-drag to pan, the wheel to zoom, and Space to save a numbered snapshot.
3. Resolve all retained cells to `keep` and pass the snapshot to `SpriteAtlasCatalogBuilder`. It derives stable addresses, frames, and pixel regions after validating the complete input.
4. Record the new catalog path and hash in the configuration.
5. Assign the configuration to `SemanticNamingTool.tscn`. Inspect each enlarged cell and atlas position, edit alias/category/family/tags/note/removal request, and save with Ctrl+S.

Removal requests are metadata. They do not change catalog membership without a separate reconciliation operation.

## Components

- `sprite_atlas_curation_config.gd`: owns paths, hashes, grid geometry, output directories, address prefix, and default category.
- `AtlasSelectionTool.tscn` / `atlas_selection_tool.gd`: visual selection and append-only selection snapshots.
- `sprite_atlas_catalog_builder.gd`: complete-input validation and non-overwriting catalog creation.
- `SemanticNamingTool.tscn` / `semantic_naming_tool.gd`: visual semantic editing and append-only semantic snapshots.
- `fantasy_sprite_catalog_validation_config.tres`: validation configuration for the durable example package.
- `validate_sprite_atlas_curation.gd`: non-mutating workflow validation.

The template scenes intentionally have no default configuration. The caller owns the configuration, source atlas, output directories, naming decisions, and any later catalog reconciliation.

## Data Contracts

The texture dimensions must equal `columns × cell_width` by `rows × cell_height`, and its SHA-256 must match the configuration.

Selection schema 2 stores atlas authority, grid geometry, deterministic y-then-x cells, frames, regions, and `keep`/`uncertain` state. Catalog schema 1 stores one stable entry per retained cell. Semantic contract `semantic_aliases_v1` binds records to an exact catalog path, hash, and count.

Stable addresses use `<prefix>_xXX_yYY`. Non-empty aliases must be unique and use lowercase alphanumeric underscore syntax.

Writes are append-only or refuse existing targets. Catalog and semantic finalization use validated temporary output so invalid input cannot partially replace authority. Atlas pixels are never modified.

## Validation

The validator uses `Workshop/WorkshopAssets/FantasySpriteCatalog/` as a durable fixture. It passes:

- configured source and catalog authority;
- deliberate invalid-hash refusal;
- exact 486-entry catalog derivation;
- current selection preload;
- all 486 semantic records preload;
- script and scene import under Godot 4.4.1.

Headless teardown of the UI scenes may report renderer RID cleanup warnings after the successful assertions. The validator exits successfully and performs no writes.

## Limits

- Only uniform rectangular grids are supported.
- Paths must be readable by the active Godot project.
- Human judgment owns sprite selection and meaning.
- Automatic recognition, automatic naming, irregular packing, multiple-texture catalogs, terrain topology, TileSet creation, animation grouping, and runtime adoption are outside this build.
- ToolShed storage does not authorize modification of a caller's data.
