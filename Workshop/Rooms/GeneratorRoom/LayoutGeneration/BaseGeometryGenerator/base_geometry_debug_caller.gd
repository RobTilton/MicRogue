extends Node3D

const ERROR_ORIGIN := (
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "BaseGeometryGenerator/base_geometry_debug_caller.gd"
)

@export var catalog: GenerationCatalog
@export var archetype: GenerationSemantics.Archetype = GenerationSemantics.Archetype.DUNGEON
@export var layout_scale: GenerationSemantics.Scale = GenerationSemantics.Scale.MEDIUM
@export var modifier: GenerationSemantics.GeometryModifier = GenerationSemantics.GeometryModifier.STANDARD

@onready var dungeon_renderer: DungeonRenderer = $DungeonRenderer
@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	var parameter_resolution := GenerationParameterResolver.resolve(
		catalog,
		LayoutRequest.new(archetype, layout_scale, modifier)
	)
	if not parameter_resolution.is_success:
		push_error("%s: %s" % [ERROR_ORIGIN, parameter_resolution.error_message])
		return

	var geometry_resolution := BaseGeometryGenerator.generate(
		parameter_resolution.parameters
	)
	if not geometry_resolution.is_success:
		push_error("%s: %s" % [ERROR_ORIGIN, geometry_resolution.error_message])
		return

	var field: GeometryField = geometry_resolution.field
	dungeon_renderer.render_dungeon({
		"width": field.size.x,
		"height": field.size.y,
		"cells": field.cells,
	})
	_center_camera(field.size)


func _center_camera(field_size: Vector2i) -> void:
	camera.position = Vector3(
		float(field_size.x - 1) * 0.5,
		40.0,
		float(field_size.y - 1) * 0.5
	)
	camera.size = float(max(field_size.x, field_size.y) + 4)
