extends Resource
class_name SoundCollection

export var _sounds : Dictionary = {} setget set_sounds

func _init(sounds_ : Dictionary = {}):
	_sounds = sounds_

func set_sounds(val : Dictionary) -> void:
	_sounds = val

func get_sound(val : String):
	if _sounds.has(val):
		return _sounds[val]

func has_sound(val : String): return _sounds.has(val)
