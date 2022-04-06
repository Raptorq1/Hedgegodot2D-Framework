extends OptionSelButton
tool

onready var all_player = $AllPlayer
export var text : String setget _set_text
onready var shade : Sprite = $ConfigName/HeadContainer/Shade
onready var head : Sprite = $ConfigName/HeadContainer/Head

func _ready():
	._ready()
	option_values = $"/root/GlobalScript".chars_info.values()
	rect_min_size = Vector2(280, 72)
	if !can_change_value:
		$ConfigName/HeadContainer/Arrows.visible = false

func _set_text(val : String) -> void:
	text = val
	update()

func _draw():
	if get_parent() is ButtonSelector:
		draw_string(get_parent().font, Vector2(10, 30), text, Color.white, -1)

func set_current_value(val : int) -> void:
	if option_values.empty(): return
	current_value = val % (option_values.size())
	if current_value < 0:
		current_value = option_values.size() - 1
	if !Engine.editor_hint:
		if head:
			if option_values[current_value].has("enabled"):
				if option_values[current_value]["enabled"]:
					head.modulate = Color.white
				else:
					head.modulate = Color(0x11ffffff)
			head.frame = current_value
		if shade:
			shade.frame = current_value + ((shade.get_hframes() * shade.get_vframes()) / 2)
		if all_player:
			all_player.play("hover")

func on_accept():
	var pos = get_position_in_parent() - 2
	var loaded_data = get_node("/root/GlobalScript").loaded_data
	if loaded_data.size() > pos and pos >= 0:
		if loaded_data[pos] == null and option_values[current_value]["available"]:
			DataPersistance.save_game(pos, option_values[current_value]["character_id"], 0, 0)
	var parent = get_parent()
	parent.disable_buttons()
	parent.global_sounds.play("MenuAccept")
	all_player.play("select")
	yield(all_player, "animation_finished")
	parent.get_parent().owner.change_scene("res://zones/test-zone-act-1-scene.tscn")


func _on_Button_pressed():
	var parent = get_parent()
	if parent.selected != get_position_in_parent():
		parent.selected = get_position_in_parent()
		return
	parent.accept()
