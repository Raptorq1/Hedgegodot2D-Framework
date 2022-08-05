extends Node

var loaded_data: Array = []

func insert_loaded_data(val):
	loaded_data.append(val)

func reset():
	var error = get_tree().reload_current_scene()
	if error != OK:
		print("fail on reset")

func reset_game():
	var error = get_tree().change_scene_to(preload('res://main.tscn'))
	if error != OK:
		print("fail on reset")
