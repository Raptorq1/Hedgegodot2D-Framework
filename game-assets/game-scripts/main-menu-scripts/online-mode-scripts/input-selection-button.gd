extends Container
class_name SetterSelButton
tool

export(String) var option_value: String setget set_option_value
export(String) var option_name : String setget set_option_name
export var current_value : int = 0 setget set_current_value
var can_change_value : bool = true
var disabled : bool = false

var option_name_rect : Control = get_node_or_null("Top/ConfigName")
var option_values_rect : Control = get_node_or_null("Top/ConfigSwichContainer/ConfigSwitch")

func set_all():
	option_name_rect = get_node_or_null("Top/ConfigName")
	option_values_rect = get_node_or_null("Top/ConfigSwichContainer/ConfigSwitch")

func _ready():
	set_process(false)
	option_name_rect = get_node_or_null("Top/ConfigName")
	option_values_rect = get_node_or_null("Top/ConfigSwichContainer/ConfigSwitch")

func _process(delta):
	update()

func _notification(what):
	var min_rect : Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
	for i in get_children():
		if !i is HBoxContainer:
			return
		var hbox : HBoxContainer = i
		min_rect.size.x = max(min_rect.size.x, hbox.rect_size.x+hbox.rect_position.x)
		min_rect.size.y = max(min_rect.size.y, hbox.rect_size.y+hbox.rect_position.y)
	
	rect_min_size = min_rect.size

func set_option_name(val : String) -> void:
	set_all()
	if val.length() < 13:
		option_name = val
	else:
		option_name = val.substr(0, val.length() + (13-val.length()))
	update()

func set_current_value(val : int) -> void:
	current_value = val

func increment():
	set_current_value(current_value+1)

func decrement():
	set_current_value(current_value-1)

func change_value(val : float):
	on_value_change()
	if val > 0:
		increment()
	elif val < 0:
		decrement()
	get_parent().global_sounds.play("MenuBleep")

func on_value_change():pass

func set_option_value(val : String) -> void:
	option_value = val
	update()

func on_accept():
	pass
