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

The following is a schema example, not an additional installed capability or validation claim.

```text
Name: <stable name>
Status: <Proven | Experimental | Archived>
Kind: <Completed Tool Build>
BuildUnit: <current directory>
Authority: <current README/contract>
Keywords: <search terms>
Summary: <capability>
UseWhen: <appropriate conditions>
DoNotUseWhen: <unsupported conditions>
KeyRules: <invariants and limits>
```
