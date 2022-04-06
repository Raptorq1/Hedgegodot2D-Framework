extends Area2D

var speed : float = 0.0
onready var parent = get_parent()
onready var cart_charge_sfx : AudioStreamPlayer2D = $CartCharge
onready var traffic_light_sfx : AudioStreamPlayer2D = $Traffic
onready var grab_sfx : AudioStreamPlayer2D = $Grab
var player : PlayerPhysics

signal exploded

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	speed = min(speed + parent.acceleration * delta, parent.max_speed)
	var max_distance_in_tiles = parent.max_distance * parent.tile_size
	position.x = clamp(position.x + (speed * parent.scale.x) * delta, -max_distance_in_tiles, max_distance_in_tiles)
	if player:
		var player_camera = player.player_camera
		var weight = delta * (speed * 0.05)
		weight = weight if weight > 0.01 else weight
		player.player_camera.global_position = lerp(player_camera.global_position, global_position + Vector2(get_viewport_rect().size.x * 0.2, 0), weight if weight < 1 else 1)
	parent.animator.playback_speed = clamp((speed/parent.max_speed)*2, 0.5, 2)
	if abs(position.x) >= (max_distance_in_tiles) - 23:
		explode()

func explode():
	get_tree().create_timer(0.5).connect("timeout", player, "set_specific_animation_temp", [false])
	emit_signal("exploded")
	parent.traffic_animator.play("ToRed")
	player.global_position = global_position
	player.speed.x = speed * 0.5
	player.speed.y = -player.jmp
	player.side = scale.x
	player.fsm.change_state("OnAir")
	player.specific_animation_temp = true
	player.animation.animate("Hurt", 2.0)
	position.x = 0
	speed = 0
	player.visible = true
	set_physics_process(false)
	parent.animator.playback_speed = 1.0


func _on_CartArea_body_entered(body : Node):
	match body.get_class():
		"PlayerPhysics":
			if is_physics_processing() or player: return
			player = body
			player.erase_state()
			parent.player_sprite.visible = true
			player.visible = false
			player.global_position = global_position
			player.rotation = 0
			grab_sfx.play()
			yield(get_tree().create_timer(parent.delay_start * 0.3), "timeout")
			traffic_light_sfx.play()
			parent.traffic_animator.play("ToGreen")
			yield(get_tree().create_timer(parent.delay_start * 0.7), "timeout")
			cart_charge_sfx.play()
			parent.animator.play("Moving")
			set_physics_process(true)
		_:
			if !is_physics_processing(): return
			explode()


func _on_CartArea_body_exited(body):
	if body == player and !is_physics_processing():
		player = null
