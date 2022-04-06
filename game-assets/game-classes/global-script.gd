extends Node

enum Characters {
	SONIC = 0, TAILS = 1, KNUCKLES = 2, MIGHTY = 3, RAY = 4, SONIC_TAILS = 5
}
var chars_info : Dictionary
var available_chars : = [Characters.SONIC]
var loaded_data: Array = []

class PlayerInfo:
	var character_id : int
	
	func _init(char_id : int) -> void:
		character_id = char_id

var players : = [
	PlayerInfo.new(Characters.SONIC)
]

func _ready():
	for i in Characters.size():
		var key = Characters.keys()[i]
		var value = Characters.values()[i]
		chars_info[key] = {
			"character_id": value,
			"available": available_chars.has(value)
		}

func insert_loaded_data(val):
	loaded_data.append(val)

func erase():
	players.clear()

func reset():
	var error = get_tree().reload_current_scene()
	if error != OK:
		print("fail on reset")
