extends Area2D
class_name Ring

const ring_sparkle_scene = preload("res://general-objects/ring-sparkle-object.tscn");
export(int) var points = 1
onready var sprite = $AnimatedSprite
onready var pick_box = $Collide
var counter:float=1
var catcher

func _ready() -> void:
	if !is_connected("body_entered", self, "_on_Ring_body_entered"):
		connect("body_entered", self, "_on_Ring_body_entered")
		
	if !is_connected("area_entered", self, "_on_Ring_area_entered"):
		connect("area_entered", self, "_on_Ring_area_entered")

func _on_Ring_body_entered(body:Node):
	match body.get_class():
		"PlayerPhysics":
			_catch(body)


func _on_Ring_area_entered(area: Area2D) -> void:
	if area and area.get_owner().is_class('Rocket'):
		if area.get_owner().rocket.is_physics_processing() and area.get_owner().player:
			catcher = area.get_owner().player
			_catch(catcher)

func _catch(body: Node) -> void:
	body.rings += points;
	catcher = body
	for i in get_children():
		i.queue_free()
	emit_sparkle()

func emit_sparkle():
	var ring_sparkle_instance:Node2D = ring_sparkle_scene.instance();
	var ring_sparkle_anim:AnimatedSprite = ring_sparkle_instance.get_node("Anim")
	ring_sparkle_instance.position = Vector2.ONE * -8
	
	# Select Sparkle Animation
	randomize()
	ring_sparkle_instance.animation = round(rand_range(0, 2))
	
	add_child(ring_sparkle_instance)
	
	#Play Sound
	var sound:SoundMachine = catcher.get_node("AudioPlayer");
	sound.play("ring")
	
	ring_sparkle_instance.connect("tree_exited", self, "queue_free")

func get_class():
	return "Ring"

func is_class(class_:String):
	return class_ == get_class() or .is_class(class_);
