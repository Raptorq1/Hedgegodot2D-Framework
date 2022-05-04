extends Path2D
tool
class_name ObjectSpawnerArc
var my_color = Color(rand_range(0.4, 1), rand_range(0.65, 1), rand_range(0.8, 1), 1)
export var scene : PackedScene = preload("res://general-objects/ring-object.tscn")
export var offset:Vector2 = Vector2(8, 8) setget set_offset
var objects = []

func _ready() -> void:
	if Engine.editor_hint:
		update()
		return
	refresh()

func refresh () -> void:
	var curves = curve.get_baked_points()
	Utils.UArray.call_all_array(objects, "queue_free")
	objects.clear()
	for i in curves:
		var obj = scene.instance()
		objects.append(i)
		obj.position = i + offset
		var container = Node2D.new()
		add_child(container)
		container.add_child(obj)

func _draw() -> void:
	if Engine.editor_hint:
		var curves = curve.get_baked_points()
		for i in curves:
			draw_circle(i, 5.0, my_color)

func set_offset(val : Vector2):
	offset = val
	if Engine.editor_hint:
		update()
	else:refresh()
