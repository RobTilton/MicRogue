# Rapid Room Generation System
Updated: 2026-09-27

This directory is the complete portable runtime package for Microgue's rapid room generator. It accepts one square layer-one board side length and returns exactly the mutable layer-three map, generated room records, explicit room count, and realized doorway placements needed downstream:

```gdscript
var map_data: RapidRoomMapData = RapidRoomGenerator.make_map(5)
```

`size` must be at least one. Invalid input or an impossible internal doorway state fails loudly and returns `null`; partial data is never returned.

`RapidRoomMapData` exposes:

- mutable row-major `PackedInt32Array cells` using `FLOOR = 1` and `WALL = 2`;
- detached `Array[RapidRoom] rooms`;
- explicit `room_count`, equal to `rooms.size()`;
- detached `Array[RapidRoomDoorway] doorways`.

Each `RapidRoom` contains its stable contiguous `id` and `panel_count`. Panel count is the number of layer-one board panels assigned by that room's self-avoiding walk and is always one through four. Room panel counts sum to `size × size`.

Each `RapidRoomDoorway` contains `position`, the center coordinate of its final layer-three 3×3 doorway footprint, and `axis`, its horizontal or vertical traversal orientation. Exterior requests are sealed internally and are not returned as usable doorways.

The returned package deliberately excludes dimensions and generator diagnostics. The final map is square; its internal side length is `(12 × size) + 3`. Door template choice, wall-edge erosion accounting, sealed exterior requests, and elapsed generation time remain implementation details.

For reproducible tests:

```gdscript
var reproducible: RapidRoomMapData = RapidRoomGenerator.make_seeded_map(5, 42)
```

The seeded entry changes randomness ownership only. The system validates caller-owned input and trusts all intermediate data it exclusively produces. Connected room walks and four-sided shared-doorway authorship guarantee one cardinally connected final floor network without repair.

The package has no scene, renderer, autoload, controller, tagging, visualization, or gameplay dependency. Copy the complete directory into a Godot 4 project and allow Godot to import its scripts.
