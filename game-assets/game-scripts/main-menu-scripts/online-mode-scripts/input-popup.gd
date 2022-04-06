extends PopupDialog

onready var text_edit = $HBoxContainer/TextEdit
onready var button = $HBoxContainer/Button
var editing : SetterSelButton
var container

func container_ready(container_: ButtonSelector):
	container = container_

func start_input(input_affect: SetterSelButton):
	popup()
	editing = input_affect


func _on_Button_pressed():
	editing.option_value = text_edit.text
	editing = null
	hide()
	container.can_select = true
