extends State

var follow_player : bool = false
var follow_player_slowly := false
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var selected_player

func _init() -> void:
	set_state_physics_processing(false)
	

func state_enter(host, prev_state):
	host.charging = false
	host.shoot = false
	host.tween.interpolate_property(host, "position:y", host.position.y, -host.area.extents.y * 1.5, 0.75,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	host.tween.start()
	host.flyup_sfx.play()
	if host.hp < 2:
		follow_player_slowly = true
	host.tween.connect("tween_all_completed", self, "flyed_up", [host], CONNECT_ONESHOT)

func flyed_up(host):
	set_state_physics_processing(true)
	host.get_tree().create_timer(0.75).connect("timeout", self, "start_shoot_down_mechanic", [host])

func state_physics_process(host, delta: float) -> void:
	if follow_player:
		seek_player(host, delta)
	elif follow_player_slowly:
		seek_player_slowly(host, delta)

func seek_player(host, _delta):
	var player_pos = host.area.to_local(selected_player.position).x
	host.position.x = player_pos

func seek_player_slowly(host, delta):
	var player_pos = host.area.to_local(selected_player.position).x
	var diff : float = player_pos - host.position.x
	host.position.x += sign(diff) * 100 * delta

func start_shoot_down_mechanic(host):
	var times = 3
	rng.randomize()
	follow_player = true
	
	_shoot_alert(host, times)

func _shoot_alert(host, times):
	if times > 0:
		selected_player = Utils.UArray.pick_random_index(host.area.players)
		host.laser_preview.visible = true
		host.target_sfx.play()
		var hp_fract = host.hp /25
		get_tree().create_timer(0.7).connect("timeout", self, "_wait_to_shoot", [host, times, hp_fract], CONNECT_ONESHOT)
	else:
		stop_shooting(host)

func _wait_to_shoot(host, times, hp_fract):
	follow_player = false
	get_tree().create_timer(0.5 - hp_fract).connect("timeout", self, "_shoot_down", [host, times, hp_fract], CONNECT_ONESHOT)

func _shoot_down(host, times, hp_fract):
	host.shoot  = true
	host.target_sfx.stop()
	host.laser_preview.visible = false
	get_tree().create_timer(1.25-hp_fract).connect("timeout", self, "_wait_to_repeat", [host, times], CONNECT_ONESHOT)

func _wait_to_repeat(host, times):
	host.shoot = false
	follow_player = true
	host.get_tree().create_timer(0.5).connect("timeout", self, '_shoot_alert', [host, times - 1], CONNECT_ONESHOT)

func stop_shooting(host):
	follow_player_slowly = false
	set_state_physics_processing(false)
	host.shoot = false
	follow_player = false
	host.tween.interpolate_property(host, "position", host.position, host.give_point_to_go(), 0.75,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	host.tween.start()
	host.flyup_sfx.play()
	host.tween.connect("tween_all_completed", self, "finish", ["Idle"], CONNECT_ONESHOT)

func state_animation_process(host, delta, animator):
	if animator.current_animation == "Appear":return
	var anim = "Idle"
	if host.charging:
		anim = "flash"
		host.character.material = host.shooting_material
	if host.shoot:
		anim = "laserShoot"
		host.character.material = host.shooting_material
	
	animator.animate(anim)

func state_exit(host, next_state):
	set_process(false)
