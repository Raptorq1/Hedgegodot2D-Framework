extends HurtableArea2DVariation
export var speed : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += speed * delta


func _on_VisibilityNotifier2D_viewport_exited(viewport: Viewport) -> void:
	queue_free()


func _on_hotarubeamshoot_body_entered(body: Node) -> void:
	on_body_enter(body)
