extends Node2D

export var instance_act_on_ready : bool = false
export(Array, PackedScene) var acts_to_load : Array
export var current_act = 1 setget set_current_act
onready var stage_music = get_node("Act%d/StageMusic" % current_act)
onready var boss_music = get_node("Act%d/StageMusic" % current_act)

var time_bonus = 0
var score_bonus = 0
var cool_bonus = 0
var ring_bonus = 0

func get_current_act_scene() -> PackedScene:
	return acts_to_load[current_act-2]

func get_current_act_node() -> ActInfo:
	return get_node("Act%d" % current_act) as ActInfo

func _ready() -> void:
	if instance_act_on_ready:
		var first_act = get_current_act_scene().instance()
		add_child(first_act)

func go_to_next_act():
	reset_bonuses()
	var cur_act : ActInfo = get_node("Act%d" % current_act)
	set_current_act(current_act + 1)
	var next_act = get_current_act_scene().instance()
	if !cur_act.next_act_pos: return
	next_act.global_position = cur_act.next_act_pos.global_position
	cur_act.queue_free()
	stage_music = next_act.get_node("StageMusic")
	boss_music = next_act.get_node("BossMusic")
	get_tree().get_root().set_disable_input(false)
	add_child(next_act)
	get_parent().HUD.show_title_card()

func connect_and_mute(node, method, binds = []):
	var tween = Utils.Nodes.new_tween(self)
	tween.interpolate_property(stage_music, "volume_db", stage_music.volume_db, -27.0, 1.0, 1.0)
	tween.interpolate_property(boss_music, "volume_db", boss_music.volume_db, -27.0, 1.0, 1.0)
	tween.start()
	tween.connect("tween_all_completed", node, method, binds)
	yield(tween, "tween_all_completed")
	tween.queue_free()

func reset_bonuses():
	time_bonus = 0
	score_bonus = 0
	cool_bonus = 0
	ring_bonus = 0

func set_current_act(val : int):
	current_act = clamp(val, 1, acts_to_load.size()+1)
	
