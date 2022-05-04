extends Node2D

func _ready() -> void:
	var tween : Tween = Utils.Nodes.new_tween(self)
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 3.0)
	tween.start()
	yield(tween, "tween_all_completed")
	queue_free()
