extends SceneTree

const ORIGIN: String = "Workshop/Rooms/Workshop_Document_Verification/verify_curation_document_claims.gd"

func _initialize() -> void:
	var config: SpriteAtlasCurationConfig = load("res://Workshop/ToolShed/Completed_Tool_Builds/SpriteAtlasCuration/fantasy_sprite_catalog_validation_config.tres")
	var selection: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Workshop/WorkshopAssets/FantasySpriteCatalog/Validation/atlas_selection_005.json"))
	selection["schema_version"] = 999
	var result: Dictionary = SpriteAtlasCatalogBuilder.build_payload(config, selection)
	if bool(result.get("valid", false)):
		push_error("%s: FAIL complete selection-contract validation; builder accepted schema_version=999 with %d entries" % [ORIGIN, result.entry_count])
		quit(1)
		return
	print("%s: PASS unsupported selection schema refused" % ORIGIN)
	quit(0)
