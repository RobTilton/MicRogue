# Rapid Room Generation System
Updated: 2026-09-27

This directory is the complete portable runtime package for Microgue's rapid room generator. It accepts a square top-board side length and returns detached final geometry with explicit doorway metadata:

```gdscript
var map_data: RapidRoomMapData = RapidRoomGenerator.make_map(5)
```

`size` must be at least one. A successful request returns a square map with side length `(12 × size) + 3`. Invalid input or an impossible internal doorway state fails loudly and returns null; partial map data is never returned.

`RapidRoomMapData` exposes:

- `width`, `height`, and row-major `PackedInt32Array cells`;
- detached `Array[RapidRoomDoorway] doorways`;
- `generation_usec`, `room_count`, `sealed_outward_requests`, and `eroded_wall_tiles` diagnostics;
- `FLOOR = 1`, `WALL = 2`, `cell_legend()`, `get_cell()`, and `to_ascii()`.

Each realized shared doorway retains its middle-blueprint position, final 3×3 origin, traversal axis, and selected template index. Outward doorway requests sealed by the exterior are counted but are not returned as usable doorway tags.

For reproducible tests:

```gdscript
var reproducible: RapidRoomMapData = RapidRoomGenerator.make_seeded_map(5, 42)
```

The seeded entry changes randomness ownership only; it does not enable a separate runtime-validation path. The system validates caller-owned input and trusts all intermediate data it exclusively produces. Connected top-room walks and four-sided shared-doorway authorship guarantee one cardinally connected final floor network without repair.

The package has no scene, renderer, autoload, existing Map Generation, Layout Interpretation, Doorway Placement, GridMap, or gameplay dependency. Copy the complete directory into a Godot 4 project and allow Godot to import its scripts.
