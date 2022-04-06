extends Badnik

onready var animator : AnimationPlayer = $Container/Sprite/AnimationPlayer
onready var container : Node2D = $Container
var moving : bool = false
var was_side_switched : bool = false
var next_wait_step


func _physics_process(delta):
	if speed.y > 0:
		z_index = 1
		can_hurt = true
	speed.y += delta * 500
	speed.x += -sign(speed.x) * delta * 50
	speed = move_and_slide(speed, Vector2.UP)
	if abs(speed.x) < 0.5:
		speed.x = 0
		
	

	if !is_on_floor():
		if speed.y < 0:
			animator.animate("jumping")
		else:
			animator.animate("falling")
	else:
		if was_side_switched:
			if next_wait_step:
				next_wait_step.resume()
			return
		wait_to_jump()
		animator.animate("jumping")
	

func jump():
	if !is_on_floor(): return
	var delta = get_physics_process_delta_time()
	speed.y = -7000 * delta
	speed.x = 7000 * delta * Utils.Math.bool_sign(to_right)

func wait_to_jump():
	if was_side_switched:return
	speed.x = 0
	animator.animate("RESET")
	set_physics_process(false)
	yield(get_tree().create_timer(0.1),"timeout")
	set_physics_process(true)

func wait(side = false):
	yield()
	set_physics_process(false)
	speed.x = 0
	animator.animate("RESET")
	yield(get_tree().create_timer(.1),"timeout")
	if was_side_switched:
		animator.animate("Flipping")
		yield(animator,"animation_finished")
		animator.animate("RESET")
		yield(animator, "animation_finished")
		set_to_right(side)
		$Container/Sprite.position.x = -18 if to_right else -14
		was_side_switched = false
		
	yield(get_tree().create_timer(0.5),"timeout")
	set_physics_process(true)
	
func set_to_right(val : bool):
	to_right = val
	container.scale.x = -Utils.Math.bool_sign(to_right)

func side_switch(value : bool):
	if to_right == value:
		return
	was_side_switched = true
	next_wait_step = wait(value)
