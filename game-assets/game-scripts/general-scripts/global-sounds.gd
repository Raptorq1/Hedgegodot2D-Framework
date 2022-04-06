extends AudioPlayer

func _enter_tree() -> void:
	audios = {
		'Destroy': preload("res://game-assets/audio/sfx/destroy.wav"),
		'CliffBreaking': preload('res://game-assets/audio/sfx/cliff-breaking.wav'),
		'WallBreak': preload('res://game-assets/audio/sfx/cliff-break.wav'),
		'MenuAccept': preload('res://game-assets/audio/sfx/MenuAccept.wav'),
		'AlternativeMenuAccept': preload("res://game-assets/audio/sfx/sonic-2-turning-supersonic.wav"),
		'MenuBleep': preload('res://game-assets/audio/sfx/MenuBleep.wav'),
		'MenuWoosh': preload('res://game-assets/audio/sfx/MenuWoosh.wav'),
		'Flash': preload('res://game-assets/audio/sfx/test-zone/act-1/bosses/minor-boss/HHWFlash.wav')
	}
