extends Node
class_name StateChar

signal finished(next_state)

var _state_processing : bool = true setget set_state_processing, is_state_processing
var _state_physics_processing : bool = true setget set_state_physics_processing, is_state_physics_processing
var _state_processing_anim: bool = true setget set_state_animation_processing, is_state_animation_processing

func set_state_physics_processing(val : bool) -> void: _state_physics_processing = val
func is_state_physics_processing() -> bool: return _state_physics_processing

func set_state_processing(val : bool) -> void: _state_processing = val
func is_state_processing() -> bool: return _state_processing

func set_state_animation_processing(val : bool) -> void: _state_processing_anim = val
func is_state_animation_processing() -> bool: return _state_processing_anim

func finish(next_state: String): emit_signal("finished", next_state)

func state_enter(host, prev_state:String, state:State=null):pass
func state_exit(host, next_state:String, state:State=null):pass

func state_physics_process(host, delta:float, state:State=null):pass
func state_process(host, delta:float, state:State=null):pass

func state_animation_process(host, delta:float, animator:CharacterAnimator, state:State=null):pass
func state_animation_finished(host, anim_name: String, state:State=null):pass
func state_animation_started(host, anim_name: String, state:State=null):pass
func state_animation_changed(host, old_name:String, new_name:String, state:State=null):pass

func state_input (host, event : InputEvent, state:State=null):pass

func get_class(): return "StateChar"
func is_class(name:String): return get_class() == name || .is_class(name)

func draw(host, state:State):pass
