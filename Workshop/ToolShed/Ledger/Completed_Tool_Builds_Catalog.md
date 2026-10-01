# Completed Tool Builds Catalog
Updated: 2026-10-01

Name: Sprite Atlas Curation
Status: Proven
Kind: Completed Tool Build
BuildUnit: `Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/`
Authority: [BuildReadme](../Completed_Tool_Builds/SpriteAtlasCuration/BuildReadme.md)
Keywords: sprite atlas, spritesheet, selection, catalog, semantic naming, aliases, coordinates, Godot, visual review
Summary: Configurable Godot workflow for visually selecting uniform-grid atlas cells, deriving a stable catalog, and maintaining append-only semantic metadata.
UseWhen: A project needs human-controlled curation and naming of cells from one rectangular sprite atlas with exact provenance.
DoNotUseWhen: Packing is irregular, multiple textures form one catalog, automated image recognition is required, or execution authority has not been established.
KeyRules: Configure exact paths, hashes, grid, and output directories; resolve uncertainty before catalog generation; preserve numbered snapshots; removal flags do not delete membership; human judgment owns selection and meaning.

Name: Decorated Dungeon Preview
Status: Proven
Kind: Completed Tool Build
BuildUnit: `Workshop/ToolShed/Completed_Tool_Builds/DecoratedDungeonPreview/`
Authority: [BuildReadme](../Completed_Tool_Builds/DecoratedDungeonPreview/BuildReadme.md)
Keywords: dungeon, Rapid, Layout, Decoration, preview, F6, Godot, TileMapLayer
Summary: Runnable seeded preview composing Rapid, Layout and modular Decoration into separate base/sticker layers.
UseWhen: Reviewing the durable Workshop Decoration pipeline across archetypes, sizes and seeds.
DoNotUseWhen: Production controller adoption, population or persistence is required.
KeyRules: Domain owners remain separate; caller controls size/archetype/seed; failed stages stop dependent work; no temporary Room dependency.
