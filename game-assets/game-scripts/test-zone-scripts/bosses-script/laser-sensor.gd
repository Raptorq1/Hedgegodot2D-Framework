extends HurtableArea2DVariation


func _ready() -> void:
	pass


func _on_Area2D_body_entered(body: Node) -> void:
	on_body_enter(body)
