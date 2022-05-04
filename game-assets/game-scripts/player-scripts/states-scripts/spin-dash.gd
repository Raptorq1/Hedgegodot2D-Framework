extends State

var p : float # spin dash release power

func enter(host, prev_state):
	p = 0
	host.player_vfx.play('ChargeDust', false)
	host.audio_player.play('spin_dash_charge')

func step(host, delta):
	
	host.character.rotation = 0
	
	p = min(p, 480)
	p -= int(p / 7.5)

func exit(host, next_state):
	host.gsp = (480 + (floor(p) / 2)) * host.character.scale.x
	host.player_vfx.stop('ChargeDust')
	host.audio_player.stop('spin_dash_charge')
	host.audio_player.play('spin_dash_release')

func animation_step(host, animator, delta):
	animator.animate('SpinDashCharge', 3.0, false)
	pass

func state_input(host, event):
	if event.is_action_released("ui_down_i%d" % host.player_index):
		finish("Rolling")
	
	if event.is_action_pressed("ui_jump_i%d" % host.player_index):
		p += 120
		host.animation.stop(true)
		host.audio_player.play('spin_dash_charge')
