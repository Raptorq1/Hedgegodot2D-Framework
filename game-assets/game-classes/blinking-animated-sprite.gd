extends AnimatedSprite
class_name BlinkingAnimatedSprite
tool

func _ready() -> void:set_process(true)

func _process(delta: float) -> void:
	modulate.a = 0.0 if get_tree().get_frame() % 2 == 0 else 1.0
