# Completed Tool Builds Catalog
Updated: 2026-10-03

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

Name: Rapid Generation Inspection
Status: Proven
Kind: Scene Utility
BuildUnit: `Workshop/ToolShed/Completed_Tool_Builds/RapidGenerationInspection/`
Authority: [BuildReadme](../Completed_Tool_Builds/RapidGenerationInspection/BuildReadme.md)
Keywords: Rapid, Layout, doorway, GridMap, visualization, benchmark
Summary: Inspect seeded map geometry and measure generation performance.
UseWhen: Reviewing Rapid/Layout output or checking doorway placement.
DoNotUseWhen: Gameplay orchestration or new geometry mechanics are required.
KeyRules: Reads generated maps; headless checks establish geometry/startup, not human visual acceptance.
