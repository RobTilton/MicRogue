GeneratorRoom design alignment is sufficient to create DOTS.md.

The Room is building a bounded layout-generation system, not a monolithic dungeon/world pipeline.

Core ownership

The system’s responsibility ends at:

Given a semantic layout request, return a bounded floor/wall geometry map.

It does not own:

rendering/painting
decoration
doors as placed objects
entrances/exits
actors
loot
population
persistence
world state
player knowledge

Cutting an opening in geometry is in scope. Deciding that the opening is a door is not.

Controller boundary

The Generation Controller is the orchestration center for layout generation.

It:

receives semantic requests such as Cave + Small + Cramped
sends those labels to the generator-specific parameter resolver
receives resolved concrete generation instructions
calls the bounded generation components in sequence
receives each component result
returns the final floor/wall layout

The controller owns orchestration, not the internal work of each component.

Generation Parameter Resolver

The resolver is specific to this generator system.

Its job is:

semantic labels in → concrete generation parameters out

The caller does not need to know cave radii, room counts, taxation settings, window dimensions, etc.

Those values remain internal to the generation system.

The exact catalog structure, merge rules, and numeric values are not yet designed and should be resolved inside the appropriate Box when reached.

Base Geometry Generator

The base generator is a subordinate geometry component.

Its job is to produce large raw topology from resolved parameters.

It may own geometric concepts such as:

room geometry
future shape definitions
iteration-tax / generation-scale behavior
room stamping
generation dimensions

It does not understand semantic labels such as Cave, Small, or Cramped.

Window / Wrap

The generator already contains most of this capability but it must be wired into the production pipeline.

This component:

selects/cuts a bounded window from the larger generated field
wraps/seals the outer boundary in walls
guarantees no floor exists on the outer edge
returns the bounded working map to the controller

All downstream work operates on this scoped map.

Room Discovery / Fill

After Window / Wrap, the controller runs room/region discovery.

This component:

flood-fills the bounded layout
generates the list of floor regions/rooms
returns that list for connection work

The room list is internal working data only and is not part of the final public result.

ConnectionCorrection

ConnectionCorrection is the cheap first-pass repair stage.

It:

receives the bounded map and discovered regions
performs rapid/local hole-punch connectivity repair
returns the corrected map
returns the remaining unresolved regions

It should remain low-logic and inexpensive.

RoomJudgement

RoomJudgement handles regions that ConnectionCorrection cannot cheaply resolve.

It is the save-or-sunder stage.

For each unresolved room/region it determines whether the geometry is worth deliberately connecting.

If worth saving:

connect it through the more expensive geometry process.

If not worth saving:

convert its entire footprint to wall, effectively removing it from the layout.

Exact judgment rules, thresholds, and values are intentionally deferred until that Box is reached.

If later seed populations show that too many useful regions are being discarded, smarter window-selection rules may be designed in future work. Do not pre-design that now.

Final Geometry Validation

Before returning the layout:

outer boundary must remain sealed
no floor may exist on the outer edge
surviving floor geometry must be connected
output remains geometry-only

The final public result is only the floor/wall topology map.

No semantic markers, doorway markers, entrance markers, spawn points, room classifications, or decoration data should leak into the result.

Randomness / seeds

Production callers do not need a seed contract.

Multiple internal randomized stages may exist, including generation and window selection.

Reproducibility is not currently a production guarantee.

Test/debug tooling may expose or inject randomness as needed, but that does not define the public generation contract.

Box-level decomposition

The currently agreed compositional Boxes are:

Generation Controller
Generation Parameter Resolver
Base Geometry Generator
Window / Wrap
Room Discovery / Fill
ConnectionCorrection
RoomJudgement
Final Geometry Validation

A Box exists because it is a distinct compositional component with a defined responsibility, input, and expected output.

There are no major/minor/optional Boxes.

A Box state is:

Open
Blocked
Closed

If work is not required, it should not become a Box.

Blocking discoveries may change the work required inside a Box, but do not create speculative Boxes preemptively.

Room-ready completion signal

GeneratorRoom is ready for MCA Room close when:

all required Boxes are Closed
GeneratorCaller can be exercised across the defined catalog permutations
returned maps are visually checked
returned maps pass pathfinding/connectivity checks
system documentation reflects the completed architecture

Room-close mechanics themselves remain governed by MCA.

Important design discipline

Do not define numeric values or detailed catalog semantics early.

Examples such as Medium, Cave, Cramped, taxation rates, room counts, window dimensions, and judgment thresholds are bridge-when-we-reach-it decisions.

DOTS.md should define the required compositional path to the outcome, not prematurely design the contents of every Box.