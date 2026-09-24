extends SceneTree

const CATALOG: GenerationCatalog = preload(
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "GenerationParameterResolver/starter_generation_catalog.tres"
)
const SEEDS_PER_SCALE := 100


func _initialize() -> void:
	var usage: Dictionary[StringName, int] = {}
	var maps_using: Dictionary[StringName, int] = {}
	var family_usage: Dictionary[StringName, int] = {}
	var family_maps_using: Dictionary[StringName, int] = {}
	var scale_usage := {}
	var total_punches: int = 0
	var total_maps: int = 0
	var failed_maps: int = 0

	for scale in GenerationSemantics.required_scales():
		var scale_name: String = GenerationSemantics.Scale.keys()[scale + 1]
		scale_usage[scale_name] = {}
		for seed_value in range(SEEDS_PER_SCALE):
			var parameters := GenerationParameterResolver.resolve(
				CATALOG,
				LayoutRequest.new(
					GenerationSemantics.Archetype.DUNGEON,
					scale,
					GenerationSemantics.GeometryModifier.CONFINED
				)
			)
			var geometry := BaseGeometryGenerator.generate_with_rng(
				parameters.parameters,
				_seeded_rng(seed_value)
			)
			var discovery := RoomDiscoveryFill.discover(geometry.field, true)
			var correction := ConnectionCorrection.correct(
				geometry.field,
				discovery,
				ConnectionCorrection.standard_patterns()
			)
			total_maps += 1
			if not correction.is_success:
				failed_maps += 1
				continue
			var used_this_map := {}
			var families_this_map := {}
			for punch in correction.punches:
				var pattern_id: StringName = punch.pattern_id
				var family: StringName = _family_for(pattern_id)
				usage[pattern_id] = usage.get(pattern_id, 0) + 1
				family_usage[family] = family_usage.get(family, 0) + 1
				scale_usage[scale_name][family] = scale_usage[scale_name].get(family, 0) + 1
				used_this_map[pattern_id] = true
				families_this_map[family] = true
				total_punches += 1
			for pattern_id in used_this_map:
				maps_using[pattern_id] = maps_using.get(pattern_id, 0) + 1
			for family in families_this_map:
				family_maps_using[family] = family_maps_using.get(family, 0) + 1

	print("HOLE_PUNCH_SELECTION_AUDIT")
	print("maps=", total_maps, " failed=", failed_maps, " total_punches=", total_punches)
	print("ORIENTATION_USAGE")
	for pattern in ConnectionCorrection.standard_patterns():
		var count: int = usage.get(pattern.id, 0)
		var map_count: int = maps_using.get(pattern.id, 0)
		print(
			pattern.id,
			" punches=", count,
			" punch_pct=", _percentage(count, total_punches),
			" maps=", map_count,
			" map_pct=", _percentage(map_count, total_maps)
		)
	print("FAMILY_USAGE")
	for family: StringName in [&"single", &"line", &"elbow", &"plus", &"square_3x3"]:
		var count: int = family_usage.get(family, 0)
		var map_count: int = family_maps_using.get(family, 0)
		print(
			family,
			" punches=", count,
			" punch_pct=", _percentage(count, total_punches),
			" maps=", map_count,
			" map_pct=", _percentage(map_count, total_maps)
		)
	print("FAMILY_USAGE_BY_SCALE")
	for scale_name in scale_usage:
		print(scale_name, " ", scale_usage[scale_name])
	quit(0 if failed_maps == 0 else 1)


func _family_for(pattern_id: StringName) -> StringName:
	var text: String = pattern_id
	if text.begins_with("line_"):
		return &"line"
	if text.begins_with("elbow_"):
		return &"elbow"
	return pattern_id


func _percentage(numerator: int, denominator: int) -> String:
	if denominator == 0:
		return "0.00%"
	return "%.2f%%" % (float(numerator) * 100.0 / float(denominator))


func _seeded_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng
