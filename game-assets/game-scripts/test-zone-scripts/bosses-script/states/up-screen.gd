extends State

var follow_player : bool = false
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func enter(host, prev_state):
	host.charging = false
	host.shoot = false
	var tween = Tween.new()
	tween.interpolate_property(host, "position:y", host.position.y, -host.area.extents.y * 1.5, 0.75,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	add_child(tween)
	tween.start()
	host.flyup_sfx.play()
	yield(tween, "tween_all_completed")
	get_tree().create_timer(0.75).connect("timeout", self, "shoot_down", [host])

func step(host, delta):
	if follow_player:
		seek_player(host)

func seek_player(host):
	var player_pos = host.area.to_local(host.area.players[rng.randi_range(0, host.area.players.size()-1)].position).x
	host.position.x = player_pos

func shoot_down(host):
	var times = 3
	rng.randomize()
	follow_player = true
	
	wait_shoot(host, times)

func wait_shoot(host, times):
	#print(times)
	if times > 0:
		host.laser_preview.visible = true
		host.charge_sfx.play()
		yield(get_tree().create_timer(0.7), "timeout")
		follow_player = false
		yield(get_tree().create_timer(0.5), "timeout")
		host.shoot  = true
		host.laser_preview.visible = false
		yield(get_tree().create_timer(1.25), "timeout")
		host.shoot = false
		follow_player = true
		get_tree().create_timer(0.5).connect("timeout", self, 'wait_shoot', [host, times - 1])
	else:
		stop_shooting(host)

func stop_shooting(host):
	host.shoot = false
	follow_player = false
	var tween = Tween.new()
	tween.interpolate_property(host, "position", host.position, host.give_point_to_go(), 0.75,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	add_child(tween)
	tween.start()
	host.flyup_sfx.play()
	yield(tween, "tween_all_completed")
	finish("Idle")

func animation_step(host, animator, delta):
	if animator.current_animation == "Appear":return
	var anim = "Idle"
	if host.charging:
		anim = "flash"
		host.modulate.r = 3.0
	if host.shoot:
		anim = "laserShoot"
		host.modulate.r = 3.0
	
	animator.animate(anim)
