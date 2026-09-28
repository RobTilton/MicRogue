# Lightweight Generation Controller
Updated: 2026-09-28

## Rapid Shape

The lightweight controller is one script-only Godot `Node` that composes Rapid generation with Room Layout tagging. It owns no domain behavior beyond ordered calls and failure containment.

## Location And Surface

Runtime authority is [`Production/Systems/LightweightGenerationController/`](../../../Production/Systems/LightweightGenerationController/).

Inspector inputs:

- `size: int`, inspector minimum 4 and default 5;
- `archetype` dropdown: Cave, Catacomb, Nest, SubPassage.

Call:

```gdscript
var map_data: RapidRoomMapData = controller.generate_map()
```

## Ordered Behavior

1. Call `RapidRoomGenerator.make_map(size)` synchronously.
2. Return `null` if Rapid fails.
3. Pass the exact returned package and selected Archetype to `RoomLayoutTagger.tag_rooms()`.
4. Return `null` if Layout refuses.
5. Return the same mutated `RapidRoomMapData` package on success.

No explicit `await`, thread, signal, scene, or scheduler participates.

Programmatic size values below 4 remain safe because Rapid silently normalizes them to 4.

## Limits

The controller does not render, decorate, populate, persist, retry, or select gameplay content.
