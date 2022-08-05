extends CPUParticles2D
tool

var rotation_z = 0.0
var rotation_border = 0.0
export var speed : float = 2.0
var to_follow : Node2D
onready var container : Node2D = $Container
onready var front : CPUParticles2D = $Container/Front
onready var back : CPUParticles2D = $Container/Back

func _ready():
	set_process(true)

func _process(delta):
	rotation_z += delta * speed
	rotation_border += delta * sign(speed)
	rotation_z = fmod(rotation_z, TAU)
	var rot_cos_z = (20 * cos(rotation_z))
	if has_node("Container") and Engine.editor_hint:
		var container_editor = $Container
		container_editor.position.x = rot_cos_z * cos(rotation_border)
		container_editor.position.y = rot_cos_z * sin(rotation_border)
		var front = container_editor.get_node("Front")
		front.emitting = true if rotation_z < PI else false
		container_editor.get_node("Back").emitting = !front.emitting
		return
	container.position.x = rot_cos_z * cos(rotation_border)
	container.position.y = rot_cos_z * sin(rotation_border)
	var front = container.get_node("Front")
	front.emitting = true if rotation_z < PI else false
	container.get_node("Back").emitting = !front.emitting
	if to_follow:
		global_position = to_follow.global_position
