extends State

var slope : float

func enter(host : PlayerPhysics, prev_state):
	pass
	host.speed = Vector2.ZERO
	host.direction = Vector2.ZERO
	host.gsp = 0
	host.character.rotation = 0

func step(host : PlayerPhysics, delta):
	var ground_angle = host.ground_angle()
	slope = -host.slp
	host.gsp += slope * sin(ground_angle)
	host.gsp -= min(abs(host.gsp), host.frc) * sign(host.gsp)
	if host.constant_roll:
		finish("Rolling")
		return
	if abs(host.gsp) >= 0.1:
		finish("OnGround")
		return
	
	if !host.is_ray_colliding or host.fall_from_ground() or !host.is_on_ground():
		host.is_grounded = false
		host.snap_margin = 0
		finish("OnAir")
		return
	
	if !host.can_fall || (abs(rad2deg(ground_angle)) <= 30 && host.rotation != 0):
		host.snap_to_ground()
		finish("OnGround")
		return
	
	#host.speed.x = host.gsp * cos(ground_angle)
	#host.speed.y = host.gsp * -sin(ground_angle);

func animation_step(host: PlayerPhysics, animator: CharacterAnimator, delta:float):
	animator.animate('Idle', 1.0, true)

func state_input(host, event):
	if host.direction != Vector2.ZERO:
		if host.direction.x != 0:
			finish("OnGround")
			return
		if host.direction.y > 0:
			if host.gsp > host.min_to_roll:
				finish("Rolling")
				return
			finish("Crouch")
			return
		else:
			finish("LookUp")
			return
	if event.is_action_pressed('ui_jump_i%d' % host.player_index):
		finish(host.jump())
