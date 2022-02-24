extends State

var slope : float

func enter(host : PlayerPhysics, prev_state):
	host.speed = Vector2.ZERO
	host.direction = Vector2.ZERO
	host.gsp = 0
	host.characters.rotation = 0

func step(host : PlayerPhysics, delta):
	var ground_angle = host.ground_angle()
	slope = -host.SLP
	host.gsp += slope * sin(ground_angle)
	host.gsp -= min(abs(host.gsp), host.FRC) * sign(host.gsp)
	if host.constant_roll:
		return 'Rolling'
	if host.gsp != 0:
		if host.direction.y > 0:
			return 'Rolling'
		return 'OnGround'
	if host.direction != Vector2.ZERO:
		if host.direction.x != 0:
			return 'OnGround'
	
	if host.ground_mode != 0 or !host.is_grounded:
		return 'OnAir'
	
	#host.speed.x = host.gsp * cos(ground_angle)
	#host.speed.y = host.gsp * -sin(ground_angle);

func animation_step(host: PlayerPhysics, animator: CharacterAnimator, delta:float):
	animator.animate('Idle', 1.0, true)

func state_input(host, event):
	if host.direction.y != 0:
		if host.direction.y > 0:
			return 'Crouch'
		else:
			return 'LookUp'
	if event.is_action_pressed('ui_jump_i%d' % host.player_index):
		return host.jump()
