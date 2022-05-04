extends Node

class_name StateChar

signal finished(next_state)
var character

func _post_ready():
	character.owner.fsm.setup_sub_state(self)

func _exit_tree():
	character.owner.fsm.shutdown_sub_state(self)

func enter(host: PlayerPhysics, prev_state:String, main_state:State = null):
	return

func step(host: PlayerPhysics, delta: float, main_state:State = null):
	return

func exit(host: PlayerPhysics, next_state:String, main_state:State = null):
	return

func animation_step(host: PlayerPhysics, animator: CharacterAnimator, delta : float, main_state:State = null, args:Array = []):
	return

func state_input(host : PlayerPhysics, event: InputEvent, main_state:State = null):pass

func _on_animation_finished(host:PlayerPhysics, anim_name: String, state:State = null):
	pass

func draw(host: PlayerPhysics, state:State):
	pass

func get_class():
	return "StateChar"

func is_class(name:String):
	return get_class() == name || .is_class(name)

func finish(next_state: String):
	emit_signal("finished", next_state)
