extends FSM

var sub_state

func _enter_tree() -> void:
	set_physics_process(false)
	set_process_input(false)

func on_host_ready_ext(host_):
	if sub_state:
		sub_state.connect("finished", self, "change_state")

func get_current_state_node():
	if states.has(current_state):
		return states[current_state]
	elif host.char_fsm.states.has(current_state):
		return host.char_fsm.states[current_state]

func is_current_state(name:String) -> bool:
	return current_state == name

func physics_process_ext(delta):
	var cur_state = get_current_state_node()
	if !host.specific_animation_temp:
		cur_state.animation_step(host, host.animation, delta)
	
	cur_state = get_current_state_node()
	if sub_state:
		sub_state.step(host, delta, cur_state)
		cur_state = get_current_state_node()
		if !host.specific_animation_temp:
			sub_state.animation_step(host, host.animation, delta, cur_state)
	
	host.coll_handler.update_collision(host, delta)
	
	if host.player_camera:
		if !host.robot:
			host.fsm.set_process_input(true)
		if host.player_camera.enabled:
			host.player_camera.camera_step(host, delta)

func change_state(state_name):
	assert(states.has(state_name) or host.char_fsm.states.has(state_name), "Error: State %s does not exist in current context" % state_name)
	if state_name == current_state:
		return
	if host.specific_animation_temp:
		(host.animation as CharacterAnimator).playback_speed = 1.0
	host.specific_animation_temp = false
	
	#Exit
	var cur_state = get_current_state_node()
	cur_state.disconnect("finished", self, "change_state")
	if sub_state:
		sub_state.disconnect("finished", self, "change_state")
	cur_state.exit(host, state_name)
	if sub_state:
		sub_state.exit(host, state_name, cur_state)
	previous_state = current_state
	current_state = state_name
	sub_state = null
	
	#Enter
	cur_state = get_current_state_node()
	cur_state.connect("finished", self, "change_state")
	if cur_state.get("sub_state"):
		sub_state = cur_state.sub_state
	if sub_state:
		sub_state.connect("finished", self, "change_state")
	cur_state.enter(host, previous_state)
	if sub_state:
		sub_state.enter(host, previous_state, cur_state)
	emit_signal('state_changed', previous_state, current_state, host)

func do_not_process_state_until(from: Node, signal_name: String):
	set_actived(false)
	yield(from, signal_name)
	set_actived(true)

func _input(event: InputEvent) -> void:
	var kevt = event
	var action_chk = funcref(Utils.UInput, "is_action")
	var ui_up = 'ui_up_i%d' % host.player_index
	var ui_left = 'ui_left_i%d' % host.player_index
	var ui_right = 'ui_right_i%d' % host.player_index
	var ui_down = 'ui_down_i%d' % host.player_index
	if action_chk.call_func(ui_right) || action_chk.call_func(ui_left):
		host.direction.x = Input.get_axis(ui_left, ui_right)
	if action_chk.call_func(ui_up) || action_chk.call_func(ui_down):
		host.direction.y = Input.get_axis(ui_up, ui_down)
	
	var cur_state = get_current_state_node()
	cur_state.state_input(host, event)
	
	cur_state = get_current_state_node()
	if sub_state:
		sub_state.state_input(host, event, cur_state)
	
func _on_CharAnimation_animation_finished(anim_name: String) -> void:
	if !activated: return
	var cur_state = get_current_state_node()
	cur_state._on_animation_finished(host, anim_name)
	cur_state = get_current_state_node()
	if sub_state:
		sub_state._on_animation_finished(host, anim_name, cur_state)


func _on_Player_character_changed(previous_character, current_character):
	previous_character.fsm.disconnect_all_states(self);
	current_character.fsm.connect_all_states(self)

func setup_sub_state(obj:Node):
	if !states.has(obj.name):return
	var state = states[obj.name]
	state.sub_state = obj

func shutdown_sub_state(obj:Node):
	if !states.has(obj.name):return
	var state = states[obj.name]
	state.sub_state = null

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

func set_actived(val : bool) -> void:
	activated = val
	set_physics_process(activated)
	set_process_input(activated)
	emit_signal("activate_switch", activated)

func play_specific_anim_temp(animation_name : String, custom_speed : float = 1.0, can_loop : bool = true, time_to_stop = null) -> void:
	host.specific_animation_temp = true
	host.animation.animate(animation_name, custom_speed, can_loop)
	print(animation_name)
	if time_to_stop != null and time_to_stop is float:
		yield(get_tree().create_timer(time_to_stop), "timeout")
		host.specific_animation_temp = false

func _on_Player_draw():
	var state = get_current_state_node()
	state.draw(host)
	if sub_state:
		sub_state.draw(host, state)
