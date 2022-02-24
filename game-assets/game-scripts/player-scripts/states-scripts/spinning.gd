extends State

var slope : float
var idle_anim = 'Rolling'

func enter(host, prev_state):
	host.is_pushing = false
	idle_anim = 'Rolling'
	host.snap_margin = host.snaps
	host.suspended_jump = false
	host.audio_player.play("spin")
	

func step(host, delta):
	var gsp_dir = sign(host.gsp)
	var abs_gsp = abs(host.gsp)
	
	if abs_gsp == 0 && host.direction.x == 0:
		return 'Idle'
	
	if host.was_damaged:
		host.snap_margin = 0
		return 'OnAir'
	
	if !host.is_ray_colliding || host.fall_from_ground():
		host.is_grounded = false
		host.move_and_slide_preset()
		host.snap_margin = 0
		return 'OnAir'
	
	if host.is_floating:
		host.snap_margin = 0
		return 'OnAir'
	
	if host.constant_roll:
		if abs_gsp < 300:
			host.gsp += ((host.TOPROLL - host.gsp) * delta) * host.characters.scale.x * host.ACC
			host.gsp = clamp(host.gsp, -300, 300)
		host.control_locked = true
		host.control_unlock_timer = 0.5
	
	var ground_angle = host.ground_angle();
	#print(rad2deg(ground_angle))
	
	if abs_gsp < 30.0:
		return "OnGround"
	
	if sign(host.gsp) == sign(sin(ground_angle)):
		slope = -host.SLPROLLUP
	else:
		slope = -host.SLPROLLDOWN
	
	
	host.gsp += slope * sin(ground_angle)
	abs_gsp = abs(host.gsp)
	if !host.control_locked:
		if host.direction.x != 0 and host.direction.x == -gsp_dir:
			if abs_gsp > 0 :
				var braking_dec : float = host.ROLLDEC
				host.gsp += braking_dec * host.direction.x
		else:
			host.gsp -= min(abs_gsp, host.FRC / 2.0) * gsp_dir
			abs_gsp = abs(host.gsp)
	
	if abs_gsp <=61.875:
		return "OnGround"
	
	if host.is_wall_right && host.gsp > 0 || host.is_wall_left && host.gsp < 0:
		return "OnGround"
	
	host.gsp = .0 if host.is_wall_left and host.gsp < 0 else host.gsp
	host.gsp = .0 if host.is_wall_right and host.gsp > 0 else host.gsp
	host.speed.x = host.gsp * cos(ground_angle)
	host.speed.y = host.gsp * -sin(ground_angle)
	
	if !host.can_fall || (abs(rad2deg(ground_angle)) <= 30 && host.rotation != 0):
		host.snap_to_ground()

func animation_step(host, animator, delta):
	var gsp_dir = sign(host.gsp)
	var anim_name = idle_anim
	var anim_speed = 1.0
	var abs_gsp = abs(host.gsp);
	host.characters.global_rotation = 0;
	var side = sign(host.characters.scale.x);
	side = 1 if side == 0 else side
	host.sprite.offset = \
		Vector2(-16, -15) + \
		(Vector2(sin(host.characters.rotation), cos(host.characters.rotation)) *\
		Vector2(5 * side, 5))
	if side == 0: side = 1
	anim_name = 'Rolling'
	anim_speed = -((5.0 / 60.0) - (abs_gsp / 120.0))
	var host_char = host.characters
	var char_rotation = host_char.rotation_degrees;
	var host_rotation = host.rotation_degrees
	var abs_crot = abs(host_rotation)
	host_char.rotation += (-host_char.rotation) * (2 * delta)
	if abs_crot < .05:
		host_char.rotation = 0
	anim_speed = max(-(8.0 / 60.0 - (abs_gsp / 120.0)), 1.6)
	if gsp_dir != 0:
		host_char.scale.x = gsp_dir

	animator.animate(anim_name, anim_speed);

func _on_CharAnimation_animation_finished(anim_name):
	pass

func state_input(host, event):
	if event.is_action_pressed("ui_jump_i%d" % host.player_index):
		return host.jump()
