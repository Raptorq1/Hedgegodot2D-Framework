extends ButtonSelector
tool

export var scroll : int = 0 setget set_scroll
export var separation : int = 0 setget set_separation
export var min_scroll : int = 0 setget set_min_scroll
export var max_scroll : int = 0 setget set_max_scroll
export var font : DynamicFont = preload("res://game-assets/game-fonts/options-common-button-text.tres")
export var dynamic_scroll_size : bool = false

func _ready():
	_set_selected(selected)
	var children = get_children()
	children.remove(0)
	if dynamic_scroll_size:
		for i in get_children():
			max_scroll += i.rect_min_size.y * separation

func _notification(what):
	sort_queue()

func sort_queue():
	for i in get_children():
		var hc : OptionSelButton = i
		var rect : Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
		rect.size.x = rect_size.x
		rect.size.y = hc.rect_size.y
		rect.position.y = (hc.get_position_in_parent() * (rect.size.y + separation)) - scroll
		rect.position.x = 0
		hc.rect_position = rect.position
		hc.rect_size = rect.size
		fit_child_in_rect(hc, rect)

func set_scroll(val : int) -> void:
	scroll = clamp(val, min_scroll, max_scroll)
	_notification(NOTIFICATION_SORT_CHILDREN)

func set_separation(val : int) -> void:
	separation = val
	_notification(NOTIFICATION_SORT_CHILDREN)

func set_min_scroll(val : int) -> void:
	min_scroll = val
	if min_scroll > max_scroll:
		max_scroll = min_scroll
	if min_scroll > scroll:
		scroll = min_scroll
	_notification(NOTIFICATION_SORT_CHILDREN)

func set_max_scroll(val : int) -> void:
	max_scroll = val
	if max_scroll < min_scroll:
		max_scroll = min_scroll
	if max_scroll < scroll:
		scroll = max_scroll
	_notification(NOTIFICATION_SORT_CHILDREN)

func _set_selected(val) :
	get_child(selected).all_player.play("resetanim")
	selected = min(get_child_count()-1, max(0, val))
	get_child(selected).all_player.play("hover")
	global_sounds.play("MenuBleep")
	var child : Container = get_child(selected)
	var tween = get_parent().get_node("Tween")
	tween.interpolate_method(self, "set_scroll", scroll, child.get_position_in_parent() * child.rect_size.y, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func _input(event : InputEvent):
	if all_disabled: return
	if event.is_action_pressed(selector_back) or event.is_action_pressed(selector_next):
		_set_selected(selected + Input.get_axis(selector_back, selector_next))
	
	if event.is_action_pressed(value_back) or event.is_action_pressed(value_next):
		var selected_node = get_child(selected)
		if selected_node.can_change_value:
			
			selected_node.change_value(Input.get_axis(value_back, value_next))
	if event.is_action_pressed("ui_accept"):
		accept()
	

func accept():
	get_child(selected).on_accept()
