extends Node2D
export var bullet_scene:PackedScene

func _on_Area_body_entered(body):
	if body.is_class("PlayerPhysics"):
		var dir = sign(body.gsp) if body.gsp !=0 else 1
		if body.is_grounded:
			spawnBullet(\
				Vector2((20 * -dir), -300),\
				Vector2(0, -5)\
			);
			var abs_gsp = abs(body.gsp)
			if abs_gsp < 700:
				body.gsp = 700 * dir
			elif abs_gsp < 1100:
				body.gsp += 150 * dir

func spawnBullet(speed:Vector2, pos:Vector2):
	var bullet:Node2D = bullet_scene.instance();
	bullet.speed = speed;
	bullet.position = global_position + pos
	bullet.set("spawnpoint", bullet.get("global_position"))
	get_parent().add_child(bullet);
	bullet.sprite.rotate(rotation + (1 * int(rotation == 0)))
	bullet.sprite.scale.x = -sign(speed.x) if speed.x != 0 else 1
