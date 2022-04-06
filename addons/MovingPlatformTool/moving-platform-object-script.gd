tool
extends Node2D
class_name MovingPlatformObject

onready var path : Path2D = Utils.Nodes.get_node_by_type(self, 'Path2D')

export var loop : bool = false setget set_loop
export var speed : float = 1.0
export var pause_timer : float = 1.0
onready var platform : KinematicBody2D = Utils.Nodes.get_node_by_type(self, 'KinematicBody2D')
onready var positions = (path as Path2D).curve.get_baked_points()
var path_follow : PathFollow2D = PathFollow2D.new()
var remote_t : RemoteTransform2D = RemoteTransform2D.new()
var right : bool = false
var unit_pos:float = 0.0

func _enter_tree() -> void:
	if Engine.editor_hint:
		update_configuration_warning()

func _ready() -> void:
	if Engine.editor_hint:
		return
	else:
		if path:
			path_follow.rotate = false
			remote_t.set_remote_node(platform.get_path())
			path.add_child(path_follow)
			path_follow.add_child(remote_t)
			path_follow.unit_offset= 0
			set_physics_process(true)
	#print(is_physics_processing())

func set_loop (val:bool) -> void:
	loop = val
	update()

func get_size() -> Vector2:
	var to_return : Vector2
	for i in get_children():
		if i is PhysicsBody2D:
			for j in i.get_children():
				if j is CollisionShape2D:
					to_return = j.shape.extents
	
	return to_return

func _physics_process(delta: float) -> void:
	#print(int(right) * delta)
	unit_pos += Utils.Math.bool_sign(right) * delta * speed
	unit_pos = max(0, min(1, unit_pos))
	#print(Utils.sign_bool(right) * delta * speed)
	path_follow.unit_offset = unit_pos
	if loop:
		if (path_follow.unit_offset >= 1 || path_follow.unit_offset <= 0):
			right = !right
			if pause_timer > 0.0:
				set_physics_process(false)
				yield(get_tree().create_timer(pause_timer), "timeout")
				set_physics_process(true)
	

func _get_configuration_warning() -> String:
	var text = ""
	var count_kin : int = 0
	var count_path : int = 0
	for i in get_children():
		if i is KinematicBody2D:
			count_kin += 1
		if i is Path2D:
			count_path += 1
	
	if count_kin != 1:
		if count_kin > 1:
			text = "This node works only with one KinematicBody2D"
		else:
			text = "This node must contain at least one KinematicBody2D"
	
	if count_path != 1:
		if count_path > 1:
			text = "This node works only with one Path2D"
		else:
			text = "This node must contain at least one Path2D"
	
	return text
