extends Node
class_name State

signal finished(next_state)

var sub_state
var _can_animate: bool = true

func do_not_animate():
	_can_animate = false

func animate_again():
	_can_animate = true

func enter(host, prev_state:String):
	pass
	
func step(host, delta: float):
	pass
func exit(host, next_state:String):
	pass

func animation_step(host, animator: CharacterAnimator, delta:float):
	pass

func _on_animation_finished(host, anim_name: String):
	pass

func _on_animation_started(host, anim_name: String):
	pass

func state_input (host, event : InputEvent):pass

func get_class():
	return "State"

func is_class(name:String):
	return get_class() == name || .is_class(name)

func finish(next_state: String):
	emit_signal("finished", next_state)

func draw(host):
	pass
