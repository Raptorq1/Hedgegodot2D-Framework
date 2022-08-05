extends Node
class_name FSM

signal state_changed(prev_state, current_state, host)
var _host_ready = false setget , is_host_ready
var state_collection:StateCollection = StateCollection.new() setget , get_state_collection
var host

export var initial_state:String = 'Idle'
onready var current_state = initial_state setget change_state

var previous_state = null

func _enter_tree() -> void:
	set_physics_process(false)
	set_process(false)
	set_process_input(false)

func _on_host_ready(host_):
	host = host_
	state_collection.generate_states(get_children())
	get_current_state_node().connect("finished", self, "change_state", [], CONNECT_ONESHOT)
	on_host_ready_ext(host_)
	get_current_state_node().state_enter(host, "")
	host.set_physics_process(true)
	set_process_input(true)
	_host_ready = true

func on_host_ready_ext(host_):pass

func get_current_state_node():
	#print(state_collection.has_state(current_state))
	if state_collection.has_state(current_state):
		return state_collection.get_state(current_state)

func is_current_state(name:String) -> bool:
	return current_state == name

func _fsm_physics_process(delta):
	var cur_state = get_current_state_node()
	if cur_state.is_state_physics_processing():
		cur_state.state_physics_process(host, delta)
		cur_state = get_current_state_node()

func _fsm_process(delta):
	var cur_state = get_current_state_node()
	if cur_state.is_state_processing():
		cur_state.state_process(host, delta)
		cur_state = get_current_state_node()
	if cur_state.is_state_animation_processing():
		cur_state.state_animation_process(host, delta, host.animator)

func change_state(state_name):
	assert(state_collection.has_state(state_name) or host.char_fsm.states.has(state_name), "Error: State %s does not exist in current context" % state_name)
	if state_name == current_state:
		return
	
	#Exit
	var cur_state = get_current_state_node()
	cur_state.disconnect("finished", self, "change_state")
	cur_state.state_exit(host, state_name)
	previous_state = current_state
	current_state = state_name
	
	#Enter
	cur_state = get_current_state_node()
	cur_state.connect("finished", self, "change_state")
	cur_state.state_enter(host, previous_state)
	
	#End
	emit_signal('state_changed', previous_state, current_state, host)

func insert_state(state: State, change: bool = true) -> void:
	state_collection.add_state(state.name, state)
	if change:
		change_state(state.name)

func erase_state(state_name:String, next_state: String = initial_state) -> void:
	change_state(next_state)
	if state_collection.has_state(state_name):
		state_collection.remove_state(state_name)

func get_state_collection() -> StateCollection: return state_collection

func is_host_ready() -> bool:
	return _host_ready


func _on_AnimationPlayer_animation_finished(anim_name):
	get_current_state_node().state_animation_finished(host, anim_name)
