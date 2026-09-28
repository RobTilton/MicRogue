# Lightweight Generation Controller
Updated: 2026-09-28

`LightweightGenerationController` is a script-only orchestration node. It exposes:

- integer `size`, inspector minimum 4 and default 5;
- an Archetype dropdown with Cave, Catacomb, Nest, and SubPassage.

Call:

```gdscript
var map_data: RapidRoomMapData = controller.generate_map()
```

The call requests a map synchronously from Rapid, refuses when Rapid returns `null`, passes the exact package to `RoomLayoutTagger`, and returns that same mutated package. Layout failure also returns `null`; a mandatory Layout failure does not partially tag the package.

Programmatic values below 4 are accepted and silently normalized to 4 by Rapid.

The controller owns no generation, catalog, tagging, rendering, decoration, population, threading, or scheduling behavior.
