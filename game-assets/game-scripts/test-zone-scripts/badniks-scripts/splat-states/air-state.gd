extends State

func state_enter(host, next_state): pass

func state_physics_process(host, delta):
	if host.speed.y > 0:
		host.can_hurt = true
		host.z_index = 0
	host.speed.x += host.air_fric * Utils.Math.bools_sign(host.speed.x > 0, host.speed.x < 0) * delta
	host.speed.y += host.grav * delta
	if host.is_on_floor():
		finish("OnGround")

func state_animation_process(host, delta, animator):
	if host.speed.y > 0:
		animator.animate("falling")

func state_exit(host, prev_state):
	pass
