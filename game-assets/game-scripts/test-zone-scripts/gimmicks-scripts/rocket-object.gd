extends Node2D

signal exploded

var speed : float
var press_direction : int = 0
var player : PlayerPhysics
onready var parent = get_parent()
onready var hitbox = $RocketHitBox
onready var collision_shape = $RocketHitBox/Collision

func _ready():
	set_physics_process(false)
	set_process_input(false)

func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		set_physics_process(false)
		return
	if player:
		var player_camera = player.player_camera
		player_camera.follow_player = false
		player_camera.global_position = lerp(player_camera.global_position, global_position, delta * 10)
		#player.global_position = global_position
	
	if parent.can_control:
		rotation += 0.75 * press_direction * delta
	var direction = Vector2(sin(rotation), -cos(rotation))
	if speed < parent.max_speed:
		speed += delta*parent.acceleration
	speed = min(parent.max_speed, speed)
	position += direction * speed * delta
	if position.length() > parent.distance:
		_explode()

func _input(event: InputEvent) -> void:
	if !parent.can_control:
		press_direction = 0
		return
	press_direction = Input.get_axis("ui_left_i%d" % player.player_index, "ui_right_i%d" % player.player_index)

func _explode() -> void:
	
	parent.animator.play('Idle')
	hitbox.monitoring = false
	collision_shape.disabled = true
	if player:
		player.do_all()
		player.set_visible(true)
		player.sprite.set_visible(true)
		player.fsm.change_state("OnAir")
		get_tree().create_timer(0.1).connect("timeout", player, "play_specific_anim_until", ["Hurt", 1.0, true, player.fsm, "state_changed"], CONNECT_ONESHOT)
		player.speed = Vector2(sin(rotation), -cos(rotation)) * (speed * 1.5)
		player.global_position = global_position
		if player.player_camera:
			player.player_camera.follow_player = true
	speed = 0.0
	rotation = 0
	press_direction = 0
	hitbox.set_deferred("monitoring", true)
	collision_shape.set_deferred("disabled", false)
	set_deferred("player", null)
	set_physics_process(false)
	set_process_input(false)
	get_tree().connect("idle_frame", self, "set", ["position", Vector2.ZERO], CONNECT_ONESHOT)
	emit_signal('exploded')

func _on_RocketHitBox_body_shape_entered(body_rid : RID, body : Node, body_shape_index : int, local_shape_index : int):
	var shape_oneway : bool
	match body.get_class():
		"PlayerPhysics":
			if player or position != Vector2.ZERO: return
			player = body
			get_tree().create_timer(parent.delay_ascend).connect('timeout', self, '_start_ascend')
			parent.animator.play('WickBurning')
			var direction = -sign(player.global_position.x - global_position.x)
			parent.sonic_sprite.scale.x = direction if direction != 0 else parent.sonic_sprite.scale.x
			if parent.sonic_sprite.scale.x == 0:
				parent.sonic_sprite.scale.x = -1
			parent.sonic_hit_box.position = parent.sonic_sprite.offset * parent.sonic_sprite.scale.x
			parent.sonic_sprite.get_node('SsAnimator').play('snapped-sonic')
			parent.play_sounds($Audios, load('res://game-assets/audio/sfx/grab.wav'))
			player.set_visible(false)
			player.sprite.set_visible(false)
			player.has_jumped = true
			player.global_position = global_position
			player.do_nothing()
			player.erase_state()
			return
		"CollisionObject2D":
			var co2D : CollisionObject2D = body
			shape_oneway = co2D.get_shape_owner_one_way_collision_margin(body_shape_index)
		"TileMap":
			var tm : TileMap = body
			var coord : Vector2 = Physics2DServer.body_get_shape_metadata(body_rid, body_shape_index)
			var map_coord : Vector2 = tm.world_to_map(coord)
			var tile : int = tm.get_cellv(coord)
			#print(tile)
			#tm.tile_set.tile_get_shape_one_way(cell, body_shape_index)
			shape_oneway = tm.tile_set.tile_get_shape_one_way(tile, 0)
	
	if shape_oneway:
		return
	
	if is_physics_processing():
		_explode()

func _start_ascend() -> void:
	parent.play_sounds($Audios, load('res://game-assets/audio/sfx/test-zone/act-1/RocketBurn.wav'), true)
	parent.animator.play('Ascending')
	parent.animator.playback_speed = 2.5
	set_physics_process(true)
	if parent.can_control:
		set_process_input(true)
	get_tree().create_timer(0.1).connect('timeout', parent, '_repeat_spawn')
	parent.wick.set_visible(false)
