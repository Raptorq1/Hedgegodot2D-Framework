extends State

func enter(host : PlayerPhysics, prev_state : String):
	host.speed = Vector2.ZERO

func step(host : PlayerPhysics, delta: float):
	var ground_angle = host.ground_angle()
	var slope = -host.SLPROLLDOWN
	host.gsp += slope * sin(ground_angle)
	host.gsp -= min(abs(host.gsp), host.FRC) * sign(host.gsp)
	if host.gsp > .1:
		return 'OnGround'
	if !host.is_grounded:
		return 'OnAir'

func animation_step(host: PlayerPhysics, animator: CharacterAnimator, delta:float):
	var play_speed = 1.25
	var animation = 'LookUp'
	if host.direction.y > -1:
		animation = 'UpToIdle'
	#print(animator.current_animation)
	animator.animate(animation, play_speed, true)

func _on_animation_finished(host:PlayerPhysics, anim_name: String):
	match anim_name:
		'UpToIdle':
			host.fsm.change_state('Idle')
