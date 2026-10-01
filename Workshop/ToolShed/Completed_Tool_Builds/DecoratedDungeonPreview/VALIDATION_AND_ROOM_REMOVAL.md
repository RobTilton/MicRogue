# Decoration Validation And Room Removal Safety
Updated: 2026-10-01
Checkpoint: [DecorationPassRoom]+[DecorationPassTable]+[DurablePlacementAndRemovalSafety]
Implementation baseline/evidence: Uncommitted durable Workshop components and preview validated with Godot 4.4.1 on 2026-10-01; exact inventory below. Latest recorded human Git checkpoint is `3501aa2351ece4a3e2e24fcb6761f0e348082d51`, not a checkpoint of this placement.

## Result And Authority

DecorationPassRoom's required outputs have durable owners outside the temporary Room. Removal of the exact directory `Workshop/Rooms/DecorationPassRoom/` is safe for the inspected source/resource dependency graph and the composition directly tested with that Room absent. No deletion has occurred; Robert must separately authorize that exact path. No Git commit, reset or Production adoption was performed.

Robert explicitly confirmed that the existing WorkshopAssets and Production work was authorized. He then confirmed the bounded Alignment Check and issued Execute for durable Workshop placement, references, documentation and validation. Rooms are temporary execution surfaces; project composition and modularity are mandatory. Accepted MCA core additions were preserved; future Cody-initiated workflow changes are confined to the Cody primer unless core writes are requested.

## Durable Disposition

- [Decoration component unit](../../StorageUnits/DecorationPipeline/ToolReadme.md): catalog adaptation, detached result, artwork-neutral painter, fantasy profile, renderer and all five validators.
- [Composed preview](BuildReadme.md): scene, orchestration script, usage and this evidence report.
- [Profile review](../../StorageUnits/DecorationPipeline/FantasyDungeonProfile/PROFILE_REVIEW.md): preserved recorded human acceptance and review artifact. The PNG is byte-identical to the retained Room image; it is a historical review artifact, not the current alias inventory.
- [System description](../../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/FRAGILE_DECORATION_PIPELINE.md): current ownership, interfaces, dependencies and coupling invariants.
- ToolShed parts/build catalogs and system-description index discover these durable owners.

Room scripts remain compatibility wrappers extending durable scripts. The retained Room scene points to the durable preview script. Old script UIDs remain with those wrappers; durable scripts have their own Godot-generated UIDs. Named global classes have one owner in durable storage. Removal retires the old Room entry points; use the durable preview scene for F6.

## Executed Validation

Godot version: `4.4.1.stable.official.49a5bc7b6`. The installed Windows console executable ran through WSL outside the sandbox after sandbox interop failed with a socket error. This was an environment failure, not a project parse failure.

Commands use `--headless --path <project>`. All following checks exited 0 without Godot errors:

| Check | Invocation / verified scope |
|---|---|
| Editor import | `--editor --quit`: durable assets and global classes register without parse or duplicate-class errors. |
| Catalog adapter | `--script res://Workshop/ToolShed/StorageUnits/DecorationPipeline/CatalogAdapter/validate_decoration_catalog_adapter.gd`: exact authority, aliases, family, category, tags, ordering and unique-result checks. |
| Result contract | `--script res://Workshop/ToolShed/StorageUnits/DecorationPipeline/ResultContract/validate_decorated_map_data.gd`: complete coverage, invalid refusal, detached context and source non-mutation. |
| Base painter | `--script res://Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/validate_base_cell_painter.gd`: all four archetypes at sizes 4 and 5, exact deterministic coverage and non-mutation. |
| Fantasy profile | `--script res://Workshop/ToolShed/StorageUnits/DecorationPipeline/FantasyDungeonProfile/validate_fantasy_dungeon_profile.gd`: current aliases, deterministic coverage, mandatory wall/door stickers and rounded 3% eligible-floor count across all four archetypes and sizes 4/5. The validator no longer writes the review image. |
| Renderer | `--script res://Workshop/ToolShed/StorageUnits/DecorationPipeline/TileMapLayerAdapter/validate_tile_map_layer_adapter.gd`: complete base and sparse sticker rendering across all four archetypes and sizes 4/5. |
| Durable Decoration startup | `res://Workshop/ToolShed/Completed_Tool_Builds/DecoratedDungeonPreview/decoration_generation_preview.tscn --quit-after 3`: direct scene startup and default composition. |
| Rapid visualization startup | `res://Workshop/WorkshopAssets/VisualizationTool.tscn --quit-after 3`: established independent visualization remains runnable. |

Static inspection of project source/resource documents outside generated caches found no executable/resource reference into DecorationPassRoom from outside that Room. Durable resource paths resolve; all global script classes have unique owners. Local Markdown links and diff whitespace are checked at closeout.

## Preserved Acceptance And Limits

The recovered DOTS/current-state records report Robert's 2026-10-01 acceptance of the final erosion-free layered preview: earthy floor base, abyss wall base, white stone wall stickers, doors and sparse grass/bone floor stickers. That human acceptance is preserved as recorded evidence; no new visual acceptance is claimed. Relocation preserves runtime algorithms and atlas data; automated checks establish composition and startup, not subjective visual judgment.

