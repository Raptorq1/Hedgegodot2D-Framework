extends State

var point : Vector2
func state_enter(host, prev_state):
	point = host.give_point_to_go()
	if !host.shoot:
		var min_dist = 125
		while host.position.distance_to(point) < min_dist:
			point = host.give_point_to_go()
	if prev_state == "Idle" and host.fsm.state_collection.get_state(prev_state).times < 2:
		var x = 190
		point.x = x if abs(x - host.position.x) > abs(-x - host.position.x) else -x

func state_physics_process(host, delta):
	var direction:Vector2 = (point - host.position).normalized()
	var motion: Vector2 = direction * host.speed * delta
	var distance_to_target = host.position.distance_to(point)
	#print(host.position.distance_to(point), " ", motion.length())
	
	if motion.length() > distance_to_target:
		host.speed = Vector2.ZERO
		finish("Idle")
		return
	else:
		var max_speed_selector
		
		var max_speed = host.max_speed_unit if !host.shoot else 250
		var speed_target = direction * max_speed
		if abs(host.speed.x) < max_speed:
			host.speed.x += (speed_target.x - host.speed.x) * delta
		if abs(host.speed.y) < max_speed:
			host.speed.y += (speed_target.y - host.speed.y) * delta
	
	host.position += host.speed * delta

func state_animation_process(host, delta, animator):
	if animator.current_animation == "Appear":return
	var anim = "Idle"
	if host.charging:
		anim = "flash"
		host.character.material = host.shooting_material
	if host.shoot:
		anim = "laserShoot"
		host.character.material = host.shooting_material
	
	animator.animate(anim)
