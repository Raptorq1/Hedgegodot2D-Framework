extends KinematicBody2D
class_name PlayerPhysics
signal damaged
signal loaded

var player_index: int
var respawn_point : Vector2

var im_main_player : bool = false
export(int) var CHARACTER_SELECTED = 0 setget _set_character_sel
var ACC
var DEC
var ROLLDEC
var FRC
var SLP
var SLPROLLUP
var SLPROLLDOWN
var TOP
var TOPROLL
var JMP
var FALL
var AIR
var GRV
export(bool) var spinDash = true;
var my_spawn_point : PlayerSpawner
onready var selected_character
onready var fsm : = $StateMachine
onready var player_camera = $PlayerCamera
onready var player_vfx = $VFX
onready var GLOBAL = get_node("/root/Global");

onready var low_collider = $LowCollider
onready var ray_collider = $RayCollider

onready var left_ground:RayCast2D = $GroundSensors/LeftGroundSensor
onready var right_ground:RayCast2D = $GroundSensors/RightGroundSensor
onready var middle_ground:RayCast2D = $GroundSensors/MiddleGroundSensor
onready var ground_sensors_container:Node2D = $GroundSensors
onready var main_collider:CollisionShape2D = $MainCollider
onready var attack_collider:CollisionShape2D = $AttackCollider
onready var left_wall:RayCast2D = $LeftWallSensor
onready var right_wall:RayCast2D = $RightWallSensor
onready var left_wall_bottom:RayCast2D = $LeftWallSensorBottom
onready var right_wall_bottom:RayCast2D = $RightWallSensorBottom

onready var characters = $Characters
onready var sprite
var char_default_collision
var char_roll_collision
onready var animation : CharacterAnimator
onready var audio_player = $AudioPlayer
onready var main_scene = get_tree().current_scene
var snaps : float = 10
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
# change to false when changes state
var specific_animation_temp : bool = false setget set_specific_animation_temp

func _enter_tree() -> void:
	if Engine.editor_hint:
		set_process(false)

func _ready():
	if !Engine.editor_hint:
		#yield(get_tree().create_timer(0.1), 'timeout')
		_set_character_sel(CHARACTER_SELECTED)
		set_collision_mask(get_collision_mask())
		control_unlock_timer = control_unlock_time_normal
		emit_signal('loaded')
	if player_camera:
		player_camera.camera_ready(self)

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
	var default_vals = characters.get_child(CHARACTER_SELECTED)
	for i in ['TOP', 'ACC', 'DEC', 'FRC']:
		set(i, default_vals.get(i) * (1 if !speed_shoes else 1.7))
	if underwater:
		for i in ['TOP', 'ACC', 'DEC', 'FRC', 'AIR']:
			set(i, get(i) / (1 if !underwater else 2))
		if underwater:
			JMP = default_vals.JMP/1.5
			GRV = default_vals.GRV/4
		else:
			JMP = default_vals.JMP
			GRV = default_vals.GRV
	player_vfx.get_node('Trail').enabled = speed_shoes

func set_underwater(val:bool) -> void:
	underwater = val
	var default_vals = characters.get_child(CHARACTER_SELECTED)
	for i in ['TOP', 'ACC', 'DEC', 'FRC', 'AIR']:
		set(i, default_vals.get(i) / (1 if !underwater else 2))
	if underwater:
		JMP = default_vals.JMP/1.5
		GRV = default_vals.GRV/4
	else:
		JMP = default_vals.JMP
		GRV = default_vals.GRV
	if speed_shoes:
		for i in ['TOP', 'ACC', 'DEC', 'FRC']:
			set(i, get(i) * (1 if !speed_shoes else 1.7))

func physics_step(delta):
	_step_setup(delta)
	if player_camera:
		position.x = max(player_camera.camera.limit_left+9, position.x)
		position.x = min(player_camera.camera.limit_right-9, position.x)
	else:
		position.x = max(9, position.x)
		
	if is_on_floor():
		is_grounded = true
	
	ground_ray = get_ground_ray()
	is_ray_colliding = ground_ray != null
	if ground_ray and is_ray_colliding and is_on_floor():
		if Utils.is_collider_oneway(ground_ray, ground_ray.get_collider()) && ground_mode != 0:
			ground_normal = ground_ray.get_collision_normal()
			ground_mode = 0
			return
		ground_normal = Utils.get_collider_normal_precise(ground_ray, ground_mode)
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
		is_wall_left = is_wall_left or global_position.x- Utils.get_width_of_shape(main_collider.shape) - player_camera.camera.limit_left <= 0
		is_wall_right = is_wall_right or global_position.x+9 - player_camera.camera.limit_right >= 0
	#print("left: ", is_wall_left, ", right:", is_wall_right)
	

func _step_setup(delta : float) -> void:
	roll_anim = animation.current_animation == 'Rolling'
	if "animation_roll" in selected_character:
		if selected_character.animation_roll is Array:
			for i in selected_character.animation_roll:
				roll_anim = roll_anim || animation.current_animation == i
		else:
			roll_anim = roll_anim || animation.current_animation == selected_character.animation_roll
	assert (char_default_collision && char_roll_collision, "Error: the variables not contains value")
	
	var coll_shape = char_default_collision if !roll_anim else char_roll_collision
	
	main_collider.shape = coll_shape.shape
	main_collider.position = coll_shape.position
	
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
		if collider:
			var one_way = Utils.is_collider_oneway(rs, collider)
			var coll_angle = abs(floor(rs.get_collision_normal().angle()))
			#print(angle)
			var grounded_wall : bool = \
				(is_equal_approx(coll_angle, PI) && (is_equal_approx(coll_angle, 0)) && is_grounded)
			
			var air_wall = \
				(abs(rotation) > deg2rad(15) && fsm.current_state == 'OnAir')
			
			if one_way or grounded_wall or air_wall:
				print("oneway")
				continue
			to_return = to_return or rs.is_colliding()
	return to_return

