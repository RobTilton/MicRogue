# Layout Interpretation System
Updated: 2026-09-26

This Production system converts valid connected `MapData` floor geometry into a mutable semantic layout without changing physical map cells or placing content.

## Public Entry Point

```gdscript
var interpretation: InterpretationData = LayoutInterpreter.interpret(
	map_data,
	LayoutInterpretationSemantics.Purpose.MINE_SHAFT,
	GenerationSemantics.Scale.MEDIUM
)
```

The caller supplies valid generator-owned `MapData`, one supported architectural purpose, and the Scale used to generate the map. The call returns a complete mutable `InterpretationData` package or `null` when a mandatory Area cannot be claimed. Randomness and catalogs remain internal; no seed or tuning port is public.

Active Map Generation supports Medium and Large. Small interpretation definitions remain preserved for future generator rework but Small generation is currently pinned.

## Components

- `ArchitectureCatalog/`: purpose, Scale-tiered requirement, role, and relationship definitions.
- `ZoneCatalog/`: universal, purpose-specific, and Generic Area geometry/tag profiles.
- `ClaimAndZoning/`: floor analysis, exclusive Area claiming, universal placement, ordered purpose placement, growth, and Generic coverage.
- `PackageAndSurface/`: public interpreter plus mutable output package and Zone records.

## Contract

The system trusts the closed generator pipeline to provide a valid map with one cardinally connected floor region. It claims Entrance and Boss first, then the selected Purpose/Scale requirements, then Generic Areas. Spatial relationships are preferences; mandatory presence and multiplicity are hard.

The exact input `MapData` travels with a parallel Zone ownership overlay and mutable Zone records. `InterpretationData.reassign_cells()` transfers floor ownership atomically without altering physical map cells.

The system does not place doors, stairs, portals, actors, loot, lighting, traps, furniture, decoration, occupants, or encounters.

## Documentation And Validation

The durable AI-facing contract is [`Workshop/AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/LAYOUT_INTERPRETATION_SYSTEM.md`](../../../Workshop/AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/LAYOUT_INTERPRETATION_SYSTEM.md).

Closeout contracts, tests, and evidence remain in [`Workshop/Rooms/LayoutInterpretationRoom/`](../../../Workshop/Rooms/LayoutInterpretationRoom/). Production promotion was validated with focused component suites and the complete 12-case active Medium/Large integration matrix.
