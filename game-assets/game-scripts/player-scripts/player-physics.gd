extends KinematicBody2D
class_name PlayerPhysics
signal damaged
signal character_changed(previous_character, current_character)

var player_index: int
var respawn_point : Vector2

var robot : bool = false

export(int) var selected_character_index setget set_selected_character
var acc
var dec
var roll_dec
var frc
var slp
var slp_roll_up
var slp_roll_down
var top
var top_roll
var jmp
var fall
var air
var grv
var spin_dash
var my_spawn_point : PlayerSpawner
onready var selected_character_node : Character
onready var fsm : = $StateMachine
var char_fsm
onready var player_camera = $CameraSpace/PlayerCamera
onready var player_vfx = $VFX
onready var GLOBAL = get_node("/root/Global");

onready var low_collider = $LowCollider
onready var ray_collider = $RayCollider

onready var left_ground:RayCast2D = $GroundSensors/LeftGroundSensor
onready var right_ground:RayCast2D = $GroundSensors/RightGroundSensor
onready var middle_ground:RayCast2D = $GroundSensors/MiddleGroundSensor
onready var ground_sensors_container:Node2D = $GroundSensors
onready var main_collider:CollisionShape2D = $MainCollider
onready var left_wall:RayCast2D = $LeftWallSensor
onready var right_wall:RayCast2D = $RightWallSensor
onready var left_wall_bottom:RayCast2D = $LeftWallSensorBottom
onready var right_wall_bottom:RayCast2D = $RightWallSensorBottom
onready var collision_handler : Node = $CollisionHandler
onready var attack_area : Area2D = $AttackBox
onready var attack_shape : CollisionShape2D = attack_area.get_node("hitbox")

onready var hitbox_area : Area2D = $HitBox
onready var hitbox_shape : CollisionShape2D = hitbox_area.get_node("hitbox")

onready var character = $Character
var characters_path = [
	"res://general-objects/players-objects/characters-scene/sonic-character-object.tscn"
]
onready var sprite
var char_default_collision
var char_roll_collision
onready var animation : CharacterAnimator
onready var audio_player = $AudioPlayer
onready var main_scene = get_tree().current_scene
var snaps : float = 15
var snap_margin = snaps

var ring_scene = preload("res://general-objects/ring-object.tscn")

var direction : Vector2 = Vector2.ZERO;
var gsp : float
var speed : Vector2
var ground_mode : int
var control_locked : bool setget _set_control_locked
const control_unlock_time_normal = .5
var control_unlock_timer : float
onready var _control_unlock_timer_node : Timer = $ControlLockTimer
var can_fall : bool
var is_ray_colliding : bool
var is_grounded : bool
var ground_point : Vector2
var ground_normal : Vector2
var has_jumped : bool
var is_floating : bool
var is_braking : bool
var was_damaged : bool
var is_wall_left : bool
var is_wall_right : bool
var is_pushing : bool
var spring_loaded : bool
var spring_loaded_v : bool
var invulnerable : bool = false
var constant_roll : bool
var boost_constant_roll : bool
var up_direction : Vector2 = Vector2.UP
var prev_position : Vector2
var ground_ray : RayCast2D
var can_break_wall : bool = false setget _set_can_brake_wall
var suspended_jump : bool = false
var suspended_can_right : bool = true
var suspended_can_left : bool = true
var throwed : bool = false
var input_dict : Dictionary
var speed_shoes : bool = false setget set_speed_shoes
var underwater : bool = false setget set_underwater
var roll_anim: bool = false
var min_to_roll := 100.0
var side : int setget set_side, get_side
var is_attacking : bool = false setget set_is_attacking
var previous_rotation : float = 0.0
# change to false when changes state
var specific_animation_temp : bool = false setget set_specific_animation_temp

func _enter_tree() -> void:
	if Engine.editor_hint:
		set_process(false)

func _ready():
	if !Engine.editor_hint:
		character.set_as_toplevel(true)
		fsm._on_host_ready(self)
		set_selected_character(selected_character_index)
		set_collision_mask(get_collision_mask())
		control_unlock_timer = control_unlock_time_normal
		for i in character.get_children():
			i.set_owner(self)
		if player_camera:
			player_camera.camera_ready(self)
		collision_handler.on_host_ready(self)

func get_rays() -> Array:
	return [left_ground, middle_ground, right_ground, left_wall, left_wall_bottom, right_wall, right_wall_bottom]
	

func get_ray(val : int) -> RayCast2D:
	var rays = get_rays()
	return rays[val]

func set_ground_rays (val : bool) -> void:
	for i in [middle_ground, left_ground, right_ground]:
		(i as RayCast2D).set_deferred("enabled", val)

