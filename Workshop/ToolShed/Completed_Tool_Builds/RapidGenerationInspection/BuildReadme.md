# Rapid Generation Inspection
Updated: 2026-10-03

Reusable inspection and measurement tools for Production Rapid and Layout. VisualizationTool.tscn renders seeded map cells, room colors and doorway orientation through its mesh libraries. test_rapid_doorway_placement.gd verifies doorway geometry; benchmark_rapid_generator.gd measures generation. Runtime data is read-only; these tools do not own gameplay orchestration.

Run each script with Godot --headless --path <project> --script res://Workshop/ToolShed/Completed_Tool_Builds/RapidGenerationInspection/<script>. Launch VisualizationTool.tscn for human visual inspection. Automated relocation results are recorded in Workshop/_Audits/Current_Audits/System_Realignment/RelocationValidation.md; human verification was received on 2026-10-03.
