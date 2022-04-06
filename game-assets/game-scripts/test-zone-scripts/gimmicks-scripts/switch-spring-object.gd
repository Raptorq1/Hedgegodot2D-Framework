extends Area2D
tool

export var side:int = 0 setget set_side
const push_force = 700
export var length : int = 1 setget set_length
var shape:CollisionShape2D
var sprite:Sprite
onready var sfx : AudioPlayer = get_tree().get_current_scene().get_node('ActContainer/Act1/LevelSFX') if !Engine.editor_hint else null

func set_side(val : int) -> void:
	side = max(0, min(val, 3))
	rotation = side * PI/2

func set_length(val : int) -> void:
	if shape and sprite:
		length = max(1, val)
		sprite.region_rect.size.x = 16
		sprite.region_rect.size.y = 32 * length
		sprite.offset.y = -((length-2) * 32)/2
		shape.position.y = -(32 * (length-1))/2
		shape.shape.extents.y = (32 * length)/2
		shape.shape.extents.x = 8
	else:
		sprite = Utils.Nodes.get_node_by_type(self, 'Sprite')
		shape = Utils.Nodes.get_node_by_type(self, 'CollisionShape2D')
		shape.shape = RectangleShape2D.new()
		set_length(val)

func _ready():
	set_side(side)

func _on_SwitchSpring_body_shape_entered(body_rid, body, body_shape, local_shape):
	if body.is_class("PlayerPhysics"):
		var player : PlayerPhysics = body
		player.specific_animation_temp = true
		player.animation.animate("Rotating")
		player.animation.playback_speed = 4.0
		sfx.play('Bouncer')
		match side:
			0:
				player.fsm.change_state('OnAir')
				player.speed.x = scale.x * push_force
				player.speed.y = -push_force / 1.5
			1:
				player.fsm.change_state('OnAir')
				player.speed.x = push_force/1.5
				player.speed.y = scale.x * push_force
			2:
				player.fsm.change_state('OnAir')
				player.speed.x = scale.x * push_force
				player.speed.y = push_force / 1.5
			3:
				player.fsm.change_state('OnAir')
				player.speed.x = -push_force/1.5
				player.speed.y = -scale.x * push_force
