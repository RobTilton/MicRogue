extends Node


func _ready() -> void:
	var dungeon: Dictionary = DungenGeneratorFrontier.generate_dungeon(
		121,
		41,
		100,
		5,
		15,
		5,
		15,
		4434
	)

	print(DungenGeneratorFrontier.field_to_ascii(dungeon))
