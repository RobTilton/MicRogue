# Portable Layout Generation
Updated: 2026-09-25

This directory is the complete reusable Godot layout-generation module. Copy `MapGenerationSystem/` into a Godot 4 project, allow Godot to import its scripts, and call the public boundary:

```gdscript
var map_data: MapData = GeneratorCaller.make_map(
	MapParameters.new(
		GenerationSemantics.Archetype.CAVE,
		GenerationSemantics.Scale.LARGE,
		GenerationSemantics.GeometryModifier.CONFINED
	)
)
```

All three semantic parameters are required. `Standard` must be explicit. A successful call returns detached `MapData` containing `width`, `height`, and row-major `cells`. Cell values are owned by `MapData`: `ABYSS = 0`, `FLOOR = 1`, and `WALL = 2`.

Failure is loud and returns `null`; partial maps are never returned. Production randomness is internal and no seed is part of the public contract.

The module has no renderer, scene, autoload, Global, Micro Rogue gameplay, biome, POI-family, population, persistence, or painting dependency. Consumers decide how returned data is rendered or used. Internal components remain independently callable with their required typed inputs, but ordinary consumers should use `GeneratorCaller.make_map()`.
