extends Position2D
class_name PlayerSpawner
tool

var rect_size = Vector2(25, 39)
var rect = Rect2(-rect_size * Vector2(0.5, 1), rect_size)

func _ready():
	set_process(false)

func _draw():
	if !OS.is_debug_build() and !Engine.editor_hint: return
	var lines = [
		Vector2.ZERO,
		Vector2(-.5, -.2),
		Vector2(-.5, -1),
		Vector2(.5, -1),
		Vector2(.5, -.2)
	]
	var final_lines:PoolVector2Array = []
	for i in lines:
		final_lines.append(i * rect_size)
	draw_polygon(final_lines, [Color(0, 0.7, .6, .7)])
	draw_line(Vector2(-rect_size.x * .5, 0), Vector2(rect_size.x * .5, 0), Color(0, .9, .8, .8), 2.0)
	draw_line(Vector2(-rect_size.x * .5, -rect_size.y * .5), Vector2(rect_size.x * .5, -rect_size.y * .5), Color(0, .9, .8, .8), 2.0)
	draw_line(Vector2(-rect_size.x * .5, -rect_size.y), Vector2(rect_size.x * .5, -rect_size.y), Color(0, .9, .8, .8), 2.0)
