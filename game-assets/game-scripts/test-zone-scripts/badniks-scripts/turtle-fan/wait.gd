extends State

func enter(host, prev_state):
	if !host.target_sighted:
		get_tree().create_timer(0.5).connect("timeout", self, "when_end", [host, "Move"])
	else:
		change_push_position(host)
func animation_step(host, animator, delta):
	animator.animate("RESET")

func when_end(host, to):
	host.character.scale.x = Utils.Math.bool_sign(host.to_right)
	finish(to)
	
func change_push_position(host):
	host.character.scale.x = sign(host.pos_entered.x)
	if host.character.scale.x == 0:
		host.character.scale.x = 1
	yield(get_tree().create_timer(0.1), "timeout")
	if host.pos_entered:
		if host.pos_entered.y < host.choose_position.position.y:
			host.target_h = false
		else:
			host.target_h = true
	finish("Blowing")
