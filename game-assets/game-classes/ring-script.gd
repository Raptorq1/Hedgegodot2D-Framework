extends RigidBody2D
class_name Ring

const ring_sparkle_scene = preload("res://general-objects/ring-sparkle-object.tscn");
export(int) var points = 1;
export(bool) var physical = false setget set_physical
onready var sprite = $AnimatedSprite
onready var hitBox = $Collision
onready var pick_box = $Area/Collide
var counter:float=1;
var grounded: bool = false;
var exit_timer:float = 2.0

func set_intangible_temp():
	pick_box.set_deferred("disabled", true)
	yield(get_tree().create_timer(1.5),"timeout")
	pick_box.set_deferred("disabled", false)
	if physical:
		counddown_exit()

func counddown_exit():
	yield(get_tree().create_timer(exit_timer),"timeout")
	var co_timer = get_tree().create_timer(3.0).connect("timeout", self, "queue_free")
	var count_disappear = 0.1
	
	while true:
		visible = !visible
		yield(get_tree().create_timer(count_disappear), "timeout")
		visible = !visible
		yield(get_tree().create_timer(count_disappear), "timeout")
		visible = !visible
		yield(get_tree().create_timer(count_disappear), "timeout")
		visible = !visible
		yield(get_tree().create_timer(count_disappear), "timeout")
		if count_disappear > 0.01:
			count_disappear -= 0.01
	

func set_physical(value:bool):
	physical = value
	set_deferred("sleeping", !physical)
	set_sleeping(!physical)
	applied_force = Vector2.ZERO if !physical else Vector2(0, 0.75)
	gravity_scale = 1.0 if physical else 0.0

func _on_Area_body_entered(body:Node):
	match body.get_class():
		"PlayerPhysics":
			_catch(body)
		"Ring":
			add_collision_exception_with(body)

func get_class():
	return "Ring"

func is_class(class_:String):
	return class_ == get_class() or class_ == .get_class();


func _on_Area_area_entered(area: Area2D) -> void:
	if area and area.get_owner().is_class('Rocket'):
		if area.get_owner().can_ascend == true && area.get_owner().player:
			var player = area.get_owner().player
			_catch(player)

func _catch(body: Node) -> void:
	get_tree().get_current_scene().rings += points;
	var ring_sparkle_instance:Node2D = ring_sparkle_scene.instance();
	var player:= body
	var sound:AudioPlayer = player.get_node("AudioPlayer");
	randomize()
	ring_sparkle_instance.animation = round(rand_range(0, 2))
	var ring_sparkle_anim:AnimatedSprite = ring_sparkle_instance.get_node("Anim")
	ring_sparkle_instance.position = Vector2.ONE * -8# + (-Vector2.ONE * 10);
	ring_sparkle_instance.animation = round(rand_range(0, 2))
	sound.play("ring")
	for i in get_children():
		i.queue_free()
	set_deferred("sleeping", true)
	add_child(ring_sparkle_instance)
	yield(ring_sparkle_instance, "tree_exited")
	queue_free()

func _on_Ring_body_entered(body):
	if body.is_class(get_class()):
		add_collision_exception_with(body)
