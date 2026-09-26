# Zone Catalog Table
Updated: 2026-09-25
Checkpoint: `[LayoutInterpretationRoom]+[ZoneCatalog]+[PurposeAndFallbackZones]`
Implementation baseline/evidence: Complete Room-local Area catalogs validated with Godot 4.4.1; no Production implementation exists.

Defines universal, purpose-required, and Generic Area roles. The authoritative Room-local definition is [`ZoneContract.md`](ZoneContract.md).

The current Room-local universal implementation and validation evidence are summarized in [`CurrentState.md`](CurrentState.md).

Area definitions provide loose claim requirements rather than templates for reconstructing rooms. Hard minimums establish validity, preferences rank valid choices without causing failure, and tags communicate downstream intent without placing content.

All sixteen Area profiles are implemented and validated. Universal placement behavior belongs to Claim And Zoning; the obsolete endpoint-policy data layer has been removed. Detailed dependencies are authoritative in [`../../DOTS.md`](../../DOTS.md).
