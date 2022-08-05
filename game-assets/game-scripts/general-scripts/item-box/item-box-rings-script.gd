extends ItemBox

func _action(player : PlayerPhysics) -> void:
	var sound:SoundMachine = player.get_node("AudioPlayer");
	sound.play('ring')
	player.rings += 10 
