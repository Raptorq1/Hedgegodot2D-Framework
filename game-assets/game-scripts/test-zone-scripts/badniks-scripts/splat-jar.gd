extends StaticBody2D

var actived : bool = false setget set_actived
const splat_scene = preload("res://zones/test-zone-objects/badnik-objects/splat.tscn")
var my_splats = []
export(int) var max_splats = 2
var first : bool = true

func _on_VisibilityNotifier2D_screen_entered():
	set_actived(true)
	spawn()


func _on_VisibilityNotifier2D_screen_exited():
	set_actived(false)

func spawn():
	while actived:
		if my_splats.size() >= max_splats: 
			yield(get_tree(), "idle_frame")
			continue
		if !first:
			yield(get_tree().create_timer(2.0), "timeout")
		else:
			yield(get_tree().create_timer(1.0), "timeout")
		first = false
		var splat = splat_scene.instance()
		splat.set_as_toplevel(true)
		splat.global_position = global_position
		splat.can_hurt = false
		if get_parent() is BadnikContainer:
			get_parent().add_child(splat)
		else:
			add_child(splat)
		my_splats.append(splat)
		for i in my_splats:
			for j in my_splats:
				i.add_collision_exception_with(j)
		splat.add_collision_exception_with(self)
		splat.speed.y -= 200
		splat.to_right = round(rand_range(0, 1)) as bool
		#splat.speed.x = 70 * Utils.sign_bool(splat.to_right)
		splat.connect("exploded", self, "on_splat_killed", [splat])
	

func on_splat_killed(splat):
	my_splats.remove(my_splats.find(splat))

func set_actived(val : bool) -> void:
	if actived == val: return
	actived = val
	if actived: spawn()
