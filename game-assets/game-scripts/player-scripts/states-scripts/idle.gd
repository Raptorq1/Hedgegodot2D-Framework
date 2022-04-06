extends State

var slope : float

func enter(host : PlayerPhysics, prev_state):
	host.speed = Vector2.ZERO
	host.direction = Vector2.ZERO
	host.gsp = 0
	#host.character.rotation = 0

func step(host : PlayerPhysics, delta):
	var ground_angle = host.ground_angle()
	var delta_final = delta * 75
	slope = -host.slp
	host.gsp += slope * sin(ground_angle) * delta_final
	host.gsp -= min(abs(host.gsp), host.frc) * sign(host.gsp) * delta_final
	if host.constant_roll:
		finish("Rolling")
		return
	if abs(host.gsp) >= 1.1:
		finish("OnGround")
		return
	
	if host.ground_mode != 0 or !host.is_grounded:
		finish("OnAir")
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
