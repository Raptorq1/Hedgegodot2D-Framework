extends Badnik
signal target_sighted
tool

onready var fsm := $FSM
onready var animator : CharacterAnimator = $Character/AnimatedSprite/CharacterAnimator
onready var character : Node2D = $Character
onready var screen_sensor: VisibilityNotifier2D = $VisibilityNotifier2D
var players_to_push := []
var players_inside_area := []
var pos_entered
onready var eye : Area2D = $Eye
onready var fan_sensor : Area2D = $Character/FanSensor
onready var choose_position : Position2D = $PositionToPush
onready var up_blow : CPUParticles2D = $Character/UpBlow
onready var side_blow : CPUParticles2D = $Character/SideBlow
onready var turtle_walk = [
	$TurtleWalk, $TurtleWalk2
]
export var eye_extent : Vector2 = Vector2(211, 95) setget set_eye_extents, get_eye_extents
export var eye_position : Vector2 = Vector2(211, 95) setget set_eye_position, get_eye_position
onready var fan : AudioStreamPlayer2D = $Fan

var is_inside_screen : bool = false
var prev_position
var target_sighted : bool = false setget set_target_sighted
var target_h := false
var is_pushing := false setget set_is_pushing

func _ready():
	if Engine.editor_hint: return
	fsm._on_host_ready(self)
	check_for_target()

func side_switch(val : bool):
	to_right = val
	fsm.change_state("Wait")

func set_is_pushing(val : bool):
	is_pushing = val
	fan_sensor.get_node("H").set_deferred("disabled", !target_h)
	fan_sensor.get_node("V").set_deferred("disabled", target_h)

func set_target_sighted(val : bool):
	target_sighted = val
	if target_sighted:
		emit_signal("target_sighted")

func physics_step(delta):
	pass

func play_step():
	turtle_walk[round(rand_range(0, 1))].play()

func move_and_slide_preset(val=null):
	return move_and_slide(speed, Vector2.UP)

func check_for_target():
	if players_inside_area.empty():
		#print("empty")
		get_tree().create_timer(1.5).connect("timeout", self, "check_for_target")
		return
	pos_entered = to_local(players_inside_area[0].position)
	set_target_sighted(true)

func _on_FanSensor_body_entered(body):
	if body is PlayerPhysics:
		players_to_push.append(body)


func _on_FanSensor_body_exited(body):
	if body is PlayerPhysics:
		players_to_push.remove(players_to_push.find(body))


func _on_Eye_body_entered(body):
	if body is PlayerPhysics:
		if !is_inside_screen:
			yield(screen_sensor, "viewport_entered")
		players_inside_area.append(body)
		pos_entered = to_local(body.position)


func _on_Eye_body_exited(body):
	if body is PlayerPhysics:
		players_inside_area.remove(players_inside_area.find(body))
		target_sighted = false
		pos_entered = null

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	is_inside_screen = true


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	is_inside_screen = false

func set_eye_extents(val : Vector2) -> void:
	eye_extent = val
	if has_node("Eye/CollisionShape2D"):
		var shape = RectangleShape2D.new()
		shape.extents = eye_extent
		$Eye/CollisionShape2D.shape = shape

func get_eye_extents() -> Vector2:
	if has_node("Eye/CollisionShape2D"):
		return $Eye/CollisionShape2D.shape.extents
	return Vector2.ZERO

func set_eye_position(val : Vector2) -> void:
	eye_position = val
	if has_node("Eye"):
		$Eye.position = eye_position

func get_eye_position() -> Vector2:
	if has_node("Eye"):
		return $Eye.position
	return Vector2.ZERO
