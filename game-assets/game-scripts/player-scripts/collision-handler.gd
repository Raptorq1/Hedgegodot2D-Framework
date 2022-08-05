extends Object

var host

func _init(_host) -> void: host = _host

func step_collision(delta):
	setup_collision()
	check_if_can_break()

func setup_collision():
	host.main_collider.shape = host.char_default_collision.shape if !host.roll_anim else host.char_roll_collision.shape
	host.main_collider.position = host.char_default_collision.position if !host.roll_anim else host.char_roll_collision.position
	host.attack_shape.shape = host.selected_character_node.current_attack_shape.shape
	host.attack_shape.position = host.selected_character_node.current_attack_shape.position
	host.hitbox_shape.shape = host.main_collider.shape
	host.hitbox_shape.position = host.main_collider.position

func check_if_can_break():
	#var cannot_break_bottom = host.speed.y > 0 or !host.roll_anim
	host.set_collision_mask_bit(7, host.speed.y >= 0)
	var cannot_break_top = host.speed.y > 0 and host.roll_anim
	host.set_collision_mask_bit(8, !cannot_break_top)
	host._set_can_break_wall(!(abs(host.gsp) > 270 and host.fsm.is_current_state("Rolling") and host.is_grounded))
	
	# invert roll_anim
	var inv_roll_anim = !host.roll_anim
	host.set_collision_mask_bit(6, inv_roll_anim)

func is_colliding_on_wall(wall_sensor : RayCast2D) -> bool:
	var collider = wall_sensor.get_collider()
	if collider:
		var one_way = Utils.Collision.is_collider_oneway(wall_sensor, collider)
		var coll_angle = abs(floor(wall_sensor.get_collision_normal().angle()))
		var grounded_wall : bool
		grounded_wall = is_equal_approx(coll_angle, PI)
		grounded_wall = grounded_wall or is_equal_approx(coll_angle, 0)
		grounded_wall = grounded_wall and host.is_grounded and host.ground_mode != 0
		var air_wall = \
			abs(host.rotation) > deg2rad(15) and !host.is_grounded
		if one_way or grounded_wall or air_wall:
			return false
		return true
	return false

func is_pushing_wall() -> bool:
	return (host.is_wall_right and host.gsp > 0) or (host.is_wall_left and host.gsp < 0)

func get_ground_ray() -> RayCast2D:
	host.can_fall = true
	
	if !host.left_ground.is_colliding() && !host.right_ground.is_colliding():
		return null
	elif !host.left_ground.is_colliding() && host.right_ground.is_colliding():
		return host.right_ground
	elif !host.right_ground.is_colliding() && host.left_ground.is_colliding():
		return host.left_ground
	
	host.can_fall = false
	
	var left_point : float
	var right_point : float
	
	var l_relative_point : Vector2 = host.left_ground.get_collision_point() - host.position
	var r_relative_point : Vector2 = host.right_ground.get_collision_point() - host.position
	
	left_point = sin(host.rotation) * l_relative_point.x + cos(host.rotation) + l_relative_point.y
	right_point = sin(host.rotation) * r_relative_point.x + cos(host.rotation) + r_relative_point.y

	if left_point <= right_point:
		return host.left_ground
	else:
		return host.right_ground

func snap_to_ground() -> void:
	var ground_ang = ground_angle()
	var g_angle_final = Utils.Math.rad2slice(ground_ang, 8)
	#var g_angle_final = ground_ang
	#host.previous_rotation = host.rotation
	host.rotation = -g_angle_final
	host.speed += -host.ground_normal * 150

func ground_reacquisition() -> void:
	var ground_angle = ground_angle();
	var angle_speed : Vector2
	angle_speed.x = cos(ground_angle) * host.speed.x
	angle_speed.y = -sin(ground_angle) * host.speed.y
	var converted_speed = angle_speed.x + angle_speed.y
	host.gsp = converted_speed

func ground_angle() -> float:
	return host.ground_normal.angle_to(Vector2(0, -1))

func is_on_ground() -> bool:
	var ground_ray = get_ground_ray()
	if ground_ray != null:
		var point = ground_ray.get_collision_point()
		var normal = ground_ray.get_collision_normal()
		if abs(rad2deg(normal.angle_to(Vector2(0, -1)))) < 90:
			var player_pos = host.global_position.y+ 10 + (Utils.Collision.get_height_of_shape(host.main_collider.shape))
			var to_return = player_pos > point.y
			return to_return
	
	return false

func fall_from_ground() -> bool:
	if should_slip():
		
		var deg_angle = rad2deg(ground_angle())
		var angle = abs(deg_angle)
		var r_angle = round(angle)
		
		host.lock_control()
		if r_angle >= 90 and r_angle <= 180:
			host.ground_mode = 0
			return true
		else:
			host.gsp += 2.5 * Utils.Math.bool_sign((deg_angle + 180) < 180)
	return false

func should_slip() -> bool:
	if abs(host.gsp) < host.fall and host.ground_mode != 0:
		return true
	return false
