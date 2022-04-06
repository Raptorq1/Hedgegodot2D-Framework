extends Node2D
class_name ActInfo
tool
export var total_size : Rect2 setget set_total_size
export var continue_last_transition = false
export(NodePath) var next_act_pos_path
onready var next_act_pos : Position2D = get_node_or_null(next_act_pos_path)

func _ready() -> void:
	for i in get_tree().get_nodes_in_group("Players"):
		var player = i as PlayerPhysics
		var cam = player.player_camera.camera as Camera2D
		var tween = Utils.Nodes.new_tween(self)
		var vp_size = get_viewport_rect().size
		var pos : Vector2 = global_position + total_size.position
		tween.interpolate_property(cam, "limit_left", cam.limit_left, global_position.x, 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(cam, "limit_right", cam.limit_right, global_position.x + vp_size.x * 2, 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(cam, "limit_top", cam.limit_top, global_position.y + -vp_size.y * 1 if global_position.y < 0 else global_position.y, 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(cam, "limit_bottom", cam.limit_bottom, global_position.y + vp_size.y * 2, 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		tween.connect("tween_all_completed", self, "interpolated", [tween, player])


func interpolated(tween, player):
	tween.queue_free()
	var pos : Vector2 = global_position + total_size.position
	var cam = player.player_camera.camera as Camera2D
	cam.limit_left = pos.x
	cam.limit_right = pos.x + total_size.size.x
	cam.limit_top = pos.y
	cam.limit_bottom = pos.y + total_size.size.y

func _draw() -> void:
	if Engine.editor_hint:
		draw_rect(total_size, Color.red, false, 10.0)

func set_total_size(val : Rect2):
	total_size = val
	update()
