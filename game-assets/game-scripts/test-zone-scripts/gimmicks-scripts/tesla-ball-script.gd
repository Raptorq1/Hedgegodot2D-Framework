extends Node2D
onready var radius : float = 50
onready var plasma_sound : AudioStreamPlayer2D = $PlasmaSound
var players_activated : Array

class PlasmaBallState extends State:
	var rotation_border : float
	var rotation_z : float
	var prev_position : Vector2
	var side = -1
	var plasma_ball : Area2D
	
	func state_physics_process(host, delta):
		var cos_zrotation = cos(rotation_z)
		var rad_zrot = plasma_ball.radius * cos_zrotation
		prev_position = host.position
		host.position.x = plasma_ball.global_position.x - (-cos(rotation_border) * rad_zrot)
		host.position.y = plasma_ball.global_position.y - (sin(rotation_border) * rad_zrot)
		
		rotation_border -= host.direction.x * delta * 2
		rotation_z -= delta * 6.0
		side = host.z_index
		if rotation_z <= 0:
			rotation_z = TAU
		host.z_index = 1 if rotation_z < PI else -1
	
	func state_animation_process(host: PlayerPhysics, delta, animator:CharacterAnimator):
		host.sprite.offset = Vector2(-15, -15)
		animator.animate("Rolling", 1.0, true)
	
	func state_input(host, event):
		if Input.is_action_just_pressed("ui_jump_i%d" % host.player_index):
			host.fsm.erase_state(name)
			var cos_zrotation = cos(rotation_z)
			var pos: Vector2 = ((prev_position - plasma_ball.global_position) - (host.position - plasma_ball.global_position)) / plasma_ball.radius * 12
			var rot = host.get_angle_to(plasma_ball.global_position)
			host.speed.x = -host.jmp * pos.x
			host.speed.y = -host.jmp * pos.y
			host.z_index = 1
			var p_array : Array = plasma_ball.players_activated
			p_array.remove(p_array.find(host))

func _ready():
	connect("body_entered", self, "_on_TeslaBall_body_entered")

func _on_TeslaBall_body_entered(body):
	if body is PlayerPhysics:
		if players_activated.has(body): return
		body.erase_state()
		players_activated.append(body)
		var state_to_add = PlasmaBallState.new()
		state_to_add.rotation_border = -body.get_angle_to(global_position)
		state_to_add.rotation_z = PI
		body.fsm.insert_state(state_to_add)
		state_to_add.plasma_ball = self
		play_plasma()

func play_plasma():
	if players_activated.empty():return
	plasma_sound.play()
	get_tree().create_timer(0.5).connect("timeout", self, "play_plasma")

