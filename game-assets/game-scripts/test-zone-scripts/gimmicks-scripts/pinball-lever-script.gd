extends KinematicBody2D

var players : Array = [] setget set_players
onready var animator = $Sprite/AnimationPlayer

func _on_Area2D_body_entered(body):
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		p.fsm.change_state("Stateless")
		players.append(p)

func set_players(val : Array) -> void:
	players = val
	if players.size() > 0:
		set_process_input(true)
		set_physics_process(true)
	else:
		set_process_input(false)
		set_physics_process(false)

func _physics_process(delta):
	for i in players:
		var p : PlayerPhysics = i
		var angle = deg2rad(63)
		p.speed.x += cos(angle) * p.GRV/2
		p.speed.y += sin(angle) * p.GRV/2

func _on_Area2D_body_exited(body):
	if body is PlayerPhysics:
		body.fsm.change_state("OnAir")
		players.remove(players.find(body))

func _input(event):
	for i in players:
		if Input.is_action_just_pressed("ui_jump_i%d" % i.player_index):
			var difference = get_angle_to(i.position)
			if sign(i.global_position.x - global_position.x) == -sign(scale.x):
				difference = 0
			i.speed.x += cos(difference-deg2rad(45)) * i.JMP
			i.speed.y -= cos(difference) * i.JMP * 2
			animator.play("Move")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Move":
		animator.play("RESET")