# override
func set_collision_mask(val : int) -> void:
	.set_collision_mask(val)
	for i in get_rays():
		i.set_collision_mask(val)

func set_collision_mask_bit(val : int, switch : bool) -> void:
	.set_collision_mask_bit(val, switch)
	for i in get_rays():
		i.set_collision_mask_bit(val, switch)
		

func _set_can_brake_wall( val : bool ) -> void:
	can_break_wall = val
	set_collision_mask_bit(5, can_break_wall)
	set_collision_layer_bit(5, can_break_wall)
	

func set_speed_shoes(val:bool) -> void:
	speed_shoes = val
	for i in ['top', 'acc', 'dec', 'frc']:
		set(i, selected_character_node.get(i) * (1 if !speed_shoes else 1.7))
	if underwater:
		for i in ['top', 'acc', 'dec', 'frc', 'air']:
			set(i, get(i) / (1 if !underwater else 2))
		if underwater:
			jmp = selected_character_node.jmp/1.5
			grv = selected_character_node.grv/4
		else:
			jmp = selected_character_node.jmp
			grv = selected_character_node.grv
	player_vfx.get_node('Trail').enabled = speed_shoes

func set_underwater(val:bool) -> void:
	underwater = val
	for i in ['top', 'acc', 'dec', 'frc', 'air']:
		set(i, selected_character_node.get(i) / (1 if !underwater else 2))
	if underwater:
		jmp = selected_character_node.jmp/1.5
		grv = selected_character_node.grv/4
	else:
		jmp = selected_character_node.jmp
		grv = selected_character_node.grv
	if speed_shoes:
		for i in ['top', 'acc', 'dec', 'frc', 'air']:
			set(i, get(i) * (1 if !speed_shoes else 1.7))

func physics_step(delta):
	#_step_setup(delta)
	if player_camera:
		position.x = max(player_camera.camera.limit_left+9, position.x)
		position.x = min(player_camera.camera.limit_right-9, position.x)
	else:
		position.x = max(9, position.x)
	if is_on_floor():
		is_grounded = true
	ground_sensors_container.global_rotation = -ground_angle()
	ground_ray = get_ground_ray()
	is_ray_colliding = ground_ray != null
	if ground_ray and is_ray_colliding and is_on_floor():
		if Utils.Collision.is_collider_oneway(ground_ray, ground_ray.get_collider()) && ground_mode != 0:
			ground_normal = ground_ray.get_collision_normal()
			ground_mode = 0
			return
		ground_normal = Utils.Collision.get_collider_normal_precise(ground_ray, ground_mode)
		ground_mode = int(round(rad2deg(ground_angle()) / 90.0)) % 4
		ground_mode = -ground_mode if ground_mode == -2 else ground_mode
	else:
		ground_mode = 0
		ground_normal = Vector2(0, -1)
		is_grounded = false
	#ray_collider.set_deferred('disabled', !is_grounded)
	is_wall_left = step_wall_collision([left_wall, left_wall_bottom])
	is_wall_right = step_wall_collision([right_wall, right_wall_bottom])
	if player_camera:
		is_wall_left = is_wall_left or global_position.x- Utils.Collision.get_width_of_shape(main_collider.shape) - player_camera.camera.limit_left <= 0
		is_wall_right = is_wall_right or global_position.x+9 - player_camera.camera.limit_right >= 0
	#print("left: ", is_wall_left, ", right:", is_wall_right)
	

func _process(delta : float) -> void:
	character.global_position = global_position
	character.z_index = z_index
	character.visible = visible
	
	roll_anim = animation.current_animation == 'Rolling' or selected_character_node.is_rolling
	_set_can_brake_wall(!(abs(gsp) > 270 && fsm.is_current_state("Rolling") && is_grounded))
	
	roll_anim = !roll_anim
	set_collision_mask_bit(6, roll_anim)
	set_collision_layer_bit(6, roll_anim)
	
	var is_Y_speed_above = speed.y <= 0
	set_collision_mask_bit(8, is_Y_speed_above && roll_anim)
	set_collision_layer_bit(8, is_Y_speed_above && roll_anim)
	roll_anim = !roll_anim

func _set_control_locked(val : bool) -> void:
	control_locked = val
	if control_locked:
		_control_unlock_timer_node.start(control_unlock_timer)
	else:
		_control_unlock_timer_node.wait_time = control_unlock_time_normal
		_control_unlock_timer_node.stop()

