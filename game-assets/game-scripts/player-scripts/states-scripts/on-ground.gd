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
	host.reset_snap()
	host.suspended_jump = false
	#print(host.get_collision_mask_bit(8))
	

func step(host, delta):
	var gsp_dir = sign(host.gsp)
	var abs_gsp = abs(host.gsp)
	
	if abs_gsp == 0 && host.direction.x == 0:
		finish("Idle")
		return
	
	if !host.is_grounded or host.is_floating:
		finish("OnAir")
		return
	
	if !host.is_ray_colliding or host.fall_from_ground():
		host.is_grounded = false
		host.erase_snap()
		finish("OnAir")
		return
	
	var ground_angle = host.ground_angle();
	
	slope = host.slp
	var slope_to_subtract = slope * sin(ground_angle)
	host.gsp -= slope_to_subtract
	#print(host.gsp, ' ', slope_to_subtract, ' ', ground_angle, ' ', slope)
	abs_gsp = abs(host.gsp)
	gsp_dir = sign(host.gsp)
	
	if !host.control_locked:
		if host.direction.x == 0:
			#if abs(slope_to_subtract) < 1.0:
				is_braking = false
				host.gsp -= min(abs_gsp, host.frc) * gsp_dir
				abs_gsp = abs(host.gsp)
				if abs_gsp < 0.1:
					finish("Idle")
		else:
			if host.direction.x == -gsp_dir:
				if abs_gsp > 0 :
					var braking_dec : float = host.dec
					host.gsp += braking_dec * host.direction.x
				if abs_gsp >= 380:
					if !is_braking:
						brake_sign = gsp_dir
						host.audio_player.play('brake')
					is_braking = true
			
			if !is_braking && abs_gsp < host.top:
					host.gsp += host.acc * host.direction.x
	
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
	
	if host.constant_roll:
		finish("Rolling")
		return
	
	if !host.can_fall || (abs(rad2deg(ground_angle)) <= 30 && host.rotation != 0):
		host.snap_to_ground()

func exit(host, next_state):
	is_braking = false
	host.is_braking = false
	if next_state == "OnAir":
		if host.animation.current_animation == "Rolling":
			host.sprite.offset = Vector2.ONE * -15
			host.sprite.offset.y += 5

func animation_step(host, animator, delta):
	if !host.fsm.is_current_state(name): return
	var gsp_dir = sign(host.gsp)
	var anim_name = idle_anim
	var anim_speed = 1.0
	var abs_gsp = abs(host.gsp);
	var play_once = false
	if abs_gsp > .1 and !is_braking:
		idle_anim = 'Idle'
		var joggin = 280
		var runnin = 420
		var faster_run = 960
		
		anim_name = 'Walking'
		if abs_gsp >= joggin and abs_gsp < runnin:
			anim_name = "Jogging"
		elif abs_gsp >= runnin and abs_gsp < faster_run:
			anim_name = "Running"
		elif abs_gsp > faster_run:
			anim_name = "SuperPeelOut"
		var host_char:Node2D = host.character
		#var inv_transform : Transform2D= host.transform.inverse()
		
		#print(host_char.global_rotation)
		if abs(host.rotation_degrees) < 30:
			host_char.rotation = lerp_angle(host_char.rotation, 0, delta * 20)
		else:
			host_char.rotation = lerp_angle(host_char.rotation, -host.ground_angle(), delta * 20)
		anim_speed = max(-(8.0 / 60.0 - (abs_gsp / 120.0)), 1.6)+0.4
		if gsp_dir != 0:
			if abs_gsp > 500:
				host_char.scale.x = gsp_dir
			else:
				host_char.scale.x = host.direction.x if host.direction.x != 0 else host_char.scale.x
	elif is_braking:
		if anim_name != 'BrakeLoop' and anim_name != 'PostBrakReturn':
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
			if abs_gsp > host.min_to_roll:
				finish("Rolling")
			elif host.ground_mode == 0:
				finish("Crouch")
		elif host.direction.y < 0 and abs_gsp <= host.min_to_roll and host.ground_mode ==0:
			finish("LookUp")
			
	if event.is_action_pressed("ui_jump_i%d" % host.player_index):
		finish(host.jump())
