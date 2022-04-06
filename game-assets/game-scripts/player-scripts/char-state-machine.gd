extends Node
class_name CharFSM

var states : Dictionary = {}
var character

func _ready():
	for i in get_children():
		states[i.name] = i

func character_ready(character_):
	character = character_
	for i in states.values():
		i.character = character
		i._post_ready()

func disconnect_all_states(state_machine: FSM):
	for i in states.values():
		i.disconnect("finished", state_machine, "change_state")

func connect_all_states(state_machine : FSM):
	for i in states.values():
		i.connect("finished", state_machine, "change_state")
