extends State
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var charging: bool = false
func state_enter(host, prev_state):
	rng.randomize()
	host.stand_sfx.play()
	host.get_tree().create_timer(1.0).connect("timeout", self, "start_charge", [host])

func start_charge(host):
	charging = true
	yield(host.get_tree().create_timer(0.5), "timeout")
	host.shoot_charge_sfx.play()
	host.beam_charge.visible = true
	host.beam_charge.play("default")
	yield(host.get_tree().create_timer(0.5), "timeout")
	host.shoot_sfx.play()
	shoot(host)

func shoot(host):
	var shoot = host.SHOOT.instance()
	var players = host.boss.area.players
	shoot.set_as_toplevel(true)
	shoot.global_position = host.global_position
	shoot.speed = shoot.global_position.direction_to(players[rng.randi_range(0,players.size() - 1)].global_position) * 200
	host.add_child(shoot)
	host.beam_charge.visible = false
	host.beam_charge.stop()
	host.lying = true
	finish("Rounding")

func state_animation_process(host, delta, animator):
	var anim_name = "IdleStandCenter"
	
	if charging:
		anim_name = "Charging"
	
	animator.animate(anim_name)
