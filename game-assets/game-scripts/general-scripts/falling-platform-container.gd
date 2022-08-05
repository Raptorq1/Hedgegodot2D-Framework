extends Node2D

var started_count : bool = false
export var reset_after_fall : bool = false
onready var kinematic_platform = $FallingPlatform
var player_count = 0 setget set_player_count
var out_of_screen : bool = false

func _on_Area2D_body_entered(body):
	if body is PlayerPhysics:
		if body.global_position.y > kinematic_platform.sensor_area.global_position.y:
			return
		set_player_count(1 + player_count)
		if started_count: return
		if player_count > 0:
			started_count = true
		yield(get_tree().create_timer(2.0), "timeout")
		kinematic_platform.set_physics_process(true)
		
func _on_VisibilityNotifier2D_screen_exited():
	if reset_after_fall:
		kinematic_platform.set_visible(false)
		kinematic_platform.get_node("Shape").set_deferred("disabled", true)
		kinematic_platform.set_physics_process(false)
		if !out_of_screen:
			yield ($MainScreenSensor,"screen_exited")
		kinematic_platform.get_node("Shape").set_deferred("disabled", false)
		kinematic_platform.position = Vector2.ZERO
		kinematic_platform.speed = 0
		kinematic_platform.set_visible(true)
		started_count = false

func _physics_process(delta):
	if player_count > 0:
		kinematic_platform.position.y = lerp(kinematic_platform.position.y, 10, delta*10)
	else:
		kinematic_platform.position.y = lerp(kinematic_platform.position.y, 0, delta*2)
		if abs(kinematic_platform.position.y) < 0.5:
			kinematic_platform.position.y = 0
			set_physics_process(false)
	
func _on_Area2D_body_exited(body):
	if body is PlayerPhysics:
		set_player_count(player_count - 1)

func set_player_count(val : int) -> void:
	player_count = max(val, 0)
	if player_count > 0:
		set_physics_process(true)


func _on_MainScreenSensor_screen_exited():
	out_of_screen = true


func _on_MainScreenSensor_screen_entered():
	out_of_screen = false
