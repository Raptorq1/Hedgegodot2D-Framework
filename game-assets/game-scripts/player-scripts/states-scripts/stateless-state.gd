extends State

func enter(host, prev_state):
	pass
	host.speed = Vector2.ZERO
	host.gsp = 0
	host.direction = Vector2.ZERO
	host.characters.rotation = 0
	host.constant_roll = false
	host.sprite.offset = Vector2(-15, -15)
	host.spring_loaded = false
	host.spring_loaded_v = false
