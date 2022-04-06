extends Node

var host

func on_host_ready(host_):
	host = host_

func _on_AttackBox_body_entered(body):
	if body is Badnik:
		var badnik: Badnik = body
		body.explode(host)

func step_collision(host, delta):
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
	elif body is Boss:
		var boss := body as Boss
		if host.roll_anim and !boss.damage_only:
			if !boss.can_take_hit : return
			boss.damage()
			host.speed *= -0.5
		else:
			host.damage(boss.position.direction_to(host.position))
