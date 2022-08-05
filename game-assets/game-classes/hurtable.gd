extends KinematicBody2D
class_name Hurtable

class RigidVariation extends RigidBody2D:
	func on_player_damage(player):
		pass

	func push_player(player):
		var distance = global_position.direction_to(player.global_position).sign()
		player.damage(distance);
		on_player_damage(player)

func on_player_damage(player):
	pass

func push_player(player):
	var distance = global_position.direction_to(player.global_position).sign()
	player.damage(Vector2(distance.x, -1));
	on_player_damage(player)
