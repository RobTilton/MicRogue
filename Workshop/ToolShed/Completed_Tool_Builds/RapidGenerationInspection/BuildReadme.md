# Rapid Generation Inspection
Updated: 2026-10-03

Reusable inspection and measurement tools for Production Rapid and Layout. VisualizationTool.tscn renders seeded map cells, room colors and doorway orientation through its mesh libraries. test_rapid_doorway_placement.gd verifies doorway geometry; benchmark_rapid_generator.gd measures generation. Runtime data is read-only; these tools do not own gameplay orchestration.

Run each script with Godot --headless --path <project> --script res://Workshop/ToolShed/Completed_Tool_Builds/RapidGenerationInspection/<script>. Launch VisualizationTool.tscn for human visual inspection. The doorway validator checks realized geometry and local door spans. Benchmark output reports measured generation time; it does not impose a performance target. Headless startup verifies scene loading/teardown; human inspection checks appearance.
