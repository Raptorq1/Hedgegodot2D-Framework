extends State

var was_damaged : bool
var has_jumped : bool
var has_rolled : bool
var spring_loaded : bool
var spring_loaded_v : bool
var roll_jump : bool
var is_floating
var override_anim : String
var post_damage:bool
var can_snap:float
var was_throwed : bool = false
var roll_on_snap_ground : bool = false

func enter(host, prev_state):
	host.snap_margin = 0
	can_snap = 0
	#print(prev_state)
	host.ground_sensors_container.rotation = 0
	if host.spring_loaded || host.roll_anim:
		host.character.rotation = 0;
	was_damaged = host.was_damaged
	#print(was_damaged)
	if host.throwed:
		was_throwed = true
		host.throwed = false
	if was_damaged:
		host.control_locked = true;
	#print(was_damaged)
	is_floating = host.is_floating;
	if !is_floating:
		spring_loaded = host.spring_loaded
		spring_loaded_v = host.spring_loaded_v
		if !spring_loaded:
			has_jumped = host.has_jumped
			has_rolled = prev_state == "Rolling"
			spring_loaded_v = false
		else:
			has_jumped = false
			has_rolled = false
	else:
		spring_loaded = false;
		has_jumped = false
		has_rolled = false
	
	
	host.has_jumped = false
	host.spring_loaded = false;
	host.is_floating = false;
	host.spring_loaded_v = false
	roll_jump = has_jumped && has_rolled
	
	var is_animation_roll = host.roll_anim
	if is_animation_roll:
		host.sprite.offset = Vector2(-15, -10)
	host.rotation = 0

func step(host: PlayerPhysics, delta):
	var delta_final = delta * 75
	var is_animation_roll = host.roll_anim
	if is_animation_roll:
		host.sprite.offset = Vector2(-15, -10)
	host.character.rotation = lerp_angle(host.character.rotation, 0, 0.25)
	if host.is_floating:
		has_jumped = false
		spring_loaded = false
		has_rolled = false
		is_floating = true
		host.control_locked = false
	
	if host.was_damaged:
		was_damaged = true
		has_jumped = false
		spring_loaded = false
		has_rolled = false
		is_floating = false
		
	if host.spring_loaded || host.spring_loaded_v:
		spring_loaded = true
		if host.spring_loaded_v:
			spring_loaded_v = true
			was_damaged = false
		has_jumped = false
		has_rolled = false
		is_floating = false
	
	#print(was_damaged)
	#print(spring_loaded, is_floating)
	
	if host.is_on_ceiling() && !spring_loaded:
		if host.speed.y < 0:
			host.speed.y = 0;
	#print(-Vector2(0, -1).floor())
	
	host.speed.x = 0 if host.is_wall_left && host.speed.x < 0 else host.speed.x
	host.speed.x = 0 if host.is_wall_right && host.speed.x > 0 else host.speed.x

	var can_move = true if !host.control_locked else false
	
	#print(prev_frame_state)
	if host.is_grounded:
		if can_snap >= 0.25:
	#	if host.speed.y >= -50:
			host.spring_loaded = false
			host.snap_margin = host.snaps
			if was_damaged:
				finish('Idle')
			if roll_on_snap_ground:
				finish('Rolling')
			finish('OnGround')
	
	can_snap += delta
	#print(can_snap)
	#print(prev_frame_state)
	
	
	if host.direction.x != 0 && can_move:
		if abs(host.speed.x) < host.top:
			host.speed.x += host.air * host.direction.x * delta_final
	if !spring_loaded:
		if has_jumped:
			var ui_jump = "ui_jump_i%d" % host.player_index
			if Input.is_action_just_released(ui_jump): # has jumped
				var jmp_release = -240.0
				if host.underwater:
					jmp_release /= 2
				if host.speed.y < jmp_release: # set min jump height
					host.speed.y = jmp_release
	if host.speed.y < 0 and host.speed.y > -240:
		host.speed.x -= (host.speed.x/0.125)/435 * delta_final
	
	host.speed.y += host.grv * (delta * 60)

func exit(host, next_state):
	can_snap = 0
	is_floating = false;
	host.is_floating = false;
	was_throwed = false
	host.throwed = false
	was_damaged = false
	if host.is_grounded:
		if host.was_damaged:
			host.control_locked = false
			host.gsp = 0
			host.was_damaged = false
		else:
			host.ground_reacquisition()
	roll_on_snap_ground = false

func animation_step(host, animator, delta):
	var anim_name = animator.current_animation
	var anim_speed = animator.get_playing_speed()
	if anim_name == 'Walking':
		anim_speed = 3
	
	if anim_name == 'Braking':
		anim_name = 'Walking';
	if was_damaged:
		anim_name = "Hurt"
		anim_speed = 2
	else:
		if is_floating || was_throwed:
			anim_name = "Rotating"
			anim_speed = 3;
		else:
			if spring_loaded && spring_loaded_v:
				anim_name = "SpringJump"
				anim_speed = 3;
			else:
				if has_jumped or has_rolled:
					anim_name = 'Rolling';
					host.character.rotation = 0
					anim_speed = max(-((5.0 / 60.0) - (abs(host.gsp) / 120.0)), 1.0);
	
	host.character.scale.x = host.direction.x if host.direction.x != 0 else host.character.scale.x
	
	if _can_animate:
		animator.animate(anim_name, anim_speed, true)
	
	
	
	animate_again()


func _on_animation_finished(host, anim_name) -> void:
	match anim_name:
		'Rotating':
			if was_throwed && !is_floating:
				was_throwed = false
				host.animation.current_animation = 'Walking'
