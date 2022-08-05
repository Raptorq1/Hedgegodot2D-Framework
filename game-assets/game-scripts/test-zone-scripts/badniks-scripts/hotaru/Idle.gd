extends State

var flipping = false
var getting_up = false
var stand_idle : = false

func state_enter(host, prev_state):
	host.get_tree().create_timer(1.5).connect("timeout", self, "get_up", [host])

func state_physics_process(host, delta):
	var origin_dist = host.position.x - host.origin_point
	host.speed.x += sign(Utils.Math.bool_sign(host.to_right)) * delta * 24
	host.speed.x = clamp(host.speed.x, -24, 24)
	var max_dist = 10
	if origin_dist < -max_dist:
		host.to_right = true
	elif origin_dist > max_dist:
		host.to_right = false
	var abs_speed = abs(host.speed.x)
	if abs_speed < 0.5:
		flipping = true
	host.position += host.speed * delta

func state_animation_process(host, delta, animator):
	var idle_name = "Idle"
	var anim_name = "Lying"
	var anim_speed = 1.0
	var animate_from_end:bool = false
		
	if flipping:
		idle_name = "Flipping"
	if getting_up:
		idle_name = "ChangingPose"
		anim_name = ""
	
	if !host.lying:
		host.character.scale.x = 1
		idle_name = "Flipping"
		anim_name = "Stand"
		if !host.to_right:
			anim_speed *= -1
			animate_from_end = true
	
	if animate_from_end:
		animator.animate_from_end(idle_name + anim_name, anim_speed)
	else:
		animator.animate(idle_name + anim_name, anim_speed)

func state_animation_finished(host, anim_name):
	if "Flipping" in anim_name:
		flipping = false
		if !host.lying:
			stand_idle = true
	else:
		match anim_name:
			"ChangingPose":
				getting_up = false
				host.lying = false
				flipping = false

func state_animation_started(host, anim_name):
	if "Flipping" in anim_name and host.lying:
		host.character.scale.x = Utils.Math.bool_sign(host.to_right)

func get_up(host):
	getting_up = true
	host.get_tree().create_timer(2.0).connect("timeout", self, "finish", ["StopToShoot"])
