extends Node2D
tool

const ball_chain: StreamTexture = preload("res://game-assets/game-sprites/levels-sprites/test-zone-assets/test-zone-hazards/spike-ball-rotate/spike-ball-holder.png")
export var speed: float = 2.0
export var initial_angle : float = 0.0 setget set_initial_angle
var current_angle : float = initial_angle
export var editor_process : bool = true setget set_editor_process
export var length : int = 3 setget set_length
onready var spike_ball : HurtableArea2DVariation = $SpikeBall

func _ready():
	if Engine.editor_hint:
		set_physics_process(editor_process)
	else:
		set_physics_process(true)

func _draw():
	var size = ball_chain.get_size()
	if Engine.editor_hint:
		draw_circle(Vector2.ZERO, length*13, Color(0xff000077))
	for i in length-1:
		var pos = Utils.Math.angle2Vec2(current_angle) * (size+Vector2.ONE*1) * i - (size/2)
		draw_texture(ball_chain, pos)
	var pos = Utils.Math.angle2Vec2(current_angle) * length * (11+2)
	if Engine.editor_hint:
		if has_node("SpikeBall"):
			$SpikeBall.position = pos
	else:
		spike_ball.position = pos

func set_editor_process(val : bool):
	editor_process = val
	if Engine.editor_hint:
		current_angle = deg2rad(initial_angle)
		set_physics_process(editor_process)
		update()

func set_length(val : int):
	length = max(val, 0)
	if Engine.editor_hint and editor_process:
		current_angle = deg2rad(initial_angle)
	update()

func set_initial_angle(val : float):
	initial_angle = val
	if Engine.editor_hint:
		current_angle = deg2rad(initial_angle)
	elif !Engine.editor_hint:
		current_angle = deg2rad(initial_angle)
	update()

func _physics_process(delta):
	update()
	current_angle += delta * speed
