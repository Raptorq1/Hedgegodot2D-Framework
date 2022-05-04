extends Position2D

const sign_scene : PackedScene = preload("res://general-objects/act-sign.tscn")
export var act:int = 1

func spawn_sign():
	var sign_obj = sign_scene.instance()
	
	
	queue_free()
