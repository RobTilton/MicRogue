# Fantasy Dungeon Profile Review
Updated: 2026-10-01

Status: Recorded human acceptance by Robert on 2026-10-01, preserved from DecorationPassRoom.

Map north is negative Y and east is positive X. Cardinal bits are N, E, S, W; diagonal bits are NW, NE, SE, SW. The `floor_stone_a` aliases decorate physical walls, using center, outer edges, outer corners, and inner corners according to topology. Physical floors receive grass or bone stickers on `round(eligible_floor_count × 0.03)` cells, deterministically chosen outside sacred doorway footprints. Realized door positions receive door variant 003 or 004. The base renderer supplies earth under floors and abyss under walls.

[profile_review.png](profile_review.png) is the preserved human review artifact. It predates the final layered interpretation and is not a complete inventory of the current profile. Current mapping authority is [fantasy_dungeon_profile.gd](fantasy_dungeon_profile.gd); `aliases()` exposes its current selections. The validator checks those selections without rewriting the accepted artifact.
