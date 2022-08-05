extends HUDVFX
var fade_out_time :float = 2.0

func _process(delta: float) -> void:
	if parent.color.a <= 0:
		emit_signal("finished")
		queue_free()
	parent.color.a -= delta * fade_out_time
