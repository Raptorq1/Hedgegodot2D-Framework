extends State

func state_enter(host, prev_state):
	if !host.target_sighted:
		host.get_tree().create_timer(0.5).connect("timeout", self, "when_end", [host, "Move"])
	else:
		change_blow_side(host)
func state_animation_process(host, delta, animator):
	animator.animate("RESET")

func when_end(host, to):
	host.character.scale.x = Utils.Math.bool_sign(host.to_right)
	finish(to)
	
func change_blow_side(host):
	host.character.scale.x = sign(host.pos_entered.x) if host.pos_entered.x != 0 else 1
	yield(host.get_tree().create_timer(0.1), "timeout")
	if host.pos_entered:
		if host.pos_entered.y < host.choose_position.position.y:
			host.target_h = false
		else:
			host.target_h = true
	finish("Blowing")
