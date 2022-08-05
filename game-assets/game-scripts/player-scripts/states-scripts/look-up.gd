extends State

func state_enter(host : PlayerPhysics, prev_state : String):
	host.gsp = 0
	host.speed = Vector2.ZERO

func state_physics_process(host : PlayerPhysics, delta: float):
	var ground_angle = host.coll_handler.ground_angle()
	var slope = -host.slp_roll_down
	host.gsp += slope * sin(ground_angle)
	host.gsp -= min(abs(host.gsp), host.frc) * sign(host.gsp)
	if host.gsp > .1:
		finish("OnGround")
	if !host.is_grounded:
		finish("OnAir")

func state_animation_process(host, delta:float, animator: CharacterAnimator):
	var play_speed = 1.5
	var animation = 'LookUp'
	if host.direction.y > -1:
		animation = 'UpToIdle'
	#print(animator.current_animation)
	animator.animate(animation, play_speed, true)

func state_animation_finished(host:PlayerPhysics, anim_name: String):
	match anim_name:
		'UpToIdle':
			finish("Idle")
