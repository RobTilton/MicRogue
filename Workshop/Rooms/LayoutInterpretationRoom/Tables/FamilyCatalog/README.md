# Family Catalog Table
Updated: 2026-09-25
Checkpoint: `[LayoutInterpretationRoom]+[FamilyCatalog]+[FamilyContract]`
Implementation baseline/evidence: No Layout Interpretation implementation exists. Direction is established by Room discussion and [`../../Documents/FirstPassIdeation.md`](../../Documents/FirstPassIdeation.md); catalog contents remain unapproved.

## Rapid Shape

This Table discovers which family distinctions genuinely belong in Layout Interpretation, then derives the family input contract and initial catalog from those survivors. It does not begin by assuming a large schema or a family-specific random-room mechanism.

A candidate space belongs here only when its identity changes a spatial decision. Naming, decoration, inhabitants, props, or narrative flavor without a layout consequence belong to downstream systems.

## Family Contract Discovery

The first Box proceeds in this order:

1. Brainstorm a bounded initial list of dungeon families.
2. List candidate spaces associated with each family without treating the brainstorm as requirements.
3. For each candidate, identify whether it changes at least one layout decision:
   - required presence;
   - useful size, shape, or openness;
   - proximity to or separation from another Zone;
   - preferred route position;
   - multiplicity;
   - accessibility;
   - reservation of meaningfully different floor geometry.
4. Cut or defer candidates with no material layout consequence.
5. Classify surviving candidates as required or optional.
6. Derive the smallest family-definition schema capable of expressing those survivors.

Different names with identical spatial requirements are not automatically different Layout Interpretation roles. A later system may apply family-specific population or scenery treatments to a shared structural Zone.

## Optional Selection Decision

Family-aware optional selection remains conditional:

- If semantic reduction leaves several meaningful non-universal optional roles, define how those roles enter or influence the eligible selection pool.
- If few or none survive, omit the family-specific random-selection mechanism and use required family Zones plus universal structural fallback Zones.

Conversational `ADD_*` and `REMOVE_*` language does not establish mutation-oriented API fields. If the concepts survive, their intended meanings are preference/eligibility and prohibition. The stable catalog should not be destructively modified for each family.

## Current Limits

- No initial family list is approved.
- No candidate space has passed the survival test yet.
- Required/optional fields and preference weighting are not approved contracts.
- Detailed Box dependencies and Room-wide unresolved decisions remain authoritative in [`../../DOTS.md`](../../DOTS.md).
