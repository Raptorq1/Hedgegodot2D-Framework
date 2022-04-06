extends Node2D
class_name CircleVisualEffect
tool
export(float) var radius : float setget _set_radius
export(Color) var color : Color = Color.white setget _set_color
export(bool) var blink : = false setget set_blink

func _set_radius (val : float) -> void:
	radius = val
	update()

func _set_color (val : Color) -> void:
	color = val
	update()

func _draw() -> void:
	if radius <= 0:
		return
	draw_circle(Vector2.ZERO, radius, color)

func _process(delta: float) -> void:
	modulate.a = 0.5 if get_tree().get_frame() % 4 == 0 else 1.0

func set_blink(val : bool):
	blink = val
	set_process(blink)
	if !blink:
		modulate.a = 1
