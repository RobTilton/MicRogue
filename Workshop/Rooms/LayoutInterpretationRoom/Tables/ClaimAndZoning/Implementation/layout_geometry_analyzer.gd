class_name LayoutGeometryAnalyzer
extends RefCounted


static func analyze(map_data: MapData) -> GeometryAnalysisResult:
	var floor_coordinates: Array[Vector2i] = []
	for y: int in range(map_data.height):
		for x: int in range(map_data.width):
			if map_data.cells[y * map_data.width + x] == MapData.FLOOR:
				floor_coordinates.append(Vector2i(x, y))
	return GeometryAnalysisResult.new(map_data.width, map_data.height, map_data.cells, floor_coordinates)
