extends Node2D
class_name Shield

signal hability_used
signal updatable_setted(is_updating)
signal hability_ended

var shield_index : int = 0
export(bool) var updatable : bool setget set_updatable, is_updating

func _ready() -> void:pass

func use_hability(host : PlayerPhysics):pass

func set_updatable(val : bool) -> void:
	updatable = val
	emit_signal("updatable_setted", updatable)

func is_updating() -> bool: return updatable

func on_update(host : PlayerPhysics, delta:float):pass
