extends AnimatedSprite


func _process(delta: float) -> void:
	modulate.a = 0.2 if get_tree().get_frame() % 4 == 0 else 1.0
