extends State

func enter(host, prev_state):
	pass

func step(host, delta):
	if host.is_pushing:
		for player in host.players_to_push:
			var p = player as PlayerPhysics
			var speed : Vector2 = Vector2.ZERO
			var calc = (host.global_position.distance_to(p.global_position)-450)/300
			if host.target_h:
				if sign(p.speed.x) == -sign(host.character.scale.x):
					speed.x = calc * (150 + abs(p.speed.x)) * sign(p.speed.x)
				else:
					speed.x = calc * 150 * -sign(host.character.scale.x)
				speed = p.move_and_slide_preset(speed)
			else:
				if p.speed.y > 0:
					p.speed.y += calc * (100 + abs(p.speed.y))
				else:
					p.speed.y = calc * (100)
			
func animation_step(host, animator, delta):
	if !_can_animate: return
	var anim_name
	
	if !host.is_pushing:
		if host.target_h:
			anim_name = "RotateToH"
		else:
			anim_name = "RotateToV"
	else:
		if host.target_h:
			anim_name = "FanH"
		else:
			anim_name = "FanV"
	
	animator.animate(anim_name)

func _on_animation_finished(host, anim_name: String):
	if "Rotate" in anim_name and host.target_sighted:
		host.fan.play()
		host.is_pushing = true
		yield(get_tree().create_timer(5.0), "timeout")
		(host.fan as AudioStreamPlayer2D).stop()
		host.is_pushing = false
		host.target_sighted = false
		do_not_animate()
		get_tree().create_timer(5.0).connect("timeout", host, "check_for_target")
		finish("Wait")
		animate_again()
