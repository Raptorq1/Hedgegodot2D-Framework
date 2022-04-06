extends Area2D
class_name HurtableArea2DVariation

func _ready():
	connect("body_entered", self, "on_body_enter")

func on_player_damage(player:PlayerPhysics):
	pass

func push_player(player:PlayerPhysics):
	var direction = global_position.direction_to(player.global_position).sign()
	player.damage(direction);
	on_player_damage(player)

func on_body_enter(body):
	if body is PlayerPhysics:
		push_player(body)
