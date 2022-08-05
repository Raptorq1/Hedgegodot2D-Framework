extends Shield

onready var back: AnimatedSprite = $Back
onready var fore: AnimatedSprite = $Fore
onready var anim_player : AnimationPlayer = $AnimationPlayer

func use_hability(host : PlayerPhysics):
	host.speed.x = 560 * host.side
	host.speed.y = 0
	host.audio_player.play("fire_shield_dash")
	anim_player.play("dash")
	set_updatable(true)
	emit_signal("hability_used")

func reset():
	anim_player.play("default")
	set_updatable(false)
	emit_signal("hability_ended")

func on_update(host, delta):
	if abs(host.speed.x) >= 300 and host.is_attacking and !host.is_grounded and host.speed.y >= 0:
		anim_player.playback_speed = min(host.speed.x / 560.0, 2.0)
	else:
		reset()
