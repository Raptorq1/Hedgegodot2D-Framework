extends Node
class_name FSM

signal activate_switch(current)
signal state_changed(prev_state, current_state, host)

onready var states:Dictionary
export var activated : bool = true setget set_activated
export var move_and_slide : bool = true
var host

export var initial_state :String = 'OnGround'
onready var current_state = initial_state setget change_state

var previous_state = null

func _enter_tree() -> void:
	set_physics_process(false)

func _on_host_ready(host_):
	for i in get_children():
		if i.is_class("State"):
			states[i.name] = i
	get_current_state_node().connect("finished", self, "change_state")
	on_host_ready_ext(host_)
	set_physics_process(true)
	set_process_input(true)
	host = host_
	if !activated:
		yield(self, "activate_switch")
	get_current_state_node().enter(host, "")

func on_host_ready_ext(host_):pass

func get_current_state_node():
	if states.has(current_state):
		return states[current_state]

func is_current_state(name:String) -> bool:
	return current_state == name

func _physics_process(delta):
	#if !host.char_default_collision_air:
	if !is_physics_processing():
		return
	host.physics_step(delta)
	
	collision_process(delta)
	
	if states.has("Global"):
		states["Global"].step(host, delta)
	var cur_state = get_current_state_node()
	cur_state.step(host, delta)
	cur_state = get_current_state_node()
	
	host.prev_position = host.position
	if move_and_slide:
		host.speed = host.move_and_slide_preset()
	
	physics_process_ext(delta)

func collision_process(delta):pass

func physics_process_ext(delta):
	get_current_state_node().animation_step(host, host.animator, delta)

func change_state(state_name):
	assert(states.has(state_name) or host.char_fsm.states.has(state_name), "Error: State %s does not exist in current context" % state_name)
	if state_name == current_state:
		return
	
	#Exit
	var cur_state = get_current_state_node()
	cur_state.disconnect("finished", self, "change_state")
	cur_state.exit(host, state_name)
	previous_state = current_state
	current_state = state_name
	
	#Enter
	cur_state = get_current_state_node()
	cur_state.connect("finished", self, "change_state")
	cur_state.enter(host, previous_state)
	emit_signal('state_changed', previous_state, current_state, host)

func do_not_process_state_until(from: Node, signal_name: String):
	set_activated(false)
	yield(from, signal_name)
	set_activated(true)

func insert_state(state: Node, change: bool = true) -> void:
	add_child(state)
	states[state.name] = state
	if change:
		change_state(state.name)

func erase_state(state: Node, next_state: String = "OnAir") -> void:
	change_state(next_state)
	if states.has(state.name):
		states.erase(state.name)
	state.queue_free()

func set_activated(val : bool) -> void:
	activated = val
	set_physics_process(activated)
	set_process_input(activated)
	emit_signal("activate_switch", activated)
