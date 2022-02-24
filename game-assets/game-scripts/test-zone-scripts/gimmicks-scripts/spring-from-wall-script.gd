tool
extends Node2D
var showTrigger:Area2D;
export(Vector2) var trigger_position = Vector2(80, 0) setget setTriggerPos, getTriggerPos;
export(Vector2) var trigger_size = Vector2(80, 0) setget setTriggerSize, getTriggerSize
var show_rect:RectangleShape2D = RectangleShape2D.new();
export var initial_angle : float = 180 setget setInitAngle
export var final_angle : float = 0
var activate:bool = false;
var sp_plat : Node2D
var duration : float =0.1
export var activate_only_on_ground : bool = false
export var activate_only_when_stopped : bool = false

var players_inside : Array = []
var inside : bool = false

func _ready() -> void:
	setInitAngle(initial_angle)
	set_process(false)

func _enter_tree():
	_prepare();
	set_process(false)

func _prepare():
	setShowTrigger()
	$ShowTrigger/CollisionTrigger.shape = show_rect;
	sp_plat = $SpPlat

func setInitAngle(value:float):
	initial_angle = fmod(value, 360);
	var sp_p = get_node_or_null('./SpPlat')
	if sp_p:
		sp_p.rotation_degrees = initial_angle;
		#print(sp_p)

func getInitAngle():
	return initial_angle;

func setFinalAngle(value:float):
	final_angle = fmod(value, 360)

func getFinalAngle():
	return final_angle

func setShowTrigger():
	if has_node("./ShowTrigger"):
		showTrigger = $ShowTrigger;

func setTriggerPos(value: Vector2):
	if showTrigger == null:
		setShowTrigger();
	if showTrigger != null:
		showTrigger.position = value;

func getTriggerPos():
	if showTrigger == null:
		setShowTrigger();
	if (showTrigger != null):
		return showTrigger.position;
	return 0;

func setTriggerSize(value:Vector2):
	show_rect.extents = value;

func getTriggerSize():
	return show_rect.extents

func _on_ShowTrigger_body_entered(body):
	if body.is_class("PlayerPhysics"):
		if activate_only_on_ground:
			if !body.is_grounded:
				return
			else:
				if activate_only_when_stopped && abs(body.gsp) > 0:
					return
		if !players_inside.has(body):
			players_inside.append(body)
		if players_inside.size() > 0:
			inside = true
			if sp_plat.rotation_degrees == -initial_angle:
				sp_plat.rotation_degrees = initial_angle
			$Tween.interpolate_property(sp_plat, "rotation_degrees", -sp_plat.rotation_degrees, final_angle, duration, Tween.TRANS_LINEAR)
			$Tween.start()
func _on_ShowTrigger_body_exited(body):
	if body.is_class("PlayerPhysics"):
		if players_inside.has(body):
			players_inside.remove(players_inside.find(body))
		if players_inside.size() < 1:
			inside = false
			$Tween.interpolate_property(sp_plat, "rotation_degrees", sp_plat.rotation_degrees, -initial_angle, duration, Tween.TRANS_LINEAR)
			$Tween.start()
func _on_RedSpringFromSolid_script_changed():
	_prepare();