func step_wall_collision(wall_sensors : Array) -> bool:
	var to_return = false
	for ws in wall_sensors:
		var rs : RayCast2D = ws
		var collider = rs.get_collider()
		#print(collider)
		if collider:
			var one_way = Utils.Collision.is_collider_oneway(rs, collider)
			var coll_angle = abs(floor(rs.get_collision_normal().angle()))
			#print(angle)
			var grounded_wall : bool = \
				(is_equal_approx(coll_angle, PI) && (is_equal_approx(coll_angle, 0)) && is_grounded)
			
			var air_wall = \
				(abs(rotation) > deg2rad(15) && fsm.current_state == 'OnAir')
			if one_way or grounded_wall or air_wall:
				return false
			to_return = to_return or rs.is_colliding()
	return to_return

func fall_from_ground() -> bool:
	if abs(gsp) < fall and ground_mode != 0:
		var angle = abs(rad2deg(ground_angle()))
		_set_control_locked(true)
		
		if angle >= 90 and angle <= 180:
			ground_mode = 0
			return true
		
	return false

func is_on_ground() -> bool:
	var ground_ray = get_ground_ray()
	if ground_ray != null:
		if Utils.Collision.is_collider_oneway(ground_ray, ground_ray.get_collider()):
			return false
		var point = ground_ray.get_collision_point()
		var normal = ground_ray.get_collision_normal()
		if abs(rad2deg(normal.angle_to(Vector2(0, -1)))) < 90:
			var player_pos = global_position.y+ 10 + (Utils.Collision.get_height_of_shape(main_collider.shape)*1.5)
			var to_return = player_pos > point.y
			return to_return
	
	return false

func snap_to_ground() -> void:
	var ground_ang = (ground_angle())
	var to_radian = ground_ang
	previous_rotation = rotation
	if abs(to_radian) < deg2rad(22.5):
		rotation = 0
	else:
		rotation += (-to_radian - rotation)
	speed += -ground_normal * 150

func ground_reacquisition() -> void:
	var ground_angle = ground_angle();
	var angle = abs(rad2deg(ground_angle))
	var angle_speed : Vector2
	angle_speed.x = cos(ground_angle) * speed.x
	angle_speed.y = -sin(ground_angle) * speed.y
	var converted_speed = angle_speed.x + angle_speed.y
	print(converted_speed)
	gsp = converted_speed
	#print(cos(ground_angle) * angle_speed.x)

func ground_angle() -> float:
	return ground_normal.angle_to(Vector2(0, -1))

func get_ground_ray() -> RayCast2D:
	can_fall = true
	
	if !left_ground.is_colliding() && !right_ground.is_colliding():
		return null
	elif !left_ground.is_colliding() && right_ground.is_colliding():
		return right_ground
	elif !right_ground.is_colliding() && left_ground.is_colliding():
		return left_ground
	
	can_fall = false
	
	var left_point : float
	var right_point : float
	
	var l_relative_point : Vector2 = left_ground.get_collision_point() - position
	var r_relative_point : Vector2 = right_ground.get_collision_point() - position
	
	left_point = sin(rotation) * l_relative_point.x + cos(rotation) + l_relative_point.y
	right_point = sin(rotation) * r_relative_point.x + cos(rotation) + r_relative_point.y
	#print(left_point, ' ', right_point)
	#print('l: %f, r: %f' % [left_point, right_point])
	if left_point <= right_point:
		return left_ground
	else:
		return right_ground

func damage(side:Vector2 = Vector2.ZERO, sound_to_play:String = "hurt"):
	if invulnerable:
		return
	emit_signal("damaged")
	invulnerable = true;
	var have_rings:bool = false
	snap_margin = 0
	is_grounded = false
	_set_control_locked(true)
	was_damaged = true
	speed.x = side.x * 220
	speed.y = side.y * 200
	self.side = -sign(speed.x) if speed.x != 0 else character.scale.x
	fsm.change_state("OnAir")
	speed = move_and_slide_preset()
	if main_scene:
		var rings = main_scene.rings
		main_scene.rings = 0;
		if rings > 0:
			have_rings = true
			drop_rings(rings);
	if have_rings:
		audio_player.play("ring_loss")
		var ground_angle = ground_angle()
		position += speed * get_physics_process_delta_time()
	else:
		audio_player.play(sound_to_play)

func invulnerable_for_sec(val : float) -> void:
	invulnerable = true
	yield(get_tree().create_timer(val), "timeout")
	invulnerable = false

func blink(sec : int):
	for i in sec*5:
		modulate.a = 0.25
		yield(get_tree().create_timer(0.075), "timeout")
		modulate.a = 1
		yield(get_tree().create_timer(0.075), "timeout")
	modulate.a = 1
	make_vulnerable()

