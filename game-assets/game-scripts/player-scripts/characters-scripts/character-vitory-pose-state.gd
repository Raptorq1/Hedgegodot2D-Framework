extends StateChar

var jumped : bool = false
var grounded : bool = false
var landed : bool = false

func enter(host, prev_state, state = null):
	if !jumped:
		host.direction = Vector2.ZERO
		host.is_grounded = false
		host.snap_margin = 0
		host.speed = Vector2(host.acc * 8 * host.side, -200)
		host.speed = host.move_and_slide_preset()
		jumped = true

func step(host, delta, state=null):
	var delta_final = delta * 70
	if !host.is_grounded:
		host.speed.y += host.grv * (delta * 60)
		if host.speed.y < 0 and host.speed.y > -240:
			host.speed.x -= (host.speed.x/0.125)/435 * delta_final
	else:
		if jumped:
			grounded = true
		if grounded:
			host.speed.x = 0
			host.speed.y = 0

func animation_step(host, animator, delta, state = null, arr=[]):
	var idle_name = "Victory"
	var anim_name = "Loop"
	if !host.is_grounded:
		if host.speed.y < 0:
			anim_name = "Jump"
		else:
			anim_name = "Fall"
	else:
		if jumped:
			if !landed or !grounded:
				anim_name = "Land"
				grounded = true
			if landed:
				anim_name = "Loop"
	
	animator.animate(idle_name + anim_name)

func land_ends():
	landed = true
