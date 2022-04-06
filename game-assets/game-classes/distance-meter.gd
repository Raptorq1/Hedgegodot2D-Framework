extends Node2D
tool
class_name DistanceMeter2D
signal distance_achieved

var position_d : Vector2 = Vector2.ZERO
export var max_distance : float = 200.0
export var active : bool = false setget set_active


func _ready():
	if Engine.editor_hint:
		set_process(false)
		return
	set_process(active)

func _process(delta):
	update()
	if abs(global_position.distance_to(position_d)) > max_distance:
		emit_signal("distance_achieved")

func _draw():
	if Engine.editor_hint:
		var color = Color.red
		color.a = 0.5
		draw_circle(Vector2.ZERO, 5.0, color)
		draw_line(Vector2.ZERO, to_local(position_d), color, 1.0, true)

func set_active(val : bool):
	active = val
	if Engine.editor_hint:return
	set_process(active)
