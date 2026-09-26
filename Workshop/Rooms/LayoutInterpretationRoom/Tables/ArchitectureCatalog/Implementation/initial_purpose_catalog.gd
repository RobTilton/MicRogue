class_name InitialPurposeCatalog
extends RefCounted

const ORIGIN: String = "Workshop/Rooms/LayoutInterpretationRoom/Tables/ArchitectureCatalog/Implementation/initial_purpose_catalog.gd"

var _definitions: Dictionary = {}


static func create() -> InitialPurposeCatalog:
	var catalog := InitialPurposeCatalog.new()
	var definitions: Array[LayoutPurposeDefinition] = catalog._build_definitions()
	if not catalog._validate_complete_catalog(definitions):
		return null
	for definition: LayoutPurposeDefinition in definitions:
		catalog._definitions[definition.purpose] = definition
	return catalog


func has_purpose(purpose: LayoutInterpretationSemantics.Purpose) -> bool:
	return _definitions.has(purpose)


func get_definition(
	purpose: LayoutInterpretationSemantics.Purpose
) -> LayoutPurposeDefinition:
	if not _definitions.has(purpose):
		push_error("%s: unsupported layout purpose %d." % [ORIGIN, purpose])
		return null
	var definition: LayoutPurposeDefinition = _definitions[purpose]
	return definition.duplicate_definition()


func _build_definitions() -> Array[LayoutPurposeDefinition]:
	return [
		_prison(),
		_catacomb(),
		_mage_tower(),
		_guard_tower(),
		_burrow_nest(),
		_mine_shaft(),
	]


func _prison() -> LayoutPurposeDefinition:
	return LayoutPurposeDefinition.new(
		LayoutInterpretationSemantics.Purpose.PRISON,
		LayoutInterpretationSemantics.GeometryArchetype.DUNGEON,
		[
			_near_area(&"entrance_guard", LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA, LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA),
			_requirement(&"cell_area_guard", LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA),
			_around_requirement(&"cell_areas", LayoutInterpretationSemantics.AreaRole.CELL_AREA, 1, 3, &"cell_area_guard"),
		]
	)


func _catacomb() -> LayoutPurposeDefinition:
	return LayoutPurposeDefinition.new(
		LayoutInterpretationSemantics.Purpose.CATACOMB,
		LayoutInterpretationSemantics.GeometryArchetype.DUNGEON,
		[
			_requirement(&"shrine", LayoutInterpretationSemantics.AreaRole.SHRINE_AREA),
			_requirement(&"burial_chambers", LayoutInterpretationSemantics.AreaRole.BURIAL_CHAMBER_AREA, 1, 4),
		]
	)


func _mage_tower() -> LayoutPurposeDefinition:
	return LayoutPurposeDefinition.new(
		LayoutInterpretationSemantics.Purpose.MAGE_TOWER,
		LayoutInterpretationSemantics.GeometryArchetype.TOWER,
		[
			_requirement(&"library", LayoutInterpretationSemantics.AreaRole.LIBRARY_AREA),
			_requirement(&"scrying_chamber", LayoutInterpretationSemantics.AreaRole.SCRYING_CHAMBER_AREA),
			_requirement(&"alchemy_lab", LayoutInterpretationSemantics.AreaRole.ALCHEMY_LAB_AREA),
		]
	)


func _guard_tower() -> LayoutPurposeDefinition:
	return LayoutPurposeDefinition.new(
		LayoutInterpretationSemantics.Purpose.GUARD_TOWER,
		LayoutInterpretationSemantics.GeometryArchetype.TOWER,
		[
			_near_area(&"entrance_guard", LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA, LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA),
			_near_area(&"entrance_armory", LayoutInterpretationSemantics.AreaRole.ARMORY_AREA, LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA),
			_progression_requirement(&"middle_armory", LayoutInterpretationSemantics.AreaRole.ARMORY_AREA, PackedInt32Array([50])),
			_adjacent_requirement(&"barracks", LayoutInterpretationSemantics.AreaRole.BARRACKS_AREA, &"middle_armory"),
		]
	)


func _burrow_nest() -> LayoutPurposeDefinition:
	return LayoutPurposeDefinition.new(
		LayoutInterpretationSemantics.Purpose.BURROW_NEST,
		LayoutInterpretationSemantics.GeometryArchetype.CAVE,
		[
			_progression_requirement(&"nesting_resting", LayoutInterpretationSemantics.AreaRole.NESTING_RESTING_AREA, PackedInt32Array([50])),
			_requirement(&"food_storage", LayoutInterpretationSemantics.AreaRole.FOOD_STORAGE_AREA),
		]
	)


