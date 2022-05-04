extends StaticBody2D
signal splat_exited
signal splat_spawned(splat)

var activated : bool = false setget set_activated
const splat_scene = preload("res://zones/test-zone-objects/badnik-objects/splat.tscn")
var my_splats = []
export(int) var max_splats = 2
onready var container = self
onready var anim_splash : AnimationPlayer = $AnimatedSprite/AnimationPlayer

func _ready() -> void:
	var parent = get_parent()
	if parent is BadnikContainer:
		container = parent

func _on_VisibilityNotifier2D_screen_entered():
	set_activated(true)


func _on_VisibilityNotifier2D_screen_exited():
	set_activated(false)

func spawn():
	# Will update to 2.0 seconds after first splat spawned after activation
	var time = .25
	while activated:
		# Will wait for a splat to be removed to continue loop
		if my_splats.size() >= max_splats: 
			yield(self, "splat_exited")
			continue
		yield(get_tree().create_timer(time), "timeout")
		var splat = spawn_splat()
		
		time = 2.0
	

func spawn_splat():
	var splat = splat_scene.instance()
	splat.set_as_toplevel(true)
	splat.global_position = global_position
	splat.can_hurt = false
	container.add_child(splat)
	my_splats.append(splat)
	splat.add_collision_exception_with(self)
	splat.speed.y = -200
	splat.to_right = round(rand_range(0, 1)) as bool
	splat.connect("exploded", self, "on_splat_killed", [splat])
	emit_signal("splat_spawned", splat)
	return splat

func on_splat_killed(splat):
	my_splats.remove(my_splats.find(splat))
	emit_signal("splat_exited")

func set_activated(val : bool) -> void:
	if activated == val: return
	activated = val
	if activated: spawn()


func _on_SplatJar_splat_spawned(splat) -> void:
	anim_splash.play("default")
	yield(anim_splash, "animation_finished")
	anim_splash.play('RESET')
