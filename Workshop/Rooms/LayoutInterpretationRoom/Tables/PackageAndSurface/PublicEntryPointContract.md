# Public Entry Point Contract
Updated: 2026-09-26
Checkpoint: `[LayoutInterpretationRoom]+[PackageAndSurface]+[PublicEntryPoint]`
Implementation baseline/evidence: `Production/Systems/LayoutInterpretationSystem/PackageAndSurface/layout_interpreter.gd`; active 12-case integration validated on 2026-09-26; Git checkpoint unknown.

## Surface

```gdscript
var data: InterpretationData = LayoutInterpreter.interpret(map_data, purpose, scale)
```

The caller supplies only the completed `MapData`, one supported architectural/site purpose, and the Scale used to generate that map. The call returns a mutable `InterpretationData` blueprint or `null` when required Areas cannot be satisfied.

## Ownership

`LayoutInterpreter` owns the internal catalogs and randomness. Catalogs are constructed and validated once as cached class state, not rebuilt for every dungeon. Each call creates and randomizes one internal `RandomNumberGenerator` and passes it through the complete interpretation pipeline. There is no public seed, random-generator port, catalog override, tuning input, or internal-pass exposure.

The entry point trusts the closed pipeline's `MapData` and supported-purpose contract. It performs no duplicate input, geometry, connectivity, catalog, or claim validation.

## Composition

One call:

1. Runs the ordered Universal and Purpose/Coverage passes with internal randomness.
2. Returns `null` without a partial public package if a mandatory claim cannot be completed.
3. Packages the successful result with the exact supplied `MapData` object.

The entry point does not mutate physical cells, place content, expose temporary claim state, or make decisions beyond the completed lower-layer contracts.
