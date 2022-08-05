extends Node2D
class_name ActInfo
tool
export var total_size : Rect2 setget set_total_size
export var continue_last_transition = false
export(NodePath) var next_act_pos_path
export(NodePath) var boss_area_path = @"./Level/BossArea"
export(NodePath) var level_pass_path = @"../../Sign"
onready var boss_area : BossArea = get_node_or_null(boss_area_path)
onready var next_act_pos : Position2D = get_node_or_null(next_act_pos_path)
onready var level_pass : KinematicBody2D = get_node_or_null(level_pass_path)

func act_ready() -> void:
	if level_pass_path != null and level_pass != null and boss_area_path != null and boss_area != null:
		boss_area.sign_obj = level_pass
	for i in get_tree().get_nodes_in_group("Players"):
		var player = i as PlayerPhysics
		var cam = player.player_camera.camera as Camera2D
		var tween = Utils.Nodes.new_tween(self)
		var vp_size = get_viewport_rect().size
		var pos : Vector2 = global_position + total_size.position
		tween.interpolate_property(cam, "limit_left", cam.limit_left, player.global_position.x - vp_size.x * 2 if player.global_position.x-vp_size.x > global_position.x else global_position.x, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.25)
		tween.interpolate_property(cam, "limit_right", cam.limit_right, player.global_position.x + vp_size.x, 1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.25)
		tween.interpolate_property(cam, "limit_top", cam.limit_top, player.global_position.y + -vp_size.y * 2 if player.global_position.y - vp_size.y > global_position.y else player.global_position.y, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.25)
		tween.interpolate_property(cam, "limit_bottom", cam.limit_bottom, player.global_position.y + vp_size.y * 2, 1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.25)
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
		draw_rect(total_size, Color.red, false, 1.0)

func set_total_size(val : Rect2):
	total_size = val
	update()
