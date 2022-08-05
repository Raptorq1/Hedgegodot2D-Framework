extends SoundMachine

func _init() -> void:
	sound_collection = SoundCollection.new({
		'Destroy': preload("res://game-assets/audio/sfx/destroy.wav"),
		'CliffBreaking': preload('res://game-assets/audio/sfx/cliff-breaking.wav'),
		'WallBreak': preload('res://game-assets/audio/sfx/cliff-break.wav'),
		'MenuAccept': preload('res://game-assets/audio/sfx/menu-accept.wav'),
		'AlternativeMenuAccept': preload("res://game-assets/audio/sfx/sonic-2-turning-supersonic.wav"),
		'MenuBleep': preload('res://game-assets/audio/sfx/menu-bleep.wav'),
		'MenuWoosh': preload('res://game-assets/audio/sfx/menu-woosh.wav'),
		'Flash': preload('res://game-assets/audio/sfx/test-zone/act-1/bosses/minor-boss/HHWFlash.wav')
	})