func drop_rings(rings:int = 0):
	var n = false;
	var drop_max:int = 32;
	var drop_real:int = min(drop_max, rings); 
	var angle = -deg2rad(101.25)
	var drop_speed = 300
	
	var rings_group := []
	for i in drop_real:
		var instance_ring:RigidBody2D = ring_scene.instance();
		instance_ring.position = global_position;
		instance_ring.position.y -= 10
		instance_ring.linear_velocity.x = cos(angle) * drop_speed 
		instance_ring.linear_velocity.y = sin(angle) * drop_speed
		if n:
			instance_ring.linear_velocity.x *= -1
			angle += deg2rad(22.5);
		n = !n;
		if i == drop_real / 2:
			drop_speed /= 2
			angle = deg2rad(101.25)
		
		instance_ring.physical = true
		add_child(instance_ring)
		rings_group.append(instance_ring)
		instance_ring.set_intangible_temp()
		instance_ring.set_as_toplevel(true)
	
	var middle = 0
	for ring in rings_group:
		for ring_to_add_exception in rings_group:
			ring.add_collision_exception_with(ring_to_add_exception)
		if middle == round(rings_group.size()):
			yield(get_tree(), "idle_frame")
		middle += 1

func make_vulnerable() -> void:
	was_damaged = false
	invulnerable = false
	modulate.a = 1.0

func set_selected_character(val : int) -> void:
	if !character: return
	selected_character_index = clamp(val, 0, characters_path.size())
	var previous_character
	if selected_character_index != val:
		if character.get_children().size() != 0:
			previous_character = character.get_child(0).queue_free()
		var current_character_scene: PackedScene = load(characters_path[selected_character_index])
		selected_character_node = current_character_scene.instance()
	else:
		selected_character_node = character.get_child(0)
	selected_character_node.on_player_load_me(self)
	char_fsm = selected_character_node.fsm
	sprite = selected_character_node.get_node("Sprite")
	var coll_container = selected_character_node.get_node("CollisionContainer")
	char_default_collision = coll_container.get_node("DefaultBox")
	char_roll_collision = coll_container.get_node("RollBox")
	animation = sprite.get_node("CharAnimation")
	animation.connect("animation_finished", fsm, "_on_CharAnimation_animation_finished")
	var props = [
		"acc", "dec", "roll_dec", "frc", "slp", "slp_roll_up",
		"slp_roll_down", "top", "top_roll", "jmp", "fall", "air",
		"grv", "spin_dash"
	]
	for i in props:
		if !get(i):
			set(i, selected_character_node.character_values.get(i))
	if selected_character_index != val:
		emit_signal("character_changed", previous_character, selected_character_node)

func _on_ControlLockTimer_timeout() -> void:
	_set_control_locked(false)
	_control_unlock_timer_node.set_wait_time(control_unlock_time_normal)

func move_and_slide_preset(val = null) -> Vector2:
	var top_collide:Vector2 = Vector2(sin(rotation), -cos(rotation))
	#var fways:Vector2 = Utils.angle2Vec2(Utils.rad2dir(top_collide.angle_to(Vector2.LEFT), 4))
	var bottom_snap:Vector2 = -top_collide * snap_margin
	#print(bottom_snap)
	return move_and_slide_with_snap(
		speed if !val else val,
		bottom_snap,
		top_collide,
		true,
		4,
		deg2rad(76),
		true
	)

func play_specific_anim_temp(animation_name : String, custom_speed : float = 1.0, can_loop : bool = true) -> void:
	specific_animation_temp = true
	animation.animate(animation_name, custom_speed, can_loop)

func jump() -> String:
	snap_margin = 0
	var ground_angle = ground_angle()
	speed.x += -jmp * sin(ground_angle)
	speed.y += -jmp * cos(ground_angle)
	speed = move_and_slide_preset()
	is_grounded = false
	spring_loaded = false
	is_floating = false
	has_jumped = true
	snap_margin = 0
	audio_player.play('jump')
	return 'OnAir'

func set_side(val : int) -> void:
	side = val
	character.scale.x = side

func get_side() -> int:
	if character:
		return int(sign(character.scale.x))
	return 1

func activate():
	player_camera.camera.current = true

func deactivate():
	player_camera.camera.current = false

func set_specific_animation_temp(val : bool) -> void:
	specific_animation_temp = val

func erase_state():
	speed = Vector2.ZERO
	gsp = 0
	direction = Vector2.ZERO
	character.rotation = 0
	constant_roll = false
	sprite.offset = Vector2(-15, -15)
	spring_loaded = false
	spring_loaded_v = false

func set_is_attacking(val : bool) -> void:
	is_attacking = val
	attack_area.monitoring = is_attacking

func get_class() -> String:
	return "PlayerPhysics"

func is_class(val : String) -> bool:
	return val == get_class() or .is_class(val)