func _mine_shaft() -> LayoutPurposeDefinition:
	return LayoutPurposeDefinition.new(
		LayoutInterpretationSemantics.Purpose.MINE_SHAFT,
		LayoutInterpretationSemantics.GeometryArchetype.CAVE,
		[
			_near_area(&"entrance_guard", LayoutInterpretationSemantics.AreaRole.GUARD_POST_AREA, LayoutInterpretationSemantics.AreaRole.ENTRANCE_AREA),
			_requirement(&"depot", LayoutInterpretationSemantics.AreaRole.DEPOT_AREA),
			_progression_requirement(&"equipment_storage", LayoutInterpretationSemantics.AreaRole.EQUIPMENT_STORAGE_AREA, PackedInt32Array([35, 70]), 2, 2),
		]
	)


func _requirement(
	id: StringName,
	area_role: LayoutInterpretationSemantics.AreaRole,
	minimum_count: int = 1,
	maximum_count: int = 1
) -> LayoutAreaRequirement:
	return LayoutAreaRequirement.new(id, area_role, minimum_count, maximum_count)


func _near_area(
	id: StringName,
	area_role: LayoutInterpretationSemantics.AreaRole,
	target_area_role: LayoutInterpretationSemantics.AreaRole
) -> LayoutAreaRequirement:
	return LayoutAreaRequirement.new(
		id,
		area_role,
		1,
		1,
		LayoutInterpretationSemantics.RelationshipKind.NEAR_AREA,
		LayoutInterpretationSemantics.RelationshipStrength.PREFERRED,
		target_area_role
	)


func _around_requirement(
	id: StringName,
	area_role: LayoutInterpretationSemantics.AreaRole,
	minimum_count: int,
	maximum_count: int,
	target_requirement_id: StringName
) -> LayoutAreaRequirement:
	return LayoutAreaRequirement.new(
		id,
		area_role,
		minimum_count,
		maximum_count,
		LayoutInterpretationSemantics.RelationshipKind.AROUND_REQUIREMENT,
		LayoutInterpretationSemantics.RelationshipStrength.REQUIRED,
		LayoutInterpretationSemantics.AreaRole.INVALID,
		target_requirement_id
	)


func _adjacent_requirement(
	id: StringName,
	area_role: LayoutInterpretationSemantics.AreaRole,
	target_requirement_id: StringName
) -> LayoutAreaRequirement:
	return LayoutAreaRequirement.new(
		id,
		area_role,
		1,
		1,
		LayoutInterpretationSemantics.RelationshipKind.ADJACENT_REQUIREMENT,
		LayoutInterpretationSemantics.RelationshipStrength.REQUIRED,
		LayoutInterpretationSemantics.AreaRole.INVALID,
		target_requirement_id
	)


func _progression_requirement(
	id: StringName,
	area_role: LayoutInterpretationSemantics.AreaRole,
	progression_targets_percent: PackedInt32Array,
	minimum_count: int = 1,
	maximum_count: int = 1
) -> LayoutAreaRequirement:
	return LayoutAreaRequirement.new(
		id,
		area_role,
		minimum_count,
		maximum_count,
		LayoutInterpretationSemantics.RelationshipKind.PROGRESSION_TARGETS,
		LayoutInterpretationSemantics.RelationshipStrength.PREFERRED,
		LayoutInterpretationSemantics.AreaRole.INVALID,
		&"",
		progression_targets_percent
	)


func _validate_complete_catalog(
	definitions: Array[LayoutPurposeDefinition]
) -> bool:
	var expected_purposes: Array[LayoutInterpretationSemantics.Purpose] = LayoutInterpretationSemantics.required_purposes()
	if definitions.size() != expected_purposes.size():
		return _refuse("catalog has %d definitions; expected %d." % [definitions.size(), expected_purposes.size()])
	var seen_purposes: Dictionary = {}
	for definition: LayoutPurposeDefinition in definitions:
		if definition == null:
			return _refuse("catalog contains a null purpose definition.")
		if definition.purpose not in expected_purposes:
			return _refuse("catalog contains unsupported purpose %d." % definition.purpose)
		if seen_purposes.has(definition.purpose):
			return _refuse("catalog repeats purpose %d." % definition.purpose)
		if not _validate_definition(definition):
			return false
		seen_purposes[definition.purpose] = true
	for purpose: LayoutInterpretationSemantics.Purpose in expected_purposes:
		if not seen_purposes.has(purpose):
			return _refuse("catalog is missing purpose %d." % purpose)
	return true


