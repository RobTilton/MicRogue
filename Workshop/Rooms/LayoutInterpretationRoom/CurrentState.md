# Layout Interpretation Closeout State
Updated: 2026-09-26
Checkpoint: `[LayoutInterpretationRoom]+[Closeout]+[ProductionPromotion]`
Implementation baseline/evidence: Production implementation imported and validated with Godot 4.4.1 on 2026-09-26; Git checkpoint unknown.

## Rapid Shape

Layout Interpretation is a Production system that accepts valid connected `MapData`, an architectural Purpose, and the Scale used to generate that map. It returns a complete mutable semantic layout or `null`; it does not alter physical cells or place content.

Runtime authority is [`Production/Systems/LayoutInterpretationSystem/`](../../../Production/Systems/LayoutInterpretationSystem/). The Workshop Room retains contracts, tests, evidence, and this closeout state. It no longer owns implementation copies.

Active Map Generation supports Medium and Large. Small generation is pinned for future rework. Small interpretation definitions remain present so reactivation does not require reconstructing the tier catalog.

## Current Locations And Structure

- Production entry point: [`layout_interpreter.gd`](../../../Production/Systems/LayoutInterpretationSystem/PackageAndSurface/layout_interpreter.gd)
- Production system README: [`README.md`](../../../Production/Systems/LayoutInterpretationSystem/README.md)
- Architecture requirements: [`ArchitectureCatalog/`](../../../Production/Systems/LayoutInterpretationSystem/ArchitectureCatalog/)
- Area profiles: [`ZoneCatalog/`](../../../Production/Systems/LayoutInterpretationSystem/ZoneCatalog/)
- Analysis and claiming: [`ClaimAndZoning/`](../../../Production/Systems/LayoutInterpretationSystem/ClaimAndZoning/)
- Mutable package and public surface: [`PackageAndSurface/`](../../../Production/Systems/LayoutInterpretationSystem/PackageAndSurface/)
- Durable AI-facing description: [`LAYOUT_INTERPRETATION_SYSTEM.md`](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/LAYOUT_INTERPRETATION_SYSTEM.md)
- Retained contracts and tests: [`Tables/`](Tables/)
- Recoverable retired material: [`LayoutInterpretationRoom_Retired_2026-09-26/`](../../Trashcans/LayoutInterpretationRoom_Retired_2026-09-26/)

## Entry Point And Flow

```gdscript
var data: InterpretationData = LayoutInterpreter.interpret(map_data, purpose, scale)
```

The system resolves Scale-tiered purpose requirements, scans floor geometry once, claims Entrance and farthest-valid Boss, reserves required purpose Areas, grows claims, covers eligible remainder with distinct Generic Areas, and packages the exact input `MapData` with parallel mutable Zone ownership.

## Component Contracts

- Purpose and Zone catalogs own semantic requirements and Area geometry; Small, Medium, and Large definitions remain catalogued.
- Claiming owns exclusive floor membership and atomic failure. Spatial relationships rank candidates but cannot independently block otherwise valid placement.
- `InterpretationData` owns synchronized Zone records, overlay membership, coverage, unzoned floor, and atomic bulk ownership transfer.
- The system owns no doors, stairs, portals, actors, encounters, loot, lighting, traps, furniture, decorations, or occupants.

## Validation And Current Limits

After Production promotion:

- Godot imported and registered all promoted global classes.
- Initial Purpose Catalog passed 187 checks.
- Universal Area Catalog passed 30 checks.
- Purpose Area Catalog passed 149 checks.
- Geometry Analysis passed 13 checks.
- Zone Claim passed 32 checks.
- Universal Pass passed 17 checks.
- Purpose/Coverage passed 84 checks.
- Interpretation Data passed 34 checks.
- Public Entry Point passed 11 checks.
- Active integration passed 168 checks across all 12 Medium/Large archetype-purpose-scale combinations.

Expected negative fixtures emitted their intended exact-origin errors while their suites passed. Medium Guard Tower also passed 1,000 zero-retry stress runs before closeout. Large stress was interrupted without a failure and is not claimed as complete.

Small generation is intentionally unsupported at the active generator boundary. Its retained catalog definitions are future-rework material, not a current runtime guarantee. Human final acceptance is represented by the approved Production-promotion and cleanup execution; Git checkpoint remains human-controlled and unknown.
