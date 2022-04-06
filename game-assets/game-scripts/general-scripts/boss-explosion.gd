extends Node2D
tool
signal finished
signal explosion_cleared
const puff = preload("res://general-objects/dusts/boss-puff.tscn")
const explosion = preload("res://general-objects/explosions/boss-explosion-object.tscn")
var rng = RandomNumberGenerator.new()
export var duration : float = 3.0
var _duration = duration
export var frequency : float = 90.0
export var radius : float = 50.0 setget set_radius
var current_timer
onready var explosion_audio : AudioStreamPlayer = $Explosion
onready var explosion2_audio : AudioStreamPlayer = $Explosion2

func _ready() -> void:
	if !Engine.editor_hint:
		set_process(true)
		return
	set_process(false)

func _process(delta: float) -> void:
	if !current_timer:
		current_timer = get_tree().create_timer(1.0/frequency)
		current_timer.connect("timeout", self, "spawn_explosion")
	_duration -= delta
	if _duration < 0:
		set_process(false)
		emit_signal("finished")
	

func _draw() -> void:
	if Engine.editor_hint:
		draw_circle(Vector2.ZERO, radius, Color(0xff000077))

func spawn_explosion():
	rng.randomize()
	var explosion_object = Utils.UArray.pick_random_index([explosion, puff]).instance()
	var rot = rng.randf_range(-PI, PI)
	explosion_object.position = Utils.Math.angle2Vec2(rot) * rng.randf_range(0, radius)
	add_child(explosion_object)
	current_timer = null
	explosion_object.connect("tree_exited", self, "when_explosion_exit_tree")
	var select = Utils.UArray.pick_random_index([explosion_audio, explosion2_audio])
	select.play()

func when_explosion_exit_tree():
	if get_child_count() <= 2:
		emit_signal("explosion_cleared")
		queue_free()

func set_radius(val : float):
	radius = val
	update()
