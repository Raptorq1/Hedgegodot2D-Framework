extends State


func enter(host, prev_state):
	pass

func step(host, delta):
	host.speed.x = host.max_speed.x * Utils.Math.bool_sign(host.to_right)

func animation_step(host, animator, delta):
	animator.animate("Walking")

func exit(host, next_state):
	host.speed.x = 0
