extends PopupMenu

func _on_DebugMenuPopup_index_pressed(index):
	if is_item_checkable(index):
		toggle_item_checked(index)
	elif !is_item_checkable(index) and !is_item_radio_checkable(index):
		match index:
			3: get_tree().reload_current_scene()
			4: get_parent().level.act_container.go_to_next_act()

func _input(event):
	if event.is_action_pressed("ui_end"):
		show_debug_menu()

func show_debug_menu():
	get_tree().paused = true
	popup()

func _on_DebugMenuPopup_popup_hide():
	get_tree().paused = false
