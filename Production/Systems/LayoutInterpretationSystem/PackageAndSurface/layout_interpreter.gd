class_name LayoutInterpreter
extends RefCounted

static var _purpose_catalog: InitialPurposeCatalog = InitialPurposeCatalog.create()
static var _universal_catalog: UniversalAreaCatalog = UniversalAreaCatalog.create()
static var _area_catalog: PurposeAreaCatalog = PurposeAreaCatalog.create()


static func interpret(
	map_data: MapData,
	purpose: LayoutInterpretationSemantics.Purpose,
	scale: GenerationSemantics.Scale
) -> InterpretationData:
	var random := RandomNumberGenerator.new()
	random.randomize()
	var result: PurposeCoverageResult = PurposeCoveragePass.run(
		map_data,
		purpose,
		scale,
		_purpose_catalog,
		_universal_catalog,
		_area_catalog,
		random
	)
	if result == null:
		return null
	return InterpretationData.create(map_data, result)
