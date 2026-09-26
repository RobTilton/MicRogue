# Zone Catalog Table
Updated: 2026-09-25
Checkpoint: `[LayoutInterpretationRoom]+[ZoneCatalog]+[UniversalZones]`
Implementation baseline/evidence: Room-local Universal Area Catalog validated with Godot 4.4.1; no Production implementation exists.

Defines universal, purpose-required, and Generic Area roles. The authoritative Room-local definition is [`ZoneContract.md`](ZoneContract.md).

The current Room-local universal implementation and validation evidence are summarized in [`CurrentState.md`](CurrentState.md).

Area definitions provide loose claim requirements rather than templates for reconstructing rooms. Hard minimums establish validity, preferences rank valid choices without causing failure, and tags communicate downstream intent without placing content.

Entrance, Boss, and endpoint-policy data are implemented and validated. Purpose-required and Generic Area profiles plus all claim mechanics remain pending. Detailed dependencies are authoritative in [`../../DOTS.md`](../../DOTS.md).
