tool
extends Area2D

export(bool) var inverse = false;
export var radius:float setget set_radius, get_radius;
onready var collision_shape:CollisionShape2D = $Shape

func set_radius(value:float):
	if collision_shape:
		if has_node("Shape"):
			var shape:CircleShape2D = $Shape.shape
			shape.radius = value;

func get_radius():
	if has_node("Shape"):
		return $Shape.shape.radius

func _on_RotateCamTrigger_body_entered(body):
	if body.is_class("PlayerPhysics"):
		var player_cam:PlayerCamera = body.player_camera
		if player_cam:
			player_cam.rotateWithPlayer = !inverse
			player_cam.follow_player = false
			player_cam.secondary_target = self;

func _on_RotateCamTrigger_body_exited(body):
	if body.is_class("PlayerPhysics"):
		var player_cam:PlayerCamera = body.player_camera
		player_cam.rotateWithPlayer = inverse
		player_cam.follow_player = true
