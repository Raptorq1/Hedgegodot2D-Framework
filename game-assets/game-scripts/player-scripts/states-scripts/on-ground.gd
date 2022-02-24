extends State

var slope : float
var is_braking : bool
var idle_anim = 'Idle'
var brake_sign : int
var spring: Node2D

func enter(host, prev_state):
	host.is_pushing = false
	#host.spring_loaded = false
	idle_anim = 'Idle'
	host.snap_margin = host.snaps
	host.suspended_jump = false
	#print(host.get_collision_mask_bit(8))
	

func step(host, delta):
	var gsp_dir = sign(host.gsp)
	var abs_gsp = abs(host.gsp)
	
	if abs_gsp == 0 && host.direction.x == 0:
		return 'Idle'
	
	if !host.is_grounded or host.was_damaged or host.is_floating:
		return "OnAir"
	
	if !host.is_ray_colliding or host.fall_from_ground():
		host.is_grounded = false
		host.move_and_slide_preset()
		host.snap_margin = 0
		return 'OnAir'
	
	if host.constant_roll:
		return 'Rolling'
	
	var ground_angle = host.ground_angle();
	slope = -host.SLP
	
	host.gsp += slope * sin(ground_angle)
	abs_gsp = abs(host.gsp)
	if !host.control_locked:
		if host.direction.x != 0:
			if host.direction.x == -gsp_dir:
				if abs_gsp > 0 :
					var braking_dec : float = host.DEC
					host.gsp += braking_dec * host.direction.x
				if abs_gsp >= 380:
					if !is_braking:
						brake_sign = gsp_dir
						host.audio_player.play('brake')
					is_braking = true
			
			if !is_braking && abs_gsp < host.TOP:
					host.gsp += host.ACC * host.direction.x;
		else:
			is_braking = false
			host.gsp -= min(abs_gsp, host.FRC) * sign(host.gsp)
			abs_gsp = abs(host.gsp)
	
	if (host.is_wall_right && host.gsp > 0) || (host.is_wall_left && host.gsp < 0):
		host.is_pushing = true
	else:
		host.is_pushing = false
	
	if gsp_dir != brake_sign or abs_gsp <= 0.01:
		is_braking = false
	
	host.is_braking = is_braking
	
	host.gsp = .0 if host.is_wall_left and host.gsp < 0 else host.gsp
	host.gsp = .0 if host.is_wall_right and host.gsp > 0 else host.gsp
	host.speed.x = host.gsp * cos(ground_angle)
	host.speed.y = host.gsp * -sin(ground_angle)
	
	if !host.can_fall || (abs(rad2deg(ground_angle)) <= 30 && host.rotation != 0):
		host.snap_to_ground()

func exit(host, next_stage):
	is_braking = false
	host.is_braking = false

func animation_step(host, animator, delta):
	var gsp_dir = sign(host.gsp)
	var anim_name = idle_anim
	var anim_speed = 1.0
	var abs_gsp = abs(host.gsp);
	var play_once = false
	if abs_gsp > .1 and !is_braking:
		idle_anim = 'Idle'
		var joggin = 250
		var runnin = 380
		var fasterrun = 960
		if abs_gsp < joggin:
			anim_name = 'Walking'
		elif abs_gsp >= joggin and abs_gsp < runnin:
			anim_name = "Jogging"
		elif abs_gsp >= runnin and abs_gsp < fasterrun:
			anim_name = "Running"
		else:
			anim_name = "SuperPeelOut"
		var host_char = host.characters
		var char_rotation = host_char.rotation_degrees;
		var host_rotation = host.rotation_degrees
		var abs_crot = abs(host_rotation)
		host_char.rotation += (-host_char.rotation) * (2 * delta)
		if abs_crot < .05:
			host_char.rotation = 0
		anim_speed = max(-(8.0 / 60.0 - (abs_gsp / 120.0)), 1.6)
		if gsp_dir != 0:
			if abs_gsp > 500:
				host_char.scale.x = gsp_dir
			else:
				host_char.scale.x = host.direction.x if host.direction.x != 0 else host_char.scale.x
	elif is_braking:
		if anim_name != 'BrakeLoop' && anim_name != 'PostBrakReturn':
			anim_name = 'Braking'
		anim_speed = 2.0
		play_once = true;
		match anim_name:
			'BrakeLoop': 
				anim_speed = -((5.0 / 60.0) - (abs(host.gsp) / 120.0));
				play_once = false;
			'PostBrakReturn':
				anim_speed = 1;
		
	else:
		if host.is_pushing:
			idle_anim = 'Idle'
			anim_name = 'Pushing'
			anim_speed = 1.5;
	
	animator.animate(anim_name, anim_speed, play_once);

func _on_animation_finished(host, anim_name):
	if anim_name == 'Walking':
		is_braking = false
	elif anim_name == 'Idle':
		idle_anim = 'Idle'
	elif anim_name == 'Idle':
		idle_anim = 'Idle'


func _on_CharAnimation_animation_finished(anim_name):
	var mac = get_parent();
	var host = mac.get_parent();
	match anim_name:
		'Walking': is_braking = false;
		'Idle': idle_anim = 'Idle';
		'Braking':
			var gsp_dir = sign(host.gsp);
			if (host.gsp != 0 ||\
			host.direction.x == -gsp_dir) &&\
			host.direction.x != 0:
				anim_name = 'PostBrakReturn'
			elif host.direction.x == 0 ||\
			host.direction.x == gsp_dir:
				is_braking = false;
				idle_anim = 'Idle';
			
	pass # Replace with function host.

func state_input(host, event):
	if host.direction.y != 0:
		var abs_gsp = abs(host.gsp)
		if host.direction.y > 0:
			if abs_gsp > 61.875:
				return "Rolling"
			elif host.ground_mode == 0:
				if host.spinDash || host.selected_character.get("spin_dash_override"):
					if event.is_action_pressed("ui_jump_i%d" % host.player_index):
						return 'SpinDash'
				return "Crouch"
		elif host.direction.y < 0 and abs_gsp <= 61.875 and host.ground_mode ==0:
			return "LookUp"
			
	if event.is_action_pressed("ui_jump_i%d" % host.player_index):
		return host.jump()
