extends Area2D
class_name BossArea
tool

onready var tween = $Tween
export var stage_music_path : NodePath
export var boss_music_path : NodePath
onready var stage_music_node : AudioStreamPlayer = get_node(stage_music_path)
onready var boss_music_node : AudioStreamPlayer = get_node(boss_music_path)
export var post_boss_area : Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO) setget set_post_boss_area
export var boss_defeated : bool = false
export var fit_viewport : bool = false setget set_fit_viewport
export var extents : Vector2 setget set_extents, get_extents
var default_cam_limit : Dictionary = {
	"limit_left": 0,
	"limit_top": 0,
	"limit_right": 0,
	"limit_bottom": 0,
}
const SIGN = preload("res://game-assets/game-scripts/general-scripts/act-sign.gd")
var sign_obj: SIGN

var rect_size : CollisionShape2D

var pos
export var change_area_after_boss_defeated : bool = false

func _enter_tree() -> void:
	if Engine.editor_hint:
		update_configuration_warning()
		update()

func _ready() -> void:
	if !Engine.editor_hint:
		rect_size = Utils.Nodes.get_node_by_type(self, 'CollisionShape2D')
		pos = {
			"limit_left": rect_size.global_position.x - rect_size.shape.extents.x,
			"limit_right": rect_size.global_position.x + rect_size.shape.extents.x,
			"limit_top": rect_size.global_position.y - rect_size.shape.extents.y,
			"limit_bottom": rect_size.global_position.y + rect_size.shape.extents.y,
		}

var players = []
var bosses : Array
func _on_BossArea_body_shape_entered(body_rid: RID, body: Node, body_shape: int, local_shape: int) -> void:
	if body is PlayerPhysics:
		pass
		var p : PlayerPhysics = body
		var pc : PlayerCamera = p.player_camera
		if boss_defeated: 
			set_player_area_to(post_boss_area, p)
			return
		if pc:
			for i in default_cam_limit:
				default_cam_limit[i] = pc.camera.get(i)
				var sum = (sign(pos[i])* 250)
				match i:
					"limit_right", "limit_top":
						sum = -sum
				
				#print(i, " ", pos[i])
				#print(i, " ", pc.camera.get(i) - pos[i], " ", pc.camera.get(i))
				tween.interpolate_property(pc.camera, i, pos[i] - sum, pos[i], 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.0)
			#tween.interpolate_property(pc, "global_position:x", pc.global_position.x, global_position.x, 1.0, 0, Tween.EASE_OUT)
			#tween.interpolate_property(pc, "global_position:y", pc.global_position.y, global_position.y, 1.0, 0, Tween.EASE_OUT)
			tween.start()
			
			#pc.camera.limit_left = rect_size.global_position.x - rect.extents.x
			#pc.camera.limit_right = rect_size.global_position.x + rect.extents.x
			#pc.camera.limit_top = rect_size.global_position.y - rect.extents.y
			#pc.camera.limit_bottom = rect_size.global_position.y + rect.extents.y
			players.append(p);
			on_player_entered_area()

func on_player_entered_area():
	if bosses.size() > 0:
		fade_music()
		yield(get_tree().create_timer(1.7),"timeout")
		Utils.UArray.call_all_array(bosses, 'appear')

func fade_music():
	if !stage_music_node.is_playing(): return
	var tween = Tween.new()
	tween.interpolate_property(stage_music_node, "volume_db", stage_music_node.volume_db, -30.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	add_child(tween)
	tween.start()
	yield(tween,"tween_all_completed")
	stage_music_node.stop()
	tween.queue_free()
	yield(get_tree().create_timer(1.0),"timeout")
	boss_music_node.play()

func _on_Boss_died(node) -> void:
	pass

func _reset_PlayerCamera() -> void:
	for i in players:
		var p : PlayerPhysics = i
		var pc : PlayerCamera = p.player_camera
		for prop in default_cam_limit:
			#print(prop)
			pc.camera.set(prop, default_cam_limit[prop])

func set_player_area_to(val : Rect2, player: PlayerPhysics = null):
	if player:
		var pc :PlayerCamera = player.player_camera
		set_pc(player, val)
		return
	for i in players:
		set_pc(i, val)
		

func set_pc(p:PlayerPhysics, val : Rect2):
	var pc :PlayerCamera = p.player_camera
	if pc.camera.limit_left != (global_position.x + val.position.x):
		pc.camera.limit_left = (global_position.x + val.position.x) - 500
	if pc.camera.limit_right != (global_position.x + val.position.x) + val.size.x:
		pc.camera.limit_right = (global_position.x + val.position.x) + val.size.x + 500
	if pc.camera.limit_top != (global_position.y + val.position.y):
		pc.camera.limit_top = (global_position.y + val.position.y) - 500
	if pc.camera.limit_bottom != (global_position.y + val.position.y) + val.size.y:
		pc.camera.limit_bottom = (global_position.y + val.position.y) + val.size.y + 500
	tween.interpolate_property(pc.camera, "limit_left", pc.camera.limit_left, (global_position.x + val.position.x), 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(pc.camera, "limit_right", pc.camera.limit_right, (global_position.x + val.position.x) + val.size.x, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(pc.camera, "limit_top", pc.camera.limit_top, (global_position.y + val.position.y), 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(pc.camera, "limit_bottom", pc.camera.limit_bottom, (global_position.y + val.position.y) + val.size.y, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func _on_BossArea_body_shape_exited(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if bosses.size() <= 0:
		if players.size() <= 0:
			set_process(false)
		_reset_PlayerCamera()

func _get_configuration_warning() -> String:
	var to_return : String
	
	var manipulate = Utils.Nodes.get_node_by_type(self, "RectManipulate2D")
	return to_return

func get_class() -> String:
	return "BossArea"

func is_class(val : String) -> bool:
	return val == get_class() or .is_class(val)

func _draw() -> void:
	if Engine.editor_hint:
		var color : Color = Color("#00ffff")
		var viewport = get_viewport().get_visible_rect()
		viewport.position -= viewport.size / 2
		#print(viewport.position)
		draw_rect(viewport, color, false, 2.0, true)
		draw_rect(post_boss_area, Color.aqua, false, 3.0)

func set_extents(val : Vector2):
	extents = val
	if fit_viewport: return
	if has_node("CollisionShape2D"):
		$CollisionShape2D.shape.extents = extents
	update()

func get_extents() -> Vector2:
	if !has_node("CollisionShape2D"): return Vector2.ZERO
	return $CollisionShape2D.shape.extents
	
func set_fit_viewport(val : bool) -> void:
	fit_viewport = val
	if has_node("CollisionShape2D"):
		if fit_viewport:
			var viewport = get_viewport()
			if viewport:
				$CollisionShape2D.shape.extents = viewport.get_visible_rect().size/2
		else:
			set_extents(extents)
	update()

func set_post_boss_area(val : Rect2):
	post_boss_area = val
	update()
