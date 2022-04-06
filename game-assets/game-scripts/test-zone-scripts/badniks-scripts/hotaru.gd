extends KinematicBody2D
onready var character : Node2D = $Character
onready var fsm := $FSM
onready var beam_charge : AnimatedSprite = $Character/Sprite/BeamCharge
onready var animator := $Character/Sprite/CharacterAnimator
const SHOOT = preload('res://zones/test-zone-objects/badnik-objects/hotaru/beam-shoot.tscn')
var rot = 0.0
var prev_position
var speed : Vector2 = Vector2.ZERO
var to_right: bool = false
var origin_point : float
var lying : bool = true
var boss : Boss

func _ready() -> void:
	set_origin_point()
	character.scale.x = Utils.Math.bool_sign(to_right)
	fsm._on_host_ready(self)

func physics_step(delta):
	rot += delta * 2.5
	character.position = Utils.Math.angle2Vec2(rot) * 2.5

func set_origin_point(val = null):
	if val:
		origin_point = val
		return
	origin_point = position.x
