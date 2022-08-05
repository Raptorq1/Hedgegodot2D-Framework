extends State


func state_enter(host, prev_state):
	pass

func state_physics_process(host, delta):
	host.speed.x = host.max_speed.x * Utils.Math.bool_sign(host.to_right)

func state_animation_process(host, delta, animator):
	animator.animate("Walking")

func state_exit(host, next_state):
	host.speed.x = 0
