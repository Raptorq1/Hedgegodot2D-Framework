extends Node2D
tool
class_name CircleObjects

export var scene : PackedScene = preload('res://general-objects/spring-object.tscn') setget set_scene
export var scene_offset : Vector2 = Vector2(8, 8) setget _set_scene_offset
export var radius : float = 50 setget _set_radius
export var object_count : int = 16 setget _set_object_count
export var blank_position = "" setget _set_blank_positions
export var rotate : bool = false setget _set_rotate
export var rotation_speed : float = 1.0
export var editor_process : bool = false setget _set_editor_process
export var default_angle : float = 0 setget _set_dangle
var objects : Array = []
var process_angle = default_angle

func _ready() -> void:
	if process_angle == null: process_angle = 0
	if default_angle == null: default_angle = 0
	if Engine.editor_hint:
		set_physics_process(rotate && editor_process)
		return
	set_physics_process(rotate)

func _set_object_count(val : int) -> void:
	val = max(val, 0)
	object_count = val
	_spawn_objects()
	update()

func _set_blank_positions(val : String) -> void:
	blank_position = val
	_spawn_objects()
	update()

func _set_radius (val : float) -> void:
	radius = val
	if !editor_process:
		process_angle = default_angle
		_update_rings_pos()
	update()

func _set_scene_offset (val : Vector2) -> void:
	scene_offset = val
	if !editor_process:
		process_angle = default_angle
		_update_rings_pos()
	update()

func _set_dangle( val : float) -> void:
	default_angle = fmod(val, PI*2)
	if !editor_process:
		process_angle = default_angle
		_update_rings_pos()
	update()

func _set_rotate(val : bool) -> void:
	rotate = val
	if val:
		set_physics_process(editor_process)
	else:
		set_physics_process(false)
		process_angle = default_angle
		_update_rings_pos()
	update()

func _set_editor_process (val : bool) -> void:
	editor_process = val
	if !editor_process:
		set_physics_process(false)
		_update_rings_pos()
		return
	if rotate:
		set_physics_process(editor_process)

func clear():
	for i in objects:
		if i == null or !is_instance_valid(i):return
		var obj : Node = i
		if obj.is_connected("tree_exited", self, "object_removed"):
			obj.disconnect("tree_exited", self, "object_removed")
		
	if get_child_count() > 0:
		for i in get_children():
			var obj : Node = i
			obj.queue_free()
	
	objects.clear()

func _spawn_objects() -> void:
	clear()
	if object_count == 0: return
	var angle_step = TAU / object_count
	var m_angle = default_angle
	if scene == null: return
	for i in object_count:
		if i < blank_position.length() and blank_position[i] == "0":
			m_angle += angle_step
			objects.append(null)
			continue
		var scene_obj : Node2D = scene.instance()
		var direction = Utils.Math.angle2Vec2(m_angle)
		var pos = scene_offset + (direction * radius)
		if !Engine.editor_hint:
			scene_obj.connect("tree_exited", self, "object_removed", [objects.find(scene_obj)])
		scene_obj.set_position(pos)
		add_child(scene_obj)
		objects.append(scene_obj)
		m_angle += angle_step
	#print(objects)

func _update_rings_pos() -> void:
	if object_count == 0: return
	var angle_step = TAU / object_count
	var angle_to_mod = process_angle
	#if name == "PlasmaCircle2":print(objects)
	for obj in objects:
		if (obj == null) or !is_instance_valid(obj):
			angle_to_mod += angle_step
			continue
		var direction = Utils.Math.angle2Vec2(angle_to_mod)
		var pos = scene_offset + (direction * radius)
		obj.set_position(pos)
		angle_to_mod += angle_step

func _physics_process(delta: float) -> void:
	process_angle += delta * rotation_speed
	process_angle = fmod(process_angle, TAU)
	_update_rings_pos()

func _draw() -> void:
	if Engine.editor_hint:
		var col = Color(.0, 1, 0.5, .5) if !rotate else Color(.0, .5, 1, .5)
		draw_circle(Vector2.ZERO, radius, col)
		if rotate:
			var half_pi = PI * 0.5
			var width = 10.0
			var point_count = 10.0
			col.a += 0.5
			
			draw_arc(Vector2.ZERO, radius*0.5, -half_pi+.5, half_pi, point_count, col, width)
			draw_arc(Vector2.ZERO, radius*0.5, half_pi+.5, PI*1.5, point_count, col, width)

func object_removed(val : int):
	if val < objects.size():
		objects[val] = null

func _edit_is_selected_on_click(p_point:Vector2, p_tolerance:float) -> bool:
	var converted_cordinates = get_viewport().get_global_canvas_transform().affine_inverse().xform(p_point)
	return converted_cordinates.length() < radius + p_tolerance;

func set_scene(val : PackedScene):
	scene = val
	_spawn_objects()
