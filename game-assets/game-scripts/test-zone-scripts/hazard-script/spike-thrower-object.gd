extends Node2D

var actived : bool setget set_actived
var launched : bool = false
onready var charge_sfx : AudioStreamPlayer2D = $ChargeSFX
onready var spike_ball : RigidBody2D = $SpikeBall
onready var platform : StaticBody2D = $Platform
onready var floor_pos : Position2D = $FloorPosition

func _ready():
	platform.add_collision_exception_with(spike_ball)
	spike_ball.add_collision_exception_with(platform)

func _on_VisibilityNotifier2D_screen_entered():
	set_actived(true)

func _on_VisibilityNotifier2D_screen_exited():
	set_actived(false)

func set_actived(val : bool) -> void:
	if actived == val: return
	actived = val
	if actived: start()


func start():
	while actived and !launched:
		yield(get_tree().create_timer(1.0), "timeout")
		charge_sfx.play()
		yield(charge_sfx, "finished")
		yield(get_tree().create_timer(0.5), "timeout")
		spike_ball.jump()
		launched = true
