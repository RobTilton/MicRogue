extends SceneTree

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/ArchitectureCatalog/Tests/test_initial_purpose_catalog.gd"

var _checks: int = 0
var _failures: int = 0


func _init() -> void:
	var catalog: InitialPurposeCatalog = InitialPurposeCatalog.create()
	_check(catalog != null, "catalog creation succeeds")
	if catalog != null:
		_test_complete_keys(catalog)
		_test_prison(catalog)
		_test_catacomb(catalog)
		_test_mage_tower(catalog)
		_test_guard_tower(catalog)
		_test_burrow_nest(catalog)
		_test_mine_shaft(catalog)
		_test_detached_lookup(catalog)
		_test_unsupported_lookup(catalog)
	if _failures == 0:
		print("%s: PASS (%d checks)." % [ORIGIN, _checks])
		quit(0)
		return
	push_error("%s: FAIL (%d of %d checks failed)." % [ORIGIN, _failures, _checks])
	quit(1)


func _test_complete_keys(catalog: InitialPurposeCatalog) -> void:
	for purpose: LayoutInterpretationSemantics.Purpose in LayoutInterpretationSemantics.required_purposes():
		_check(catalog.has_purpose(purpose), "catalog contains purpose %d" % purpose)
	_check(not catalog.has_purpose(LayoutInterpretationSemantics.Purpose.INVALID), "catalog rejects INVALID membership")


func _test_prison(catalog: InitialPurposeCatalog) -> void:
	var definition: LayoutPurposeDefinition = catalog.get_definition(LayoutInterpretationSemantics.Purpose.PRISON)
	_check_definition(definition, LayoutInterpretationSemantics.GeometryArchetype.DUNGEON, 3, "prison")
	_check_requirement(definition.requirements[0], &"entrance_guard", LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA, 1, 1)
	_check(definition.requirements[0].target_area_role == LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA, "prison entrance guard targets Entrance")
	_check_requirement(definition.requirements[1], &"cell_area_guard", LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA, 1, 1)
	_check_requirement(definition.requirements[2], &"cell_areas", LayoutInterpretationSemantics.AreaRole.CELL_AREA, 1, 3)
	_check(definition.requirements[2].target_requirement_id == &"cell_area_guard", "prison cells target Cell-area Guard")


func _test_catacomb(catalog: InitialPurposeCatalog) -> void:
	var definition: LayoutPurposeDefinition = catalog.get_definition(LayoutInterpretationSemantics.Purpose.CATACOMB)
	_check_definition(definition, LayoutInterpretationSemantics.GeometryArchetype.DUNGEON, 2, "catacomb")
	_check_requirement(definition.requirements[0], &"shrine", LayoutInterpretationSemantics.AreaRole.SHRINE_AREA, 1, 1)
	_check_requirement(definition.requirements[1], &"burial_chambers", LayoutInterpretationSemantics.AreaRole.BURIAL_CHAMBER_AREA, 1, 4)


func _test_mage_tower(catalog: InitialPurposeCatalog) -> void:
	var definition: LayoutPurposeDefinition = catalog.get_definition(LayoutInterpretationSemantics.Purpose.MAGE_TOWER)
	_check_definition(definition, LayoutInterpretationSemantics.GeometryArchetype.TOWER, 3, "mage tower")
	_check_requirement(definition.requirements[0], &"library", LayoutInterpretationSemantics.AreaRole.LIBRARY_AREA, 1, 1)
	_check_requirement(definition.requirements[1], &"scrying_chamber", LayoutInterpretationSemantics.AreaRole.SCRYING_CHAMBER_AREA, 1, 1)
	_check_requirement(definition.requirements[2], &"alchemy_lab", LayoutInterpretationSemantics.AreaRole.ALCHEMY_LAB_AREA, 1, 1)


func _test_guard_tower(catalog: InitialPurposeCatalog) -> void:
	var definition: LayoutPurposeDefinition = catalog.get_definition(LayoutInterpretationSemantics.Purpose.GUARD_TOWER)
	_check_definition(definition, LayoutInterpretationSemantics.GeometryArchetype.TOWER, 4, "guard tower")
	_check_requirement(definition.requirements[0], &"entrance_guard", LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA, 1, 1)
	_check_requirement(definition.requirements[1], &"entrance_armory", LayoutInterpretationSemantics.AreaRole.ARMORY_AREA, 1, 1)
	_check_requirement(definition.requirements[2], &"middle_armory", LayoutInterpretationSemantics.AreaRole.ARMORY_AREA, 1, 1)
	_check(definition.requirements[2].progression_targets_percent == PackedInt32Array([50]), "guard tower middle Armory targets 50 percent")
	_check_requirement(definition.requirements[3], &"barracks", LayoutInterpretationSemantics.AreaRole.BARRACKS_AREA, 1, 1)
	_check(definition.requirements[3].target_requirement_id == &"middle_armory", "guard tower Barracks targets middle Armory")


