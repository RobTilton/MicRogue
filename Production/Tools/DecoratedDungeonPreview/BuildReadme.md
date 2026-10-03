# Decorated Dungeon Preview
Updated: 2026-10-03

## Purpose And Status

Status: Proven within the documented Godot 4.4.1 validation scope. This durable Godot scene composes Production Rapid and Layout with the [Decoration components](../../Systems/DecorationPipeline/ToolReadme.md), displaying earth/abyss base geometry and catalog-backed stickers through two TileMapLayers.

## Entry Point And Workflow

Open [decoration_generation_preview.tscn](decoration_generation_preview.tscn) and press F6. Its [script](decoration_generation_preview.gd) generates with a valid default seed, tags the selected archetype, creates the catalog adapter, decorates a detached result, and renders base and sticker layers. Failure stops dependent work and appears in the status label and origin-qualified error.

Controls choose Cave, Catacomb, Nest or SubPassage, size and seed; Regenerate reruns the composition. Middle-drag pans and the wheel zooms. The camera initially fits the generated map. No project main scene or Production controller change is required.

## Inputs, Outputs And Ownership

Rapid owns physical cells and doorway orientation. Layout owns room types, ordered weighted tags and safe-floor ownership. Decoration's painter owns logical topology; the fantasy profile owns alias choices and sticker selection; its result owns detached output; the renderer owns layer mutation. The preview only orchestrates these calls and controls the camera/UI.

Required data is the durable FantasySpriteCatalog package under `Production/Assets/`; exact hashes and membership are verified by the catalog adapter. Output is in-memory layers and status text. This scene writes no map or asset files.

## Validation And Limits

Historical scope: [validation and Room removal report](VALIDATION_AND_ROOM_REMOVAL.md) for executed checks, preserved acceptance and exact removal disposition. The report remains outside the temporary Room. The profile review image is also retained in the component unit.

This preview does not adopt Decoration into the Production controller or add population, persistence, collisions, navigation or lighting. Its durable files have no dependency on DecorationPassRoom. No temporary Room implementation is required.

Current adoption checks: [recovery validation](../../../Workshop/_Audits/Current_Audits/System_Realignment/RelocationValidation.md). Human visual and interaction verification was received on 2026-10-03.
