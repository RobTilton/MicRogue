# Workshop Document Audit
Updated: 2026-10-02
Checkpoint: [WorkshopDocumentVerification]+[Audit]+[Reconciliation]
Implementation baseline/evidence: Git HEAD e4dd64424927abde5207b1f8fc1e8364af615bf4; clean before audit creation. Existing inputs remain unchanged.

## Rapid Shape

The audit found contradicted behavioral claims, incomplete validation coverage, stale references and unavailable original acceptance evidence. There is no blanket document pass. All 44 starting documents were read and assigned a disposition below. This report is evidence for cleanup decisions, not correction, deletion, commit or Production authority. [DOTS](DOTS.md) owns authorization and traversal.

Two claim-specific runtime checks FAILED with exit 1. Ten engine invocations completed with exit 0 and no reported Godot errors within their stated scope. One additional retained validator passed its assertions and exited 0 while reporting teardown resource-leak errors. Historical runs and human acceptance cannot be independently reconstructed from current prose alone.

## Inventory And Method

The starting inventory contains 43 Markdown documents and one Word document. Coverage includes templates, retained design source and the Sim Walk rather than silently excluding older material. No additional TXT/RST/ADOC/PDF/ODT/HTML starting documents were found. The Word main-body text was extracted, including table cells; embedded objects, comments, tracked-change meaning and visual layout are not established by that extraction.

- [Starting inventory](Evidence/document_inventory.json): exact paths, byte sizes, SHA-256 and roles.
- [Broken Markdown targets](Evidence/broken_links.json): seven occurrences checked relative to each document. Anchor IDs and external URLs are not part of this local existence check.
- [Extracted Word text](Evidence/sim_walk_extracted.txt).
- [Targeted source lines](Evidence/targeted_document_lines.txt).
- [Catalog hashes](Evidence/catalog_hashes.json): five of five match.
- [Decoration placement hashes](Evidence/decoration_hashes.json): seventeen of seventeen match.
- [Literal resource graph](Evidence/resource_graph.json): no duplicate named global classes, missing literal res paths, or literal Room dependencies in inspected Production/WorkshopAssets/ToolShed GD/TSCN/TRES inputs. Dynamic references are outside this static result.
- [Fixture inventory](Evidence/fixture_inventory.json): 86 copied input files, with original project configuration, Production, WorkshopAssets and ToolShed. Original Rooms and cache were absent. Runtime operations wrote only inside this retained fixture and evidence directory. The fixture has `.gdignore` so the enclosing working project will not register its copied global classes.
- [Closeout checks](Evidence/audit_closeout_checks.json): all 44 dispositions present, original document and source-input hashes unchanged, audit links resolve, all 12 script/scene exits terminal, failed checks and curation errors explicit. Git diff whitespace check succeeded; Git status shows only this new Room.
- [Runtime results](Evidence/runtime_results.json): exit results plus retained logs. Two audit helper scripts are retained at this Room root and copied into the fixture.

Implementation inspection followed the complete fragile Decoration description before inspecting coupled owners. It covered Rapid geometry/result ownership, Layout selection/catalog/tagging, controller composition, Decoration boundaries and profile/rendering, catalog API and curation input/write boundaries. Design intentions were checked against their source and authority relationships, not treated as implemented gameplay.

## Findings

### F01 — Rapid's documented traversal-axis guarantee is false

`Workshop/AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/RAPID_ROOM_GENERATION_SYSTEM.md:72` guarantees adjacent floor along the traversal axis. At size 4, seed 42, position `(25,28)`, footprint center `(25,28)`, `axis=0` (horizontal) and `door_item_axis=1` (vertical), neighbor `(24,28)` is WALL=2. [Claim-specific failure](Evidence/rapid_document_claims.log) exited 1.

The [audit helper](verify_rapid_document_claims.gd) first passed exact seeded size normalization for requests 1/2/3/4 at seed 42. The retained doorway validator independently passed 517322 checks across 1000 maps because it checks adjacency along `door_item_axis`, not `axis`. ResultContract's source validation also uses `door_item_axis`. Neither passing result proves the prose's other-axis guarantee. Correct wording must preserve the difference between overall doorway traversal and local straight floor span; geometry changes require separate design/implementation authority.

### F02 — Curation's complete-input claim exceeds builder validation

`Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/BuildReadme.md` describes schema-2 selection and complete input validation. `SpriteAtlasCatalogBuilder.build_payload()` validates atlas authority, per-cell order/state/coordinates/geometry but never validates `schema_version`. The unchanged retained selection with only `schema_version=999` is accepted and produces 486 entries. [Claim-specific failure](Evidence/curation_document_claims.log) exited 1; [helper](verify_curation_document_claims.gd) performs no caller-data writes.

