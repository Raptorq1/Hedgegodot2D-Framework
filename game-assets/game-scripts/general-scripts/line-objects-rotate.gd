extends Node2D
tool
enum Modes {
	ROTATE
	GRAVITY
}
const ball_chain: StreamTexture = preload("res://game-assets/game-sprites/levels-sprites/test-zone-assets/test-zone-hazards/spike-ball-rotate/spike-ball-holder.png")
export var end_scene : PackedScene = preload("res://zones/test-zone-objects/act-all/spike-ball.tscn") setget set_end_scene
export var speed: float = 2.0 setget set_speed
export(Modes) var mode: int = Modes.ROTATE setget set_mode
export var initial_angle : float = 0.0 setget set_initial_angle
export var editor_process : bool = true setget set_editor_process
export var length : int = 3 setget set_length
var end : Node2D
onready var enabler = $Enabler
var grav : float = 0.0
var current_angle : float = initial_angle
var excepts = ["Enabler"]
const modes_function = {
	Modes.ROTATE: "mode_rotate",
	Modes.GRAVITY: "mode_gravity"
}
func _ready():
	if Engine.editor_hint:
		set_physics_process(editor_process)
	else:
		set_physics_process(true)
	setup()

func _draw():
	var size = ball_chain.get_size()
	var pos = Utils.Math.angle2Vec2(current_angle) * length * 16
	if Engine.editor_hint:
		draw_circle(Vector2.ZERO, length * 16, Color(0xff000077))
	
	if end and end.is_inside_tree():
		end.position = pos
	
	for i in length:
		var pos_chain = Utils.Math.angle2Vec2(current_angle) * (size) * i - (size/2)
		draw_texture(ball_chain, pos_chain)

func set_editor_process(val : bool):
	editor_process = val
	grav = 0
	if Engine.editor_hint:
		update_rot()
		set_physics_process(editor_process)
		update()

func set_length(val : int):
	length = max(val, 0)
	grav = 0
	if Engine.editor_hint and editor_process:
		update_rot()
	if has_node("Enabler"):
		var eenabler = $Enabler
		var perimeter = ((length+1) * 16) * 2
		eenabler.rect.size = Vector2.ONE * perimeter
		eenabler.rect.position = -(Vector2.ONE * perimeter) / 2
	update()

func set_initial_angle(val : float):
	initial_angle = val
	grav = 0
	if Engine.editor_hint:
		update_rot()
	update()

func _physics_process(delta):
	call(modes_function.get(mode, Modes.ROTATE), delta)
	update()

func mode_rotate(delta):
	current_angle += delta * speed

func mode_gravity(delta):
	grav += speed * delta * sign((PI/2) - current_angle)
	current_angle += grav

func _on_VisibilityEnabler2D_screen_exited() -> void:
	current_angle = 0
	grav = 0
	update()

func set_speed(val : float) -> void:
	speed = val
	grav = 0
	if Engine.editor_hint:
		update_rot()
	update()

func set_mode(val : int) -> void:
	mode = val
	grav = 0
	if Engine.editor_hint:
		update_rot()
	update()

func update_rot():
	current_angle = deg2rad(initial_angle) if mode != Modes.ROTATE else 0

func set_end_scene(val : PackedScene) -> void:
	end_scene = val
	setup()
	grav = 0
	update_rot()

func setup():
	for i in get_children():
		if !has_node(i.name) or !excepts.has(i.name):
			i.queue_free()
	end = end_scene.instance()
	add_child(end)
