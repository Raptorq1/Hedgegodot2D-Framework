extends KinematicBody2D

var speed = 0
onready var sensor_area:Area2D = $Area2D

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	speed += delta * 1000
	position.y += speed * delta
	
