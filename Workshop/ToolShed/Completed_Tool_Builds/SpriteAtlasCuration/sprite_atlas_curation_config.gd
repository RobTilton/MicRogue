class_name SpriteAtlasCurationConfig
extends Resource

@export_file("*.png") var atlas_path: String
@export var expected_atlas_sha256: String
@export var cell_size: Vector2i = Vector2i(16, 16)
@export_range(1, 4096, 1) var columns: int = 1
@export_range(1, 4096, 1) var rows: int = 1
@export_dir var selection_directory: String
@export_file("*.json") var catalog_path: String
@export var expected_catalog_sha256: String
@export_dir var semantic_directory: String
@export var address_prefix: String = "atlas"
@export var catalog_category: String = "curated"


func atlas_size() -> Vector2i:
	return Vector2i(columns * cell_size.x, rows * cell_size.y)


func address_for(coordinate: Vector2i) -> String:
	return "%s_x%02d_y%02d" % [address_prefix, coordinate.x, coordinate.y]


func validate_for_selection() -> String:
	if atlas_path.is_empty() or not FileAccess.file_exists(atlas_path):
		return "atlas_path is missing or does not exist"
	if expected_atlas_sha256.is_empty() or FileAccess.get_sha256(atlas_path) != expected_atlas_sha256:
		return "atlas hash differs from configured authority"
	if cell_size.x <= 0 or cell_size.y <= 0 or columns <= 0 or rows <= 0:
		return "grid values must be positive"
	var texture := load(atlas_path) as Texture2D
	if texture == null or Vector2i(texture.get_size()) != atlas_size():
		return "atlas dimensions do not equal columns × rows × cell_size"
	if selection_directory.is_empty():
		return "selection_directory is empty"
	return ""


func validate_for_naming() -> String:
	var selection_error := validate_for_selection()
	if not selection_error.is_empty():
		return selection_error
	if catalog_path.is_empty() or not FileAccess.file_exists(catalog_path):
		return "catalog_path is missing or does not exist"
	if expected_catalog_sha256.is_empty() or FileAccess.get_sha256(catalog_path) != expected_catalog_sha256:
		return "catalog hash differs from configured authority"
	if semantic_directory.is_empty():
		return "semantic_directory is empty"
	return ""
