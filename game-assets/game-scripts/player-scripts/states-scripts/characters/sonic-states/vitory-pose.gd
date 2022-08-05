extends StateChar

var jumped : bool = false
var grounded : bool = false
var landed : bool = false

func state_enter(host, prev_state, state = null):
	if !jumped:
		host.direction = Vector2.ZERO
		host.is_grounded = false
		host.snap_margin = 0
		host.speed = Vector2(host.acc * 8 * host.side, -200)
		host.speed = host.move_and_slide_preset()
		jumped = true

func state_physics_process(host, delta, state=null):
	if !host.is_grounded:
		host.speed.y += host.grv
		if host.speed.y < 0 and host.speed.y > -240:
			host.speed.x -= (host.speed.x/7.5)/15360
	else:
		if jumped:
			grounded = true
		if grounded:
			host.speed.x = 0
			host.speed.y = 0

func state_animation_process(host, delta:float, animator, state = null, arr=[]):
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
