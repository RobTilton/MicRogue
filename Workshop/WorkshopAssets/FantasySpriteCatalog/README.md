# Fantasy Sprite Catalog
Updated: 2026-10-01

## What It Is

Fantasy Sprite Catalog is a durable, consumer-facing artwork package containing one transparent packed atlas and a curated catalog of 486 usable 16-by-16 sprites. Every sprite has a stable coordinate address and normalized semantic metadata.

The package is Workshop-owned source material. It is ready for an approved consumer to import, but it is not currently installed in Production and does not define terrain behavior, animations, decoration rules, or map rendering.

## Structure

```text
FantasySpriteCatalog/
├── Atlas/colored-transparent_packed.png
├── Data/
│   ├── fantasy_sprite_catalog.json
│   └── semantic_aliases_001.json
├── Godot/
│   ├── fantasy_sprite_catalog.gd
│   ├── fantasy_sprite_entry.gd
│   └── Generated/fantasy_sprite_regions.gd
├── Validation/
│   ├── atlas_selection_005.json
│   └── validate_fantasy_sprite_catalog.gd
└── README.md
```

The JSON catalog is membership and geometry authority. Semantic aliases add meaning without replacing stable addresses. The generated GDScript is a deterministic Godot-facing representation of the catalog. The retained selection is validation evidence and an input fixture for the reusable ToolShed workflow.

## How It Works

The atlas is a 49-column by 22-row rectangular grid. Each cell is 16 by 16 pixels. Coordinates are zero-based.

For coordinate `(x, y)`:

```text
address = atlas_xXX_yYY
frame   = y * 49 + x
region  = [x * 16, y * 16, 16, 16]
```

Consumers may read `fantasy_sprite_catalog.json` directly or use `FantasySpriteCatalog`:

```gdscript
var texture: AtlasTexture = FantasySpriteCatalog.texture_for(&"atlas_x18_y00")
var entry: RefCounted = FantasySpriteCatalog.entry(&"atlas_x18_y00")
```

The static API provides `has`, `entry`, `texture_for`, `atlas_coords_for`, `frame_for`, `all_ids`, and `entry_count`. Textures are created lazily, clipped to their exact atlas region, and cached by stable address. Unknown required IDs return safe sentinels and report an origin-qualified error.

Semantic records use the same stable address and provide a unique alias, category, family, tags, note, and removal-request flag. Current records contain no pending removals. A consumer chooses whether it needs coordinate identity, semantic metadata, or both.

## Ownership And Mutation

- Atlas pixels are immutable unless a separately approved artwork task changes them.
- Catalog membership changes require human selection and full geometry validation.
- Aliases and metadata change through append-only semantic review before the durable current snapshot is replaced.
- Generated GDScript must agree exactly with the JSON catalog; it is not hand-edited as independent authority.
- Runtime systems may consume this package but do not mutate it.

The reusable selection and naming workflow is documented at `Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/BuildReadme.md`.

## Current Contract

- Atlas SHA-256: `801243b8b35bcfde727bd52447bcae5c2abf36b0ae2f3ac7ee54f91791575e74`
- Catalog SHA-256: `6e2d93232faebf9ea7ce5cd0623d312156ff80f8d4f3f061a2788eb1c549df71`
- Semantic metadata SHA-256: `7199e90a6247dcf72f5b646d8cb7cd6a355216787a3f1b15a8ec1ae7dabf7d52`
- Retained selection SHA-256: `f38907f88c712bbd36e46771e518c387521c49c8d7bed48b1e88b40b7bd7a690`
- Generated lookup SHA-256: `cb9d5f59f2190092d54c4ae18f92a913a329f8155d2e96eb04a404896321efbd`
- Entry count: 486
- Semantic record and alias count: 486

## Limits

This package does not determine which sprites form an autotile terrain set, which aliases are animation frames, how a generated map is rendered, or where gameplay objects are placed. Those decisions belong to concrete consumer systems. The original atlas license/provenance is not established by this package and must be resolved before distribution when applicable.