Production Rapid and WorkshopAssets changes remain at their existing authorized paths. The Production controller still invokes only Rapid and Layout. Workshop placement does not authorize new controller integration. The existing uncommitted work remains uncommitted for Robert's checkpoint decision.

## Direct Room-Absence Test

On 2026-10-01 an isolated project copy was created at `/tmp/decoration-room-absence-f7x92bim`. It contains the unchanged project configuration/icon, all Production files, WorkshopAssets and ToolShed. No `Workshop/Rooms/` directory exists in that copy. A source inventory confirmed that these locations cover all executable Godot source/resources outside DecorationPassRoom in the working project. The copy began without `.godot` cache, so it could not obtain Room classes from the original project cache.

A preliminary `--editor --quit` run exited 0 but reported `Scan thread aborted`; it did not establish completed import. The follow-up `--import` completed registration/import from scratch with exit 0 and no errors. All five durable validators and both visualization scene startup commands listed above then ran against the isolated copy, each exiting 0 with no errors. Painter/profile/renderer again covered every archetype at sizes 4 and 5.

This directly establishes that tested runtime composition and startup do not depend on the Room. It does not claim an exhaustive test of every possible interactive behavior. The original Room remains intact. Its obsolete entry points will cease to exist upon deletion; durable replacements are documented and tested. The temporary test copy and `/tmp/decoration-room-absence-path.txt` are retained under the preservation rule, not automatically deleted. Generated editor/cache state in the working project may need its ordinary rescan after later authorized removal.

## Durable Inventory

The following SHA-256 values identify the durable implementation and retained PNG at placement closeout. Documentation and generated import/UID metadata are excluded.

| Durable file (relative to project root) | SHA-256 |
|---|---|
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/base_cell_painter.gd` | `d34d841e6667d60098436f32c8503830fe1748b8df533ece7b71678ceb2013d8` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/decoration_cell_context.gd` | `74a58384b0c211bb6790fd8249c6b7ab9da427de26b6b2bb26249d1891f48c1d` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/decoration_paint_plan.gd` | `e5fd9e3189d33bdae45d3ce568aa285619fc945b74458cb4c93a5cdb9ea37330` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/BaseCellPainter/validate_base_cell_painter.gd` | `ca8454b575d6c9b8866da6ff3d638e8c2cc3892a67950901606ad9eb75f6adbf` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/CatalogAdapter/decoration_catalog_adapter.gd` | `11594be5adcdbb4cb199b0487345eb1967a6f9cba71ea8097c2cbdc55a726abc` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/CatalogAdapter/decoration_sprite_query.gd` | `49370fbe5602e66cc4bd5aa9a307e38df2262c21ef4d75c099e4b255c108393a` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/CatalogAdapter/decoration_sprite_record.gd` | `46f462e42471eaf21df8f5f27c9aa5ec88dc8e107c7183090fdc2eaedfec7258` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/CatalogAdapter/validate_decoration_catalog_adapter.gd` | `bd743b76833a504938e848c5992620e7cdacea29a5a74d1b353a202d49e0a215` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/FantasyDungeonProfile/fantasy_dungeon_profile.gd` | `5d70ffeb3b139c9fa44ba3c0f11872a9cacb148656f26c392adb736ebaaa1e5a` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/FantasyDungeonProfile/profile_review.png` | `0a9251bfe5f579764324cb2caeaf1022c98d21dae41b6db8acaf3b6baee7fa8c` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/FantasyDungeonProfile/validate_fantasy_dungeon_profile.gd` | `98897c15c177c3e0fac4dd668717a5e0e3ab3e1452a7a1c3a2cd97083e00fb0e` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/ResultContract/decorated_map_data.gd` | `117c5829d4226f7f3acb00c6ae648652d7d05357af55318b80a212c6f073d57d` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/ResultContract/validate_decorated_map_data.gd` | `9f7359c3087e36b8ace2fb90c569c60dbbfeb6ff941cf64b3fc62cdf65f07ce1` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/TileMapLayerAdapter/decoration_tile_map_layer_adapter.gd` | `1a7753e430f7448c9e8d0ff589e454d244aed909f4a3878c6afb501f752c3f3b` |
| `Workshop/ToolShed/StorageUnits/DecorationPipeline/TileMapLayerAdapter/validate_tile_map_layer_adapter.gd` | `f7559c438144b104091b5b4cc86b6c74c51fae159f9f0065c9be282814b9d7f7` |
| `Workshop/ToolShed/Completed_Tool_Builds/DecoratedDungeonPreview/decoration_generation_preview.gd` | `6d62463a58828d230560e889d2e3a31cb3a71ed146832b9c550dbe658962540f` |
| `Workshop/ToolShed/Completed_Tool_Builds/DecoratedDungeonPreview/decoration_generation_preview.tscn` | `82df1318b5b5dad49254ae097c019a4c0d8d53636270f48508db9a3ffd10a7d2` |
