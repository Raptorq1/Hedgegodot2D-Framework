extends Node2D


export(Vector2) var speed;
export(bool) var active = true
export var can_rotate:bool = true
onready var sprite = Utils.Nodes.get_node_by_type(self, "Sprite")
var canFall:bool = true
onready var distance_meter = $DistanceMeter

var spawnpoint:Vector2

func _ready():
	if active:
		spawnpoint = global_position
		distance_meter.position_d = spawnpoint
		distance_meter.max_distance = 2000
		distance_meter.set_active(true)
		set_physics_process(true);
	else:
		queue_free()

func delay(sec:float):
	canFall = false;
	yield(get_tree().create_timer(sec), "timeout")
	canFall = true


func _physics_process(delta):
	if canFall:
		if can_rotate:
			sprite.rotation += (0 - sprite.rotation) / 10
		if (abs(speed.x) > 50):
			speed.x += -sign(speed.x) * 250 * delta;
		if (speed.y < 5000):
			speed.y += 1000 * delta;
		move_local_x(speed.x * delta);
		move_local_y(speed.y * delta);


func _on_DistanceMeter_distance_achieved():
	queue_free()
