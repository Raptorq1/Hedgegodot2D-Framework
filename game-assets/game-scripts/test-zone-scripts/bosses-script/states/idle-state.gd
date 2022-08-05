extends State

var times : int = TIMES_PRESET
const TIMES_PRESET : int = 4

func state_enter(host, prev_state):
	host.speed = Vector2.ZERO
	wait(host)

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
	get_tree().create_timer(time_to_wait-hp_fract).connect("timeout", self, "finish", [next_state])
	times -= 1

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
