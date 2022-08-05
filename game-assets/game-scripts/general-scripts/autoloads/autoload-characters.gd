extends Node
enum Characters {
	SONIC = 0, TAILS = 1, KNUCKLES = 2, MIGHTY = 3, RAY = 4, SONIC_TAILS = 5
}

enum Shields {
	NORMAL = 0, FIRE = 1, WATER = 2, LIGHTNING = 3, HOMING = 4
}

onready var characters : = [
	CharInfo.new(Characters.SONIC, "res://general-objects/players-objects/characters-scene/sonic-character-object.tscn")
]

onready var shields_path := [
	"",
	"res://general-objects/players-objects/shields/fire-shield-object.tscn",
	"",
	"",
	""
]

func erase():
	characters.clear()
