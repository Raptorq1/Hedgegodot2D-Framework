extends Sprite

var timer:Timer = Timer.new()
export var time_left : float = 0.5
var can_start : bool = false
var can_count = false
var count = 10
onready var music_player : AudioStreamPlayer = get_tree().get_current_scene().get_node("Music")
onready var sfx : GlobalSounds = get_node("/root/GlobalSounds")
onready var fade_out : AnimationPlayer = get_tree().get_current_scene().get_node("FadeOut")

func start():
	add_child(timer)
	timer.start(time_left)
	can_start = true
	timer.connect("timeout", self, "toogle")

func toogle():
	set_visible(!visible)
	timer.start(time_left)
	#print(count)
	if can_count:
		count -= 1
	if count <= 0:
		timer.queue_free()
		set_visible(true)

func _input(event):
	if can_start && event.is_pressed():
		can_count = true
		if count >= 10:
			time_left = 0.1
			timer.start(time_left)
			set_visible(true)
			music_player.stop()
			sfx.play('AlternativeMenuAccept')
			fade_out.play('FadeOut')
