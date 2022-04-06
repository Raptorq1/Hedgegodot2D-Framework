extends Node

onready var anim_player = $AnimationPlayer
var finished : bool = false
var loaded : bool = false
onready var loader : Control = get_node('/root/AdvancedBackgroundLoader')
func _enter_tree() -> void:
	var global = $"/root/GlobalScript"
	global.insert_loaded_data(DataPersistance.load_game())
	var lo = get_node('/root/AdvancedBackgroundLoader')
	lo.SIMULATED_DELAY_SEC = 0.001
	lo.connect('can_change', self, '_on_Loader_can_change')
	lo.connect('error', self, '_on_Loader_error')
	lo.preload_scene('res://scenes/title-screen.tscn')
	set_process_input(false)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	finished = true
	if loaded:
		loader.change_scene_to_preloaded()

func _on_Loader_can_change() -> void:
	$LoadingIndicator.get_child(0).disappear()
	loaded = true
	if !finished:
		set_process_input(true)
	else:
		loader.change_scene_to_preloaded()
	anim_player.play("Fade", -1, 1.0, false)

func _input(event: InputEvent) -> void:
	if loaded:
		if Input.is_key_pressed(KEY_ENTER) || (event.is_pressed() && event is InputEventScreenTouch):
			set_process_input(false)
			set_process(false)
			loader.change_scene_to_preloaded()

func _on_Loader_error() -> void:
	pass
	#get_tree().quit(ERR_FILE_NOT_FOUND)