This is a validation gap under the documented schema contract. The original validator's valid fixture and invalid-hash checks pass but do not cover unsupported schemas. Inspecting builder source also shows it does not reconcile top-level selection grid declarations; that observation was not separately runtime-tested.

### F03 — Successful curation assertions coexist with engine errors

[Retained curation run](Evidence/sprite_curation.log) exited 0 and reported passed assertions, then emitted leaked CanvasItem warnings and TextureStorage, shaped-text and font RID ERROR lines, plus ObjectDB leakage. BuildReadme already acknowledges possible RID cleanup warnings, but omits the engine ERROR diagnostics observed here. Record assertion success, exit 0 and teardown errors separately. This run does not support an error-free verdict or prove interactive editing/saving.

### F04 — Semantic snapshot temporary-file preservation is not guaranteed

`Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/BuildReadme.md` says writes are append-only or refuse existing targets. `semantic_naming_tool.gd:188–191` chooses sequence using finalized JSON existence only, then opens `<new JSON>.tmp` with FileAccess.WRITE without checking whether that temporary already exists. It can overwrite a retained failed temporary at that sequence. In contrast, `sprite_atlas_catalog_builder.gd:59` checks both final and temporary target existence. This is source-established; no existing temporary was overwritten during the audit. Concurrency and filesystem failures were not exhaustively tested.

### F05 — Three handoff-template links are broken

`MCA_ROOM_AND_DOCUMENTATION_CONTRACT.md:61`, `Templates/README.md:8` and `Documentation_Format_README.md:105` reference `ASTRA_HANDOFF_TEMPLATE.md`, which is absent. Existing `Templates/HANDOFF_TEMPLATE.md` is the apparent intended target. Core policy corrections require the explicit scope required by the Cody primer; this report makes no core edits.

### F06 — Two system-index links are broken

`AI_AGENTS_README/SHARED/AI_WORKFLOW_NOTES.md:10` and `AI_Facing_Documentation/README.md:7` reference `SYSTEMS_DESCRIPTIONS_FOR_AI/README.md`. The actual index is `_README.md`. The system documents exist; normal discovery routing points to an absent file.

### F07 — Directory/index claims are stale or incomplete

`AI_WORKFLOW_NOTES.md:12` says supplied catalogs are empty; both now contain proven entries. `ToolShed/StorageUnits/README.md:4` says empty despite DecorationPipeline. `Rooms/README.md:4` says no project Rooms despite Project_Core_Documentation at the starting baseline. `ToolShed/Completed_Tool_Builds/README.md` lists SpriteAtlasCuration but omits installed DecoratedDungeonPreview. `ToolShed/README.md` likewise describes only SpriteAtlasCuration. `Workshop/README.md:10` retains seed-template wording that ToolShed is initially empty. Existing catalogs correctly discover the durable Decoration owners.

### F08 — Decoration's current Room-disposition prose is obsolete

`VALIDATION_AND_ROOM_REMOVAL.md:8,20,53` says no deletion occurred, Room wrappers remain and the original Room remains intact. `Workshop/Rooms/DecorationPassRoom/` is absent now. ToolReadme:8 and preview BuildReadme:24 also retain current compatibility/removal wording for absent Room entry points. The old report can describe its 2026-10-01 closeout state, but needs a clear historical/current distinction before being used for current removal or handoff decisions. No conclusion about who removed it or whether removal was authorized is established by its absence.

The report's `/tmp/decoration-room-absence-f7x92bim` and `/tmp/decoration-room-absence-path.txt` are unavailable in this environment. Its recorded uncommitted-placement state is historical; audit starting HEAD is a clean committed baseline. New fixture import, five Decoration validators and both scene startup checks independently establish the scoped current composition without original Rooms.

### F09 — Retired Layout pointers have no current targets

`Trashcans/README.md:6` links both `LayoutInterpretationRoom_Retired_2026-09-26/` and `Production/Systems/LayoutInterpretationSystem/`; neither exists. Current Production has RoomLayoutSystem, but there is insufficient evidence to assert it is the exact replacement for all retired contents. Repair must identify disposition rather than invent a migration history.

### F10 — Original acceptance and historical-run provenance is unavailable

