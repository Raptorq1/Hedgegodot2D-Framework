extends Node2D
onready var radius : float = 50
onready var plasma_sound : AudioStreamPlayer2D = $PlasmaSound
onready var player_controllers_container = $PlayerControllersContainer

class PlayerController extends Node:
	var player : PlayerPhysics
	var rotation_border : float
	var rotation_z : float
	var prev_position : Vector2
	var side = -1
	
	func _ready():
		set_physics_process(true)
	
	func _physics_process(delta):
		var cos_zrotation = cos(rotation_z)
		var rad_zrot = owner.radius * cos_zrotation
		prev_position = player.position
		player.position.x = -cos(rotation_border) * rad_zrot
		player.position.y = sin(rotation_border) * rad_zrot
		
		rotation_border -= player.direction.x * delta * 2
		rotation_z -= delta * 6.0
		side = player.z_index
		if rotation_z <= 0:
			rotation_z = TAU
		player.z_index = 1 if rotation_z < PI else -1
		player.position = (owner.global_position - player.position) 
	
	func _input(event):
		if Input.is_action_just_pressed("ui_jump_i%d" % player.player_index):
			var cos_zrotation = cos(rotation_z)
			var pos: Vector2 = ((prev_position - owner.global_position) - (player.position - owner.global_position)) / owner.radius * 12
			var rot = player.get_angle_to(owner.global_position)
			player.speed.x = -player.JMP * pos.x
			player.speed.y = -player.JMP * pos.y
			player.fsm.change_state("OnAir")
			player.z_index = 1
			queue_free()

func _ready():
	if player_controllers_container.get_children().empty():
		set_physics_process(false)

func _on_TeslaBall_body_entered(body):
	if body is PlayerPhysics:
		body.fsm.change_state("Stateless")
		body.specific_animation_temp = true
		body.animation.animate("Rolling")
		var controller_to_add = PlayerController.new()
		controller_to_add.rotation_border = -body.get_angle_to(global_position)
		controller_to_add.rotation_z = PI
		controller_to_add.player = body
#		players_rotations[body] = {
#			"rotationR": -body.get_angle_to(global_position),
#			"rotationZ": PI,
#			"side": -1,
#			"prev_position": null
#		}
		player_controllers_container.add_child(controller_to_add)
		controller_to_add.set_owner(self)
		play_plasma()

func play_plasma():
	if player_controllers_container.get_children().empty():
		return
	plasma_sound.play()
	get_tree().create_timer(0.5).connect("timeout", self, "play_plasma")

