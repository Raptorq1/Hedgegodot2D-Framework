extends State


func state_enter(host, prev_state):
	set_state_physics_processing(true)
	host.spawn_blot()
	host.speed.x = 0

func state_physics_process(host, delta):
	if !host.was_side_switched:
		host.jump()
		return
	else:
		set_state_physics_processing(false)

func state_animation_process(host, delta, animator):
	var anim_name = "jumping"
	if host.was_side_switched:
		anim_name = "flipping"
	animator.animate(anim_name, 1.0, true)

func state_animation_finished(host, anim_name):
	match anim_name:
		"flipping":
			host.to_right = host.next_side
			host.animator.animate("RESET")
			host.jump()

func state_exit(host, next_state):
	host.was_side_switched = false
	host.splats_land_sfx.play()
