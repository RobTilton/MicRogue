extends Node

@onready var dungeon_renderer: DungeonRenderer = $DungeonRenderer


func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var seed_value: int = rng.randi()
	var dungeon: Dictionary = DungenGeneratorFrontier.generate_dungeon(
		91,
		61,
		100,
		5,
		15,
		5,
		15,
		seed_value
	)

	dungeon_renderer.render_dungeon(dungeon)
