extends ItemBox

func _action(player : PlayerPhysics) -> void:
	player.audio_player.play("fire_shield_catch")
	player.shield_container.attach_shield(get_node("/root/AutoloadCharacters").Shields.FIRE)
