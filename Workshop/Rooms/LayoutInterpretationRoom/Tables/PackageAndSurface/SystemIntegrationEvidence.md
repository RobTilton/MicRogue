# System Integration Evidence
Updated: 2026-09-26
Checkpoint: `[LayoutInterpretationRoom]+[PackageAndSurface]+[SystemIntegration]`

## Hard Gate

Current active generation supports Medium and Large. The current post-pin matrix passed **12 of 12 active runs and 168 checks** with no retry. The 18-run table below predates the Small pin and is retained as historical tier evidence; it is not a current claim that Small generation is supported.

The retained historical matrix executed the real `GeneratorCaller.make_map()` public API followed by `LayoutInterpreter.interpret()` for all six archetype-purpose pairings at Small, Medium, and Large scale with the Standard geometry modifier.

Result: **18 of 18 complete packages; 252 integration checks passed.** No retry occurred inside the retained run.

Every run verified exact `MapData` identity, unchanged physical cells, purpose, Entrance, Boss, required multiplicities, relationship targets, progression metadata, overlay/Zone agreement, exclusive ownership, unzoned agreement, calculated coverage, and post-composition ownership transfer.

## Retained Timing Run

All times are observed headless Godot 4.4.1 measurements, not guarantees.

| Pairing | Scale | Generation μs | Interpretation μs | Total μs |
|---|---|---:|---:|---:|
| Dungeon / Prison | Small | 36,342 | 21,978 | 58,320 |
| Dungeon / Prison | Medium | 59,969 | 92,980 | 152,949 |
| Dungeon / Prison | Large | 128,113 | 359,998 | 488,111 |
| Dungeon / Catacomb | Small | 25,701 | 25,996 | 51,697 |
| Dungeon / Catacomb | Medium | 72,561 | 100,297 | 172,858 |
| Dungeon / Catacomb | Large | 188,960 | 258,047 | 447,007 |
| Tower / Mage Tower | Small | 24,249 | 12,352 | 36,601 |
| Tower / Mage Tower | Medium | 55,813 | 62,627 | 118,440 |
| Tower / Mage Tower | Large | 99,321 | 194,822 | 294,143 |
| Tower / Guard Tower | Small | 23,240 | 15,361 | 38,601 |
| Tower / Guard Tower | Medium | 52,244 | 57,503 | 109,747 |
| Tower / Guard Tower | Large | 110,406 | 190,428 | 300,834 |
| Cave / Burrow Nest | Small | 21,908 | 8,687 | 30,595 |
| Cave / Burrow Nest | Medium | 59,422 | 51,569 | 110,991 |
| Cave / Burrow Nest | Large | 145,115 | 393,023 | 538,138 |
| Cave / Mine Shaft | Small | 28,476 | 14,305 | 42,781 |
| Cave / Mine Shaft | Medium | 67,553 | 55,346 | 122,899 |
| Cave / Mine Shaft | Large | 347,769 | 348,512 | 696,281 |

| Stage | Minimum μs | Maximum μs | Average μs |
|---|---:|---:|---:|
| Generation | 21,908 | 347,769 | 85,953 |
| Interpretation | 8,687 | 393,023 | 125,768 |
| Combined | 30,595 | 696,281 | 211,721 |

## Integration Corrections

The hard gate was allowed to block and drove these Room-local corrections before the retained pass:

- Required Areas now reserve minimum foundations before Boss and purpose-Area growth, preventing early claims from consuming scarce required geometry.
- Spatial relationships are soft placement preferences; closest valid geometry is accepted when ideal spacing is unavailable.
- Balanced/compact growing Areas may use equal-capacity connected geometry inside their approved window when a perfect preferred rectangle is unavailable; strict chain units remain strict.
- Guard Tower reserves its constrained Armory/Barracks foundations before its soft Entrance Guard.
- Purpose requirements resolve from Purpose plus Scale: Small uses reduced programs, Medium preserves the baseline, and Large expands approved repeated Areas.
- Armory minimum geometry was reduced to `3x3`; Equipment Storage inherits that geometry.
- Depot minimum geometry was reduced to `3x3`, its window expanded to `15x15`, and its growth preference changed to sprawling without wall avoidance.
- Final Purpose/Coverage results publish post-growth universal claims rather than stale reserved snapshots.

The targeted Small-scale gate additionally passed 1,200 checks across 100 Guard Towers and 100 Mine Shafts with zero retries. Interpretation ranged from `10,189` to `34,317` microseconds and averaged `15,794` microseconds.

Earlier blocked matrices are not acceptance evidence. Only the complete retained 18-of-18 run and 200-of-200 Small stress run above close the gate.
