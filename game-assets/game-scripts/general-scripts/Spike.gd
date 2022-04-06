tool
extends StaticNode2D

func _ready() -> void:
	rotation_degrees = floor(rotation_degrees)

func _on_Damage_body_entered(body: Node) -> void:
	if body.is_class("PlayerPhysics"):
		var player : PlayerPhysics = body
		#print(player.speed, player.gsp)
		var up_direction = -Utils.Math.angle2Vec2(rotation)
		var direction = Vector2.ZERO
		direction.x = -player.character.scale.x * cos(player.ground_angle())
		direction.y = -cos(player.ground_angle())
		direction = direction.sign()
		if !player.is_grounded:
			direction = global_position.direction_to(player.global_position).sign()
		player.damage(direction)


func _on_Damage_stay_inside(body : Node):
	if !body:
		return
	_on_Damage_body_entered(body)
