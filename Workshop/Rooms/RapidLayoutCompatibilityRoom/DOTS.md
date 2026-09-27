# Rapid/Layout Compatibility Room DOTS
Updated: 2026-09-27

## Room Contract

- Room: `RapidLayoutCompatibilityRoom`
- Outcome: Make Rapid Room Generation output a valid, proven input to Layout Interpretation while preserving the intended responsibilities of both Production systems.
- Scope / prohibited territory: Inspect and, after Rob supplies the intended consequential mechanics, modify `Production/Systems/RapidRoomGenerationSystem/`, `Production/Systems/LayoutInterpretationSystem/`, focused validation, this Room, and the two affected AI-facing system descriptions. Do not add legacy-generator coupling to Rapid, silently discard Rapid doorway metadata, delete material, modify unrelated systems, or independently choose the architectural rewiring Rob reserved.
- Acceptance: Rapid output passes an explicitly supported Layout purpose/scale integration contract; physical geometry and Layout semantic-ownership guarantees are preserved; focused repeatable validation records the supported matrix; affected current-state documentation matches the resulting implementation.
- Authority evidence: Rob confirmed the 2026-09-27 Alignment Check and issued `Execute` in the immediately following message.
- Starting state: Git `9a4f60b71fcf34e961c23b9c5449b6a68e6028e9`; worktree was clean at Room entry. The Rapid system description still names its earlier promotion baseline and should not be treated as current Git state.

## Current Traversal

- Last completed checkpoint: none
- Active/interrupted checkpoint: `[RapidLayoutCompatibilityRoom]+[CompatibilityContract]+[InterfaceAndInvariantAudit]`
- Next eligible action: Complete the interface/invariant audit, record Rob's intended rewiring, and bound the implementation Box.
- Human acceptance / Git checkpoint: Room execution authorized; no implementation acceptance or Room Git checkpoint received.

## Mandatory Box List

| Checkpoint: [Room]+[Table]+[Box] | Responsibility | Depends on | Completion condition | Status | Outputs / evidence |
|---|---|---|---|---|---|
| `[RapidLayoutCompatibilityRoom]+[CompatibilityContract]+[InterfaceAndInvariantAudit]` | Establish the exact type, semantic-input, geometry, metadata, and ownership mismatch; capture Rob's intended resolution as the implementation contract. | none | Current-state evidence identifies all compatibility boundaries and records the approved handling without unresolved consequential mechanics. | active | `CurrentState.md`; focused Production inspection; Rob direction pending. |
| `[RapidLayoutCompatibilityRoom]+[SystemRewire]+[RapidToLayoutIntegration]` | Implement the approved compatibility design and focused tests without unrelated system expansion. | `[RapidLayoutCompatibilityRoom]+[CompatibilityContract]+[InterfaceAndInvariantAudit]` | Approved interface composes successfully; focused component and integration checks pass; affected references are synchronized. | planned | Production changes, focused validation, Room and AI-facing documentation. |
| `[RapidLayoutCompatibilityRoom]+[RoomCloseout]+[CompositionAndDisposition]` | Reconcile the completed system contract, validation matrix, retained outputs, and human validation state. | `[RapidLayoutCompatibilityRoom]+[SystemRewire]+[RapidToLayoutIntegration]` | Composition evidence and remaining limits are explicit; DOTS and current-state references agree; output disposition is recorded. | planned | `DOTS.md`, `CurrentState.md`, affected system descriptions. |

## Current References And Unresolved State

- Authoritative Room state: [`CurrentState.md`](CurrentState.md) once created by the active audit Box.
- Input system descriptions: [`RAPID_ROOM_GENERATION_SYSTEM.md`](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/RAPID_ROOM_GENERATION_SYSTEM.md) and [`LAYOUT_INTERPRETATION_SYSTEM.md`](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/LAYOUT_INTERPRETATION_SYSTEM.md).
- Runtime authorities: [`RapidRoomGenerationSystem`](../../../Production/Systems/RapidRoomGenerationSystem/) and [`LayoutInterpretationSystem`](../../../Production/Systems/LayoutInterpretationSystem/).
- Unresolved: Rob has reserved the consequential rewiring choice and has not yet supplied it. No implementation Box may cross that boundary until it is recorded.
- Output disposition: retain Room documentation here; Production changes and reusable validation remain with their owning systems unless Rob directs otherwise.
