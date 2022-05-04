extends KinematicBody2D
class_name Boss
tool
signal died(node)
signal damage(pre_hit_hp, current_hp)

var damage_only : bool = false
export var hp : int = 3 setget _set_hp
export var can_take_hit : bool = true
onready var area = get_parent()
var speed : Vector2
var max_speed : Vector2
var prev_position 

func _enter_tree() -> void:
	if !Engine.editor_hint:return
	update_configuration_warning()

func _ready() -> void:
	if !Engine.editor_hint:
		if !area.is_class("BossArea"):
			area = null
		else:
			area.bosses.append(self)
		if area && area is BossArea:
			if !is_connected("died", area, "_on_Boss_died"):
				connect('died', area, "_on_Boss_died")

func appear() -> void: pass
func boss_start () -> void:
	if hp <= 0:
		destroy()

func destroy() -> void:
	can_take_hit = false
	var ba : BossArea = area
	ba.bosses.remove(ba.bosses.find(self))
	on_destroy()

func on_destroy():pass

func damage() -> void:
	var php = hp
	if hp > 0:
		hp -= 1
		emit_signal('damage', php, hp)
		on_damage()
	else:
		destroy()

func on_damage():
	pass

func _get_configuration_warning() -> String:
	var to_return = ""
	if !area || !area is BossArea:
		to_return += "The Boss class must contain BossArea class as a parent\n"
	if hp <= 0:
		to_return += "Hp is setted to 0, When the boss start, it will be destroyed"
	return to_return

func _set_hp(val : int) -> void:
	hp = max(val, 0)

func get_class() -> String:return "Boss"
func is_class(val: String) -> bool:return val == get_class() or .is_class(val)