`FantasyDungeonProfile/PROFILE_REVIEW.md:4` and `VALIDATION_AND_ROOM_REMOVAL.md:37` preserve recorded 2026-10-01 human acceptance, attributed to recovered Room records. Those records are absent. The PNG remains and matches its recorded hash, which establishes file identity, not acceptance or coverage of the final layered profile. Both documents appropriately warn that the PNG predates the final interpretation. Keep acceptance as recorded but independently unverified unless exact authoritative approval evidence is recovered. No new human visual acceptance was received during this audit. Historical test logs were not supplied; new runs establish current scoped results only.

### F11 — Art timing refers to superseded turn-based combat

`Project_Core_Documentation/ArtDirectionV2.md:429` asserts turn-based combat while `Scope_Defined.md` requires real-time combat and expressly excludes older turn-based designs as authority. Do not carry its frame budget into gameplay as settled timing. ArtDirection is explicitly an R&D/prototype contract; exact visual timing needs that interpretation reconciled, not an autonomous combat redesign.

### F12 — Retained source packets have formatting defects, not automatic rewrite authority

ArtDirection starts with a four-backtick `md` fence and closes near the end with three backticks; its sword example includes a four-backtick closing marker. This can consume or prematurely close the outer code block and render the document incorrectly. Its date is a legacy **Date** field, not the common Updated header. GameDefinitionV1 has no Updated header. These source packets were not newly edited and the contract forbids touching unrelated legacy documents merely to stamp dates. Preserve source intent; normalize only under correction authority. Scope_Defined already has the common header and an explicit immutable/exact-link scope-change boundary.

### F13 — Durable core-document ownership is unclear

Project_Core_Documentation contains three design documents and two Python prototypes but no DOTS or explicit current Room contract. Its content reads as durable source/reference storage inside a location now defined as temporary execution surfaces. The audit cannot infer an active execution Room, completed Box, acceptance or removal readiness from that directory. Clarify whether this is deliberately retained reference storage or a Room with missing state, and establish a durable owner before any removal proposal. No removal is recommended by this audit.

## Evidence That Holds Within Its Scope

The controller source matches documented synchronous Rapid→Layout calls, same-package mutation, failure returns and default/exported size/archetype surfaces. Layout source matches entrance/boss selection windows and tie rules, catalog order, skipped unavailable named entries, fallback, planned-before-mutation assignment and duplicate-preserving tags. These guarantees assume valid Rapid-owned input rather than arbitrary hostile record graphs.

Rapid's source matches minimum-size normalization, panel partition limits, square dimension formula, detached mutable result, contiguous IDs, ownership channels and five doorway templates. The adjacent-floor prose defect is F01. Tests are samples and source inspection, not exhaustive proof for all sizes/seeds.

Decoration source and retained validator runs support catalog authority, detached result, artwork-neutral topology painter, current aliases, rounded 3% eligible-floor coverage, door priority and separate base/sticker rendering. Base renderer's Earth/Abyss colors and 16×16 layer/source-ID conventions match. The controller contains no Decoration integration. The literal graph and runtime fixture support tested independence from original Rooms.

Catalog's five SHA-256 values match, and its validator passed 486-entry semantics/geometry/generated lookup/cached-texture checks. All seventeen recorded Decoration implementation/image hashes match. Hash agreement does not establish visual taste, historical acceptance, license provenance or engine-error absence.

Scope_Defined preserves the required/unresolved/possible-future distinctions in GameDefinitionV1, including real-time combat, persistence, knowledge, no crafting/durability/power meta progression, and intentionally unresolved mechanics. The Sim Walk explicitly distinguishes discoveries from scope and defines a first-playable slice; that slice is not a contradiction of completed-game scope. Its proposed generator API is a target, not an implemented current API.

ArtDirection's narrow Godot particle capability claim is supported by the official Godot 4.4 [ParticleProcessMaterial](https://docs.godotengine.org/en/4.4/classes/class_particleprocessmaterial.html) and [GPUParticles2D](https://docs.godotengine.org/en/4.4/classes/class_gpuparticles2d.html) references: process-material configuration exposes direction/spread, point emission, initial/angular velocity, tangential acceleration, lifetime randomness and color. This does not validate the proposed art grammar or visual prototype.

## Actual Runtime Results

Engine: `4.4.1.stable.official.49a5bc7b6`, installed Windows console executable. Sandboxed WSL interop failed with a socket error before execution; the approved escalation succeeded. Test commands used `--headless --path <isolated fixture> --log-file <individual log>`, plus the invocation below. Fixture import used `--import`, completed its scan/import and exited 0; no early-aborted scan was treated as completed import.

