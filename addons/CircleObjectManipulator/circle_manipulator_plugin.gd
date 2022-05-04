extends EditorPlugin
tool

enum Anchors {
	RADIUS=1, ANGLE=2
}

var obj : CircleObjects
const ANCHOR_SIZE : float = 15.0
const STROKE_WIDTH : float = 1.0
const ANCHOR_COLOR_RADIUS : Color = Color("#AD12B3")
const ANCHOR_COLOR_ANGLE : Color = Color("#FF4F0D")
const STROKE_COLOR : Color = Color.white
var dragging : int = 0

var anchors_rect = {}

func edit(object: Object) -> void:
	obj = object

func make_visible(visible: bool) -> void:
	if !obj:
		return
	if !visible:
		obj = null
	update_overlays()

func handles(object: Object) -> bool:
	return object is CircleObjects

func _add_control () ->void:
	pass

func forward_canvas_draw_over_viewport(overlay: Control) -> void:
	
	if !obj || !obj.is_inside_tree() || !obj.is_visible():
		dragging = 0
		anchors_rect = {}
		return
	var anchor_rad_angle = Vector2(1, 0)
	var anchor_da_angle = Vector2(sin(obj.default_angle), -cos(obj.default_angle))
	
	var anchor_rad_pos = obj.global_position + (anchor_rad_angle * obj.radius)
	var anchor_da_pos = obj.global_position + (anchor_da_angle * (obj.radius*0.7))
	
	var center_pos = obj.global_position
	
	var anchor_rad_coord = obj.get_viewport_transform() * anchor_rad_pos

	var anchor_da_coord = obj.get_viewport_transform() * anchor_da_pos

	var center_coord = obj.get_viewport_transform() * center_pos
	center_coord.x-=4
	var wh = Vector2.ONE * ANCHOR_SIZE
	
	center_coord.x += ANCHOR_SIZE/4
	
	anchors_rect = {
		Anchors.ANGLE: Rect2(anchor_da_coord - (wh/2), wh),
		Anchors.RADIUS: Rect2(anchor_rad_coord - (wh/2), wh)
	}
	
	overlay.draw_rect(anchors_rect[Anchors.ANGLE], ANCHOR_COLOR_ANGLE, true)
	overlay.draw_line(center_coord, anchor_da_coord, ANCHOR_COLOR_ANGLE, STROKE_WIDTH, true)
	
	overlay.draw_rect(anchors_rect[Anchors.RADIUS], ANCHOR_COLOR_RADIUS, true)
	overlay.draw_line(center_coord, anchor_rad_coord, ANCHOR_COLOR_RADIUS, STROKE_WIDTH, true)

func forward_canvas_gui_input(event: InputEvent) -> bool:
	if !obj || !obj.is_visible():
		dragging = 0
		anchors_rect = {}
		return false
	
	if dragging != 0 && event is InputEventMouseMotion:
		var iemm : InputEventMouseMotion = event
		var funcs = {
			Anchors.ANGLE: funcref(self, "drag_angle"),
			Anchors.RADIUS: funcref(self, "drag_radius")
		}
		(funcs[dragging] as FuncRef).call_func(iemm.position)
		update_overlays()
		return true
	
	if event is InputEventMouseButton:
		var iemb : InputEventMouseButton = event
		if iemb.is_pressed() && iemb.button_index == BUTTON_LEFT && dragging == 0:
			dragging = _get_point(iemb.position)
			if dragging == 0:
				return false
			var undo_redo := get_undo_redo()
			undo_redo.create_action("Set %s default_angle/radius" % obj.name)
			undo_redo.add_undo_property(obj, "radius", obj.radius)
			undo_redo.add_undo_property(obj, "default_angle", obj.default_angle)
			return true
		elif !iemb.is_pressed() && iemb.button_index == BUTTON_LEFT && dragging != 0:
			dragging = 0
			var undo_redo := get_undo_redo()
			undo_redo.add_do_property(obj, "radius", obj.radius)
			undo_redo.add_do_property(obj, "default_angle", obj.default_angle)
			undo_redo.commit_action()
			return true
	
	if event.is_action_pressed('ui_cancel'):
		dragging = 0
		var undo = get_undo_redo()
		undo.commit_action()
		undo.undo()
		update_overlays()
		return true
	
	return false

func _get_point(point : Vector2) -> int:
	
	for i in anchors_rect:
		if anchors_rect[i] is Rect2:
			var rect : Rect2 = anchors_rect[i]
			if rect.has_point(point):
				return i
	
	return 0

func drag_radius(val : Vector2) -> void:
	var converted_cordinates = obj.get_viewport().get_global_canvas_transform().affine_inverse().xform(val)
	converted_cordinates = (converted_cordinates / 5).round() * 5
	obj._set_radius(obj.global_position.distance_to(converted_cordinates))
	obj._update_rings_pos()

func drag_angle (val : Vector2) -> void:
	var converted_cordinates = obj.get_viewport().get_global_canvas_transform().affine_inverse().xform(val)
	var deg = rad2deg(obj.global_position.angle_to_point(converted_cordinates) - PI/2)
	deg = fmod(round(deg/10)*10, 360)
	obj._set_dangle(deg2rad(deg));
	obj._set_dangle(round(obj.default_angle*100)/100)
	obj._update_rings_pos()