func _validate_definition(definition: LayoutPurposeDefinition) -> bool:
	if definition.geometry_archetype == LayoutInterpretationSemantics.GeometryArchetype.INVALID:
		return _refuse("purpose %d has no geometry archetype." % definition.purpose)
	if definition.requirements.is_empty():
		return _refuse("purpose %d has no ordered requirements." % definition.purpose)
	var prior_requirement_ids: Dictionary = {}
	for requirement: LayoutAreaRequirement in definition.requirements:
		if requirement == null:
			return _refuse("purpose %d contains a null requirement." % definition.purpose)
		if requirement.id == &"":
			return _refuse("purpose %d contains an unnamed requirement." % definition.purpose)
		if prior_requirement_ids.has(requirement.id):
			return _refuse("purpose %d repeats requirement '%s'." % [definition.purpose, requirement.id])
		if not _validate_requirement(requirement, prior_requirement_ids):
			return false
		prior_requirement_ids[requirement.id] = true
	return true


func _validate_requirement(
	requirement: LayoutAreaRequirement,
	prior_requirement_ids: Dictionary
) -> bool:
	if requirement.area_role not in LayoutInterpretationSemantics.required_area_roles():
		return _refuse("requirement '%s' uses unsupported Area role %d." % [requirement.id, requirement.area_role])
	if requirement.minimum_count <= 0:
		return _refuse("requirement '%s' has non-positive minimum count." % requirement.id)
	if requirement.maximum_count < requirement.minimum_count:
		return _refuse("requirement '%s' has maximum count below minimum count." % requirement.id)
	match requirement.relationship_kind:
		LayoutInterpretationSemantics.RelationshipKind.NONE:
			if requirement.relationship_strength != LayoutInterpretationSemantics.RelationshipStrength.NONE:
				return _refuse("requirement '%s' has relationship strength without a relationship." % requirement.id)
			if requirement.target_area_role != LayoutInterpretationSemantics.AreaRole.INVALID or requirement.target_requirement_id != &"" or not requirement.progression_targets_percent.is_empty():
				return _refuse("requirement '%s' has relationship data without a relationship." % requirement.id)
		LayoutInterpretationSemantics.RelationshipKind.NEAR_AREA:
			if requirement.relationship_strength == LayoutInterpretationSemantics.RelationshipStrength.NONE:
				return _refuse("requirement '%s' has no near-Area relationship strength." % requirement.id)
			if requirement.target_area_role not in LayoutInterpretationSemantics.universal_area_roles():
				return _refuse("requirement '%s' targets a non-universal Area role." % requirement.id)
			if requirement.target_requirement_id != &"" or not requirement.progression_targets_percent.is_empty():
				return _refuse("requirement '%s' mixes near-Area relationship data." % requirement.id)
		LayoutInterpretationSemantics.RelationshipKind.AROUND_REQUIREMENT, LayoutInterpretationSemantics.RelationshipKind.ADJACENT_REQUIREMENT:
			if requirement.relationship_strength == LayoutInterpretationSemantics.RelationshipStrength.NONE:
				return _refuse("requirement '%s' has no requirement relationship strength." % requirement.id)
			if not prior_requirement_ids.has(requirement.target_requirement_id):
				return _refuse("requirement '%s' targets a missing or later requirement '%s'." % [requirement.id, requirement.target_requirement_id])
			if requirement.target_area_role != LayoutInterpretationSemantics.AreaRole.INVALID or not requirement.progression_targets_percent.is_empty():
				return _refuse("requirement '%s' mixes requirement relationship data." % requirement.id)
		LayoutInterpretationSemantics.RelationshipKind.PROGRESSION_TARGETS:
			if requirement.relationship_strength == LayoutInterpretationSemantics.RelationshipStrength.NONE:
				return _refuse("requirement '%s' has no progression relationship strength." % requirement.id)
			if requirement.progression_targets_percent.size() != requirement.maximum_count:
				return _refuse("requirement '%s' progression target count does not match maximum count." % requirement.id)
			var previous_target: int = 0
			for target: int in requirement.progression_targets_percent:
				if target <= previous_target or target >= 100:
					return _refuse("requirement '%s' has invalid progression targets." % requirement.id)
				previous_target = target
			if requirement.target_area_role != LayoutInterpretationSemantics.AreaRole.INVALID or requirement.target_requirement_id != &"":
				return _refuse("requirement '%s' mixes progression relationship data." % requirement.id)
		_:
			return _refuse("requirement '%s' has unsupported relationship kind %d." % [requirement.id, requirement.relationship_kind])
	return true


func _refuse(message: String) -> bool:
	push_error("%s: %s" % [ORIGIN, message])
	return false
