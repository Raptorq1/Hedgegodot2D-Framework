extends State

func step(host, delta):
	can_break(host)

func can_break(host: PlayerPhysics):
	var cannot_break_bottom = host.speed.y > 0 or !host.roll_anim
	host.set_collision_mask_bit(7, host.speed.y >= 0)
	host.set_collision_layer_bit(7, host.speed.y >= 0)
	var cannot_break_top = host.speed.y < 0 or !host.roll_anim
	host.set_collision_mask_bit(8, cannot_break_top)
	host.set_collision_layer_bit(8, cannot_break_top)
