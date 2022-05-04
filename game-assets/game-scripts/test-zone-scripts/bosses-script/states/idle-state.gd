extends State

var times : int = TIMES_PRESET
const TIMES_PRESET : int = 4

func enter(host, prev_state):
	host.speed = Vector2.ZERO
	wait(host)
	times -= 1

func wait(host):
	var next_state = "Moving"
	var time_to_wait = .75
	if times <= 1 and times > 0:
		host.charging = true
		time_to_wait = 1.25
	elif times <= 0:
		times = TIMES_PRESET + 1
		next_state = "UpScreen"
	var hp_fract = host.hp /25
	yield(get_tree().create_timer(time_to_wait-hp_fract), "timeout")
	finish(next_state)

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
