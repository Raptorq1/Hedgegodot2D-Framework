extends Badnik
const scene_splat_blot:PackedScene = preload("res://zones/test-zone-objects/badnik-objects/splat-ink-blot.tscn")
onready var animator : AnimationPlayer = $Container/Sprite/AnimationPlayer
onready var container : Node2D = $Container
onready var fsm: = $FSM

onready var splats_land_sfx := $SplatsLand

var moving : bool = false
var was_side_switched : bool = false
var grav : float = 1400
var air_fric : float = 50
var next_side : bool = false

func _enter_tree():
	can_hurt = false
	set_physics_process(false)
	set_process(false)

func _ready():
	fsm._on_host_ready(self)
	set_physics_process(true)
	set_process(true)

func _physics_process(delta):
	#print(fsm.current_state)
	fsm._fsm_physics_process(delta)
	speed = move_and_slide(speed, Vector2.UP)

func _process(delta):
	fsm._fsm_process(delta)

func jump():
	speed.y = -400
	speed.x = 100 * Utils.Math.bool_sign(to_right)
	fsm.change_state("OnAir")

func spawn_blot():
	var splat_blot : Node2D = scene_splat_blot.instance()
	splat_blot.set_as_toplevel(true)
	get_parent().add_child(splat_blot)
	splat_blot.global_position.x = global_position.x
	splat_blot.global_position.y = global_position.y + 15
	
func set_to_right(val : bool):
	to_right = val
	container.scale.x = -Utils.Math.bool_sign(to_right)

func side_switch(value : bool):
	if to_right == value:
		return
	was_side_switched = true
	next_side = value
