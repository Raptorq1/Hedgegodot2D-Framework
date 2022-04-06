extends Line2D

export var enabled:bool = false setget _set_enabled
var point : Vector2
export var max_length:int = 5

func _ready() -> void:
	_set_enabled(enabled)
	global_rotation = 0
	global_scale = Vector2.ONE
	set_as_toplevel(true)

func _process(delta: float) -> void:
	if enabled:
		point = get_parent().get_parent().character.global_position
		add_point(point)
		while get_point_count() > max_length:
			remove_point(0)
	else:
		remove_point(0)
	if get_point_count() == 0:
		set_process(false)

func _set_enabled(val : bool) -> void:
	enabled = val
	if enabled:
		set_process(true)
