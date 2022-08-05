extends KinematicBody2D
class_name ScrewNut

export(bool) var lock_top : bool = false
export(bool) var lock_bottom : bool = false
const players :Array = []
onready var animator : AnimationPlayer = $Animator
var speed := 0.0
onready var spawn_pos: float = position.y
onready var center : Area2D = $Center

func _ready():
	set_physics_process(false)
	animator.play("default")
	center.collision_mask = collision_mask

func _on_Center_body_entered(body):
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		if !players.has(p):
			players.append(p)
			check_process()

func _on_Center_body_exited(body):
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		if players.has(p):
			remove_player(p)

func _physics_process(delta):
	if players.empty():
		if abs(animator.get_speed_scale()) <= 1.0 or (lock_top and speed < 0) or (lock_bottom and speed > 0):
			animator.set_speed_scale(0)
			speed = 0
			set_physics_process(false)
		return
		speed -= sign(speed) * 0.5
		var a_speed = speed * 0.025
		animator.set_speed_scale(animator.get_speed_scale() - sign(animator.get_speed_scale()) * delta)
	
	for player in players:
		handle_player(player, delta)
		speed = 0.0
		speed += player.speed.x * 0.25
		if players.size() > 0:
			speed = speed / players.size()
	if (speed < 0 and lock_top) or (speed > 0 and lock_bottom): return
	position.y += speed * delta
	var a_speed = speed * 0.025
	var t = 0.1
	animator.set_speed_scale(-t * sign(a_speed) if abs(a_speed) < t else -a_speed)

func handle_player(player: PlayerPhysics, delta:float) -> void:
	if (player.speed.x < 0 and lock_top) or (player.speed.x > 0 and lock_bottom):
		remove_player(player)
		return
	if sign(player.speed.x) == -sign(player.global_position.x - global_position.x): return
	player.move_and_slide_preset(Vector2(-player.speed.x, player.speed.y))

func remove_player(player: PlayerPhysics):players.remove(players.find(player))

func check_process():
	set_physics_process(!players.empty())


func _on_VisibilityNotifier2D_screen_exited():
	position.y = spawn_pos