| Invocation | Exit | Actual result / evidence |
|---|---:|---|
| `--import` | 0 | Completed import; no reported errors. [Log](Evidence/import.log) |
| CatalogAdapter `--script .../validate_decoration_catalog_adapter.gd` | 0 | Retained authority/query assertions passed. [Log](Evidence/catalog_adapter.log) |
| ResultContract `--script .../validate_decorated_map_data.gd` | 0 | Coverage/refusal/detachment/non-mutation assertions passed for fixture cases. [Log](Evidence/result_contract.log) |
| BaseCellPainter `--script .../validate_base_cell_painter.gd` | 0 | Four archetypes, sizes 4/5; deterministic coverage/non-mutation. [Log](Evidence/base_painter.log) |
| FantasyDungeonProfile `--script .../validate_fantasy_dungeon_profile.gd` | 0 | Mapped aliases, four archetypes, sizes 4/5, deterministic and exact floor counts. [Log](Evidence/fantasy_profile.log) |
| TileMapLayerAdapter `--script .../validate_tile_map_layer_adapter.gd` | 0 | Four archetypes, sizes 4/5; base count and sticker coordinates. [Log](Evidence/renderer.log) |
| Catalog `--script .../validate_fantasy_sprite_catalog.gd` | 0 | 486 entries, semantics, generated lookup, atlas and cache. [Log](Evidence/sprite_catalog.log) |
| Curation `--script .../validate_sprite_atlas_curation.gd` | 0 | Assertions passed; teardown ERROR/WARNING diagnostics. [Log](Evidence/sprite_curation.log) |
| `--script .../test_rapid_doorway_placement.gd` | 0 | 517322 checks / 1000 maps, local door-item-axis adjacency and visualization. [Log](Evidence/rapid_doors.log) |
| Decorated preview scene `--quit-after 3` | 0 | Default headless startup, no reported errors. [Log](Evidence/decorated_startup.log) |
| Rapid visualization scene `--quit-after 3` | 0 | Default headless startup, no reported errors. [Log](Evidence/visualization_startup.log) |
| `--script res://verify_rapid_document_claims.gd` | 1 | Normalization subcheck passed; traversal-axis guarantee FAILED. [Log](Evidence/rapid_document_claims.log) |
| `--script res://verify_curation_document_claims.gd` | 1 | Unsupported selection schema refusal FAILED. [Log](Evidence/curation_document_claims.log) |

Exact retained script paths are in runtime_results.json and the fixture inventory. Coverage is limited to inspected assertions and actual invocations; exit 0 is never substituted for reading errors. Interactive editing, saving, camera/UI operation, all malformed inputs, all seeds, subjective visuals and original approval history are not proven by these runs.

## Per-Document Disposition

Paths below are relative to Workshop. Every entry was read. “No discrepancy found” means the described inspection found none within its scope, not a universal proof or human acceptance.