func fall_from_ground() -> bool:
	if abs(gsp) < FALL and ground_mode != 0:
		var angle = abs(rad2deg(ground_angle()))
		_set_control_locked(true)
		
		if angle >= 90 and angle <= 180:
			ground_mode = 0
			return true
		
		#print('fall')
		
	return false

func is_on_ground():
	var ground_ray = get_ground_ray()
	if ground_ray != null:
		if Utils.is_collider_oneway(ground_ray, ground_ray.get_collider()):
			return false
		var point = ground_ray.get_collision_point()
		var normal = ground_ray.get_collision_normal()
		if abs(rad2deg(normal.angle_to(Vector2(0, -1)))) < 90:
			var player_pos = global_position.y+ 10 + (Utils.get_height_of_shape(main_collider.shape)*1.5)
			var to_return = player_pos > point.y
			return to_return
	
	return false

func snap_to_ground() -> void:
	var ground_ang = (ground_angle())
	var to_radian = ground_ang
	if abs(rad2deg(ground_ang)) <= 27:
		rotation = 0
		return
	#characters.rotation_degrees = rotation + characters.rotation
	rotation += (-to_radian - rotation)
	
	ground_sensors_container.global_rotation = -ground_ang
	speed += -ground_normal * 150

func ground_reacquisition():
	var ground_angle = ground_angle();
	var angle = abs(rad2deg(ground_angle))
	var angle_speed : Vector2
	angle_speed.x = cos(ground_angle) * speed.x
	angle_speed.y = -sin(ground_angle) * speed.y
	var converted_speed = angle_speed.x + angle_speed.y
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
	characters.scale.x = -sign(speed.x) if speed.x != 0 else characters.scale.x
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
	var angle = 101.25
	var drop_speed = 200;
	# Add all rings instances to last_rings
	for i in drop_real:
		var instance_ring:KinematicBody2D = ring_scene.instance();
		instance_ring.position = global_position;
		instance_ring.position.y -= 10
		instance_ring.speed.x = cos(angle) * drop_speed;
		instance_ring.speed.y = sin(angle) * drop_speed;
		if n:
			instance_ring.speed.x *= -1
			angle += 22.5;
		n = !n;
		if i == drop_real / 2:
			drop_speed /= 2
			angle = 101.25
		add_child(instance_ring)
		instance_ring.physical = true
		instance_ring.pick_box.set_deferred("disabled", was_damaged)
		instance_ring.set_as_toplevel(true)

func make_vulnerable():
	was_damaged = false
	invulnerable = false
	modulate.a = 1.0

func get_class() -> String:
	return "PlayerPhysics"

func is_class(name:String) -> bool:
	return name == get_class() || .is_class(name);

func _set_character_sel(val : int) -> void:
	var children = characters.get_children()
	if children is Array:
		val = val % children.size()
	else:
		val = 0
	CHARACTER_SELECTED = val
	if children[CHARACTER_SELECTED] is Node2D:
		var c : Node2D = children[CHARACTER_SELECTED]
		selected_character = c
		sprite = selected_character.get_node("Sprite")
		var coll_container = selected_character.get_node("CollisionContainer")
		char_default_collision = coll_container.get_node("DefaultBox")
		char_roll_collision = coll_container.get_node("RollBox")
		animation = sprite.get_node("CharAnimation")
		var props = [
			"ACC", "DEC", "ROLLDEC", "FRC", "SLP", "SLPROLLUP",\
			"SLPROLLDOWN", "TOP", "TOPROLL", "JMP", "FALL", "AIR", "GRV"
		]
		for i in props:
			if !get(i):
				set(i, c.get(i))


func _on_ControlLockTimer_timeout() -> void:
	_set_control_locked(false)
	_control_unlock_timer_node.set_wait_time(control_unlock_time_normal)

func move_and_slide_preset() -> Vector2:
	var top_collide:Vector2 = Vector2(sin(rotation), -cos(rotation))
	#var fways:Vector2 = Utils.angle2Vec2(Utils.rad2dir(top_collide.angle_to(Vector2.LEFT), 4))
	var bottom_snap:Vector2 = -top_collide * snap_margin
	#print(bottom_snap)
	return move_and_slide_with_snap(\
		speed,
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
	speed.x += -JMP * sin(ground_angle)
	speed.y += -JMP * cos(ground_angle)
	speed = move_and_slide_preset()
	rotation = 0
	is_grounded = false
	spring_loaded = false
	is_floating = false
	has_jumped = true
	snap_margin = 0
	audio_player.play('jump')
	return 'OnAir'

func activate():
	player_camera.camera.current = true
	im_main_player = true

func deactivate():
	player_camera.camera.current = false
	im_main_player = false

func set_specific_animation_temp(val : bool) -> void:
	specific_animation_temp = val
