extends State

var point : Vector2
func enter(host, prev_state):
	point = host.give_point_to_go()
	var min_dist = 125 if !host.shoot else 250
	while host.position.distance_to(point) < min_dist:
		point = host.give_point_to_go()

func step(host, delta):
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

func animation_step(host, animator, delta):
	if animator.current_animation == "Appear":return
	var anim = "Idle"
	if host.charging:
		anim = "flash"
		host.modulate.r = 3.0
	if host.shoot:
		anim = "laserShoot"
		host.modulate.r = 3.0
	
	animator.animate(anim)