func _test_burrow_nest(catalog: InitialPurposeCatalog) -> void:
	var definition: LayoutPurposeDefinition = catalog.get_definition(LayoutInterpretationSemantics.Purpose.BURROW_NEST)
	_check_definition(definition, LayoutInterpretationSemantics.GeometryArchetype.CAVE, 2, "burrow/nest")
	_check_requirement(definition.requirements[0], &"nesting_resting", LayoutInterpretationSemantics.AreaRole.NESTING_RESTING_AREA, 1, 1)
	_check(definition.requirements[0].progression_targets_percent == PackedInt32Array([50]), "burrow nesting/resting targets 50 percent")
	_check_requirement(definition.requirements[1], &"food_storage", LayoutInterpretationSemantics.AreaRole.FOOD_STORAGE_AREA, 1, 1)


func _test_mine_shaft(catalog: InitialPurposeCatalog) -> void:
	var definition: LayoutPurposeDefinition = catalog.get_definition(LayoutInterpretationSemantics.Purpose.MINE_SHAFT)
	_check_definition(definition, LayoutInterpretationSemantics.GeometryArchetype.CAVE, 3, "mine shaft")
	_check_requirement(definition.requirements[0], &"entrance_guard", LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA, 1, 1)
	_check_requirement(definition.requirements[1], &"depot", LayoutInterpretationSemantics.AreaRole.DEPOT_AREA, 1, 1)
	_check_requirement(definition.requirements[2], &"equipment_storage", LayoutInterpretationSemantics.AreaRole.EQUIPMENT_STORAGE_AREA, 2, 2)
	_check(definition.requirements[2].progression_targets_percent == PackedInt32Array([35, 70]), "mine equipment storage targets 35 and 70 percent")


func _test_detached_lookup(catalog: InitialPurposeCatalog) -> void:
	var first: LayoutPurposeDefinition = catalog.get_definition(LayoutInterpretationSemantics.Purpose.PRISON)
	first.requirements[0].minimum_count = 99
	first.requirements.append(LayoutAreaRequirement.new(&"mutation", LayoutInterpretationSemantics.AreaRole.GENERIC_AREA))
	var second: LayoutPurposeDefinition = catalog.get_definition(LayoutInterpretationSemantics.Purpose.PRISON)
	_check(second.requirements.size() == 3, "lookup returns detached requirement array")
	_check(second.requirements[0].minimum_count == 1, "lookup returns detached requirement objects")


func _test_unsupported_lookup(catalog: InitialPurposeCatalog) -> void:
	var unsupported: LayoutPurposeDefinition = catalog.get_definition(LayoutInterpretationSemantics.Purpose.INVALID)
	_check(unsupported == null, "unsupported lookup returns null")


func _check_definition(
	definition: LayoutPurposeDefinition,
	expected_archetype: LayoutInterpretationSemantics.GeometryArchetype,
	expected_requirement_count: int,
	label: String
) -> void:
	_check(definition != null, "%s definition exists" % label)
	if definition == null:
		return
	_check(definition.geometry_archetype == expected_archetype, "%s geometry archetype matches" % label)
	_check(definition.requirements.size() == expected_requirement_count, "%s requirement count matches" % label)


func _check_requirement(
	requirement: LayoutAreaRequirement,
	expected_id: StringName,
	expected_role: LayoutInterpretationSemantics.AreaRole,
	expected_minimum: int,
	expected_maximum: int
) -> void:
	_check(requirement.id == expected_id, "requirement '%s' identity matches" % expected_id)
	_check(requirement.area_role == expected_role, "requirement '%s' Area role matches" % expected_id)
	_check(requirement.minimum_count == expected_minimum, "requirement '%s' minimum count matches" % expected_id)
	_check(requirement.maximum_count == expected_maximum, "requirement '%s' maximum count matches" % expected_id)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("%s: check failed: %s." % [ORIGIN, message])