| Document | Role and disposition |
|---|---|
| `AI_AGENTS_README/CHAD_ONLY/AI_WORKFLOW_CONTEXT_PRIMER.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `AI_AGENTS_README/Codex_Only/CODEX_WORKFLOW_CONTEXT_PRIMER.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `AI_AGENTS_README/README.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `AI_AGENTS_README/SHARED/.AGENTS.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `AI_AGENTS_README/SHARED/AI_WORKFLOW_NOTES.md` | Current reference index; F06/F07. |
| `AI_AGENTS_README/SHARED/MCA_ROOM_AND_DOCUMENTATION_CONTRACT.md` | Current policy; F05. Explicit core-write boundary preserved. |
| `AI_AGENTS_README/SHARED/Templates/CURRENT_STATE_TEMPLATE.md` | Blank template; placeholders grant no authority; no discrepancy found in template purpose. |
| `AI_AGENTS_README/SHARED/Templates/DOTS_TEMPLATE.md` | Blank template; placeholders grant no authority; no discrepancy found in template purpose. |
| `AI_AGENTS_README/SHARED/Templates/HANDOFF_TEMPLATE.md` | Blank template; placeholders grant no authority; no discrepancy found in template purpose. |
| `AI_AGENTS_README/SHARED/Templates/README.md` | Template index; F05. |
| `AI_AGENTS_README/SHARED/Workflow_References/when_working_with_documented_systems.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `AI_AGENTS_README/SHARED/Workflow_References/when_working_with_fragile_system_documentation.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `AI_Facing_Documentation/MCA_PROTOCOL_REF_FOR_AI/MCA_PROTOCOL_REFERENCE.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `AI_Facing_Documentation/README.md` | Current index; F06. |
| `AI_Facing_Documentation/SHADER_LIBRARY_FOR_AI/README.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/FRAGILE_DECORATION_PIPELINE.md` | Current coupled-system summary; ownership/source flow matches inspected code and validator scope; recorded acceptance not inferred. |
| `AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/LIGHTWEIGHT_GENERATION_CONTROLLER.md` | Current runtime summary; source matches synchronous calls, exports, returns and boundaries. |
| `AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/RAPID_ROOM_GENERATION_SYSTEM.md` | Current runtime summary; F01; other inspected contracts supported with stated limits. |
| `AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/ROOM_LAYOUT_SYSTEM.md` | Current runtime summary; source matches selection/tagging flow under valid Rapid input; broad malformed-input guarantee not inferred. |
| `AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/_README.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `Documentation_Format_README.md` | Current format reference; F05. |
| `README.md` | Current index; F07 seed-template wording. |
| `Rooms/Project_Core_Documentation/ArtDirectionV2.md` | Retained R&D source; F11/F12/F13. Visual rules unvalidated; particle API supported. |
| `Rooms/Project_Core_Documentation/GameDefinitionV1.md` | Retained scope source; F12/F13; scope conversion agrees within reviewed requirements. |
| `Rooms/Project_Core_Documentation/Scope_Defined.md` | Immutable scope authority; no scope-conversion discrepancy found; F13 location/owner only. Human acceptance provenance not independently established. |
| `Rooms/README.md` | Current index; F07. |
| `SimWalkDocuments/Micro_Rogue_Sim_Walk_2026-09-25.docx` | Experience/design capture; proposals and first-playable boundary distinguished; no scope contradiction found. Original scope-lock approval not independently recovered; extraction limits apply. |
| `ToolShed/Completed_Tool_Builds/DecoratedDungeonPreview/BuildReadme.md` | Reusable preview contract; F08/F10 evidence dependency; default startup verified. |
| `ToolShed/Completed_Tool_Builds/DecoratedDungeonPreview/VALIDATION_AND_ROOM_REMOVAL.md` | Historical placement evidence used for current recovery; F08/F10. Seventeen hashes match; new scoped runtime evidence supplied. |
| `ToolShed/Completed_Tool_Builds/README.md` | Current index; F07. |
| `ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/BuildReadme.md` | Reusable build contract; F02/F03/F04. Valid fixture assertions passed; interactive save behavior not established. |
| `ToolShed/Ledger/Completed_Tool_Builds_Catalog.md` | Discovery catalog; targets exist. Proven status is bounded by build evidence: SpriteAtlasCuration has F02/F03/F04 and preview has F08/F10. |
| `ToolShed/Ledger/ToolShed_Format.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `ToolShed/Ledger/ToolShed_Parts_Catalog.md` | Discovery catalog; owner exists; runtime scope supported, original acceptance not re-established. |
| `ToolShed/README.md` | Current index; F07 incomplete installed-tool description. |
| `ToolShed/StorageUnits/DecorationPipeline/FantasyDungeonProfile/PROFILE_REVIEW.md` | Recorded review/acceptance; F10; image hash retained, historical limits stated accurately. |
| `ToolShed/StorageUnits/DecorationPipeline/ToolReadme.md` | Reusable component contract; F08/F10; five retained validators passed within documented cases. |
| `ToolShed/StorageUnits/README.md` | Current index; F07. |
| `Trashcans/README.md` | Retired-material index; F09. |
| `WorkshopAssets/FantasySpriteCatalog/README.md` | Current data/API contract; five hashes and 486-entry validator passed. License provenance explicitly unresolved. |
| `WorkshopAssets/README.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `_Audits/Archive_Of_Last_Resort/README.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `_Audits/Current_Audits/README.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |
| `_Audits/README.md` | Current policy/index/reference; local targets and stated role checked; no discrepancy found within this review. |

## Remaining Limits And Output Disposition

All outputs are retained in this Room: DOTS, this report, two claim-specific helpers, inventory/hash/resource/test evidence, extracted Word text and the ignored runtime fixture/cache. No existing document, Production file, asset, commit or deletion was changed. Completion of the audit means coverage and honest dispositions are recorded, not that findings have been corrected or gameplay has been accepted.

Cleanup can repair exact discovery/index targets and stale statements, clarify historical evidence and durable reference ownership, and reconcile documented contracts with the failed checks. Existing-document edits and implementation fixes need an expanded, explicit write boundary; changing the immutable scope requires its exact-file rule. Do not remove or relocate historical evidence merely to make current claims appear supported.
