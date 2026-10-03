# System Descriptions
Updated: 2026-10-03

Current Production system contracts:

- [Rapid Room Generation System](RAPID_ROOM_GENERATION_SYSTEM.md)
- [Room Layout System](ROOM_LAYOUT_SYSTEM.md)
- [Lightweight Generation Controller](LIGHTWEIGHT_GENERATION_CONTROLLER.md)

Production composition contracts:

- [Decoration Pipeline](FRAGILE_DECORATION_PIPELINE.md)

System descriptions provide immediate, present-tense understanding of what a system is and how it works. Include only the system's purpose, ownership, current source locations, entry points, ordered behavior, inputs, outputs, invariants, dependencies, mutation boundaries, guarantees, and current limits.

Do not include checkpoints, implementation baselines, test runs, pass counts, benchmark results, acceptance history, development history, or next actions. Those belong in the owning Room, current-state document, handoff, audit report, or reusable tool documentation. Follow [Documentation Format](../../Documentation_Format_README.md).

Use `FRAGILE_` only for a material coupling boundary; follow the [fragile documentation reference](../../AI_AGENTS_README/SHARED/Workflow_References/when_working_with_fragile_system_documentation.md).
