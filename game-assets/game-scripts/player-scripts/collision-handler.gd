extends Node

var host

func on_host_ready(host_):
	host = host_

func _on_AttackBox_body_entered(body):
	if body is Badnik:
		var badnik: Badnik = body
		body.explode(host)

func update_collision(host, delta):
	host.main_collider.shape = host.char_default_collision.shape if !host.roll_anim else host.char_roll_collision.shape
	host.main_collider.position = host.char_default_collision.position if !host.roll_anim else host.char_roll_collision.position
	host.attack_shape.shape = host.selected_character_node.current_attack_shape.shape
	host.attack_shape.position = host.selected_character_node.current_attack_shape.position
	host.hitbox_shape.shape = host.main_collider.shape
	host.hitbox_shape.position = host.main_collider.position

func _on_HitBox_body_entered(body):
	if body is Badnik:
		if host.roll_anim:
			body.explode(host)
		else:
			if body.can_hurt:
				body.push_player(host)
	elif body.is_class("Boss"):
		var boss = body
		if host.roll_anim and !boss.damage_only:
			if !boss.can_take_hit : return
			boss.damage()
			host.speed *= -0.5
		else:
			host.damage(boss.position.direction_to(host.position))

func is_colliding_on_wall(wall_sensor : RayCast2D) -> bool:
	var collider = wall_sensor.get_collider()
	if collider:
		var one_way = Utils.Collision.is_collider_oneway(wall_sensor, collider)
		var coll_angle = abs(floor(wall_sensor.get_collision_normal().angle()))
		var grounded_wall : bool
		grounded_wall = is_equal_approx(coll_angle, PI)
		grounded_wall = grounded_wall or is_equal_approx(coll_angle, 0)
		grounded_wall = grounded_wall and host.is_grounded
			
		var air_wall = \
			abs(host.rotation) > deg2rad(15) and !host.is_grounded
		if one_way or grounded_wall or air_wall:
			return false
		return true
	return false
