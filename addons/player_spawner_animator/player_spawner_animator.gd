extends EditorPlugin
tool

var obj : PlayerSpawner
var obj_is_dragging : bool = false
var is_pressed : bool = false

func edit(object: Object) -> void: obj = object

func make_visible(visible: bool) -> void:
	if !obj:
		return
	if !visible:
		obj = null
	update_overlays()

func handles(object: Object) -> bool:
	return object is PlayerSpawner

func forward_canvas_gui_input(event: InputEvent) -> bool:
	if obj == null or !obj.is_visible():
		return false
	
	if event is InputEventMouseButton:
		is_pressed = event.is_pressed() and event.button_index == BUTTON_LEFT
		if not is_pressed:
			stop()
			return true
	if event is InputEventMouseMotion:
		if obj and !obj_is_dragging and is_pressed:
			obj_is_dragging = true
			return true
		elif obj == null or !is_pressed:
			stop()
			return true
		obj.anim_name = "running"
		obj.animate()
		return true
	
	return false

func stop():
	obj_is_dragging = false
	obj.anim_name = "stopped"
	obj.stop()
	obj = null
