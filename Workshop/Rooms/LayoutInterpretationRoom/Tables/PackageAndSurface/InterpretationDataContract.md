# Interpretation Data Contract
Updated: 2026-09-26
Checkpoint: `[LayoutInterpretationRoom]+[PackageAndSurface]+[InterpretationData]`
Implementation baseline/evidence: Implemented in `Production/Systems/LayoutInterpretationSystem/PackageAndSurface/`; Production promotion validated on 2026-09-26; Git checkpoint unknown.

## Purpose

`InterpretationData` is the mutable blueprint passed from Layout Interpretation to later consumers. It pairs the exact generated `MapData` object with semantic Zone ownership and metadata without changing physical cell values.

## Package Shape

- `map_data`: the exact input object supplied to packaging.
- `purpose`: the selected architectural/site purpose.
- Zone ownership overlay: one row-major Zone ID per `MapData` cell; `0` means unzoned.
- Zone records keyed by positive Zone ID.
- Entrance and Boss Zone IDs.
- Coverage ratio.
- Current unzoned floor coordinates.

Each Zone record carries its role, requirement identity, origin, coordinates, bounds, tags, relationship kind and strength, related Zone IDs, and optional progression target.

## Ownership And Mutation

Physical and semantic data remain separate but travel together:

- `MapData.cells[index]` describes `ABYSS`, `FLOOR`, or `WALL`.
- the ownership overlay at the same index identifies the semantic Zone.
- the matching Zone record provides semantic metadata and Zone-oriented coordinate iteration.

The package is intentionally mutable for later decoration and door work. Consumers transfer ownership through `reassign_cells()` rather than editing the overlay and coordinate collections independently. A successful bulk transfer updates the overlay, source and destination coordinate collections, affected bounds, unzoned membership, and coverage together.

Destination `0` releases floor to the unzoned set. A positive destination must identify an existing Zone. Empty source Zones remain represented; Zone deletion policy belongs to a later consumer.

The package does not detect cuts, choose absorption destinations, create replacement Zones, place doors, or reinterpret architecture.

## Trust Boundary

Packaging trusts the completed `PurposeCoverageResult`. It does not repeat catalog validation, geometry validation, connectivity analysis, claim validation, or flood fill. Construction performs a single translation of completed claims into the ownership overlay and mutable Zone records.

`reassign_cells()` validates only its owned mutation request before changing state. Invalid destination IDs, out-of-bounds coordinates, and non-floor coordinates fail loudly and leave ownership unchanged.

## Identity And Copies

The original `MapData` object is carried forward without another cell-array copy. Zone metadata and membership are copied out of the temporary claim result so later blueprint mutation does not rewrite claim-engine state. Overlay reads return a copy so callers cannot silently desynchronize membership.
