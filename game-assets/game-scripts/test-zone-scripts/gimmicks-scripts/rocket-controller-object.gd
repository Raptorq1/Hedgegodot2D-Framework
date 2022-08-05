extends Node2D
tool
onready var rocket : Node2D = $Rocket
onready var sonic_sprite = $Rocket/RocketSprite/SnappedSonic
onready var rocket_hit_box = $Rocket/RocketHitBox
onready var sonic_hit_box = $Rocket/SonicHitBox
onready var animator : AnimationPlayer = $Rocket/RocketSprite/RocketAnimator
onready var wick : AnimatedSprite = $Rocket/RocketSprite/Wick
export var distance : float = 3.0 setget _set_distance
export var acceleration : float = 100 setget _set_acceleration
export var delay_ascend : float = 0.5
export var max_speed : float = 100 setget _set_max_speed
export var can_control : bool = true setget _set_can_control
var puff : PackedScene = preload('res://general-objects/dusts/boss-puff.tscn')

func _ready() -> void:
	if !Engine.editor_hint:
		animator.play('Idle')

func play_sounds (stream_player, audio : AudioStream, loop : bool = false):
	#var stream_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	if !stream_player.is_inside_tree():
		add_child(stream_player)
		stream_player.position = rocket.position
		stream_player.connect('finished', self, 'temp_stream_finish', [stream_player])
	stream_player.set_stream(audio)
	stream_player.set_autoplay(loop)
	stream_player.play(0)

func _set_max_speed(val : float) -> void:
	max_speed = val
	update()

func _set_can_control(val : bool) -> void:
	can_control = val
	var shade = get_node_or_null('Rocket/RocketSprite/ShaderPos')
	if shade:
		shade.set_visible(!val)
	update()

func _set_distance(val : float) -> void:
	distance = val
	update()

func _set_acceleration (val : float) -> void:
	acceleration = val
	update()

func _repeat_spawn ():
	if !rocket.is_physics_processing():
		return
	var puff_obj : AnimatedSprite = puff.instance()
	puff_obj.rotation = rocket.rotation
	add_child(puff_obj)
	puff_obj.global_position = ($Rocket/SpawnPuff.global_position)
	var time : float = (rocket.speed/max_speed) * 4 * rocket.get_physics_process_delta_time()
	get_tree().create_timer(time).connect("timeout", self, "_repeat_spawn")

func _draw() -> void:
	if true:#Engine.editor_hint:
		var acc_media = acceleration 
		if can_control:
			draw_arc($Rocket.position, distance, 0, PI*2, 360, Color(1, 0.5, 0.5, 0.5), 7.5)
		else:
			draw_line($Rocket.position, Vector2($Rocket.position.x, -distance), Color(1, .5, .5, .5), 3, true)


func temp_stream_finish(st) -> void:
	st.queue_free()

func get_class():
	return "Rocket"

func is_class(val : String) -> bool:
	return val == get_class() || .is_class(val)



func _on_Rocket_exploded():
	# Explosion Effects
	get_tree().get_current_scene().get_node('HUD').vfx_handler.flash_screen(0.1, 0.85)
	play_sounds(AudioStreamPlayer2D.new(), load('res://game-assets/audio/sfx/Explosion3.wav'), false)
	var explosion = load('res://zones/test-zone-objects/act-1-exclusive/rocket-explosion.tscn')
	var speeds = [
		Vector3(-200, -450, 0),
		Vector3(50, -500, 150),
		Vector3(200, -450, 0),
		Vector3(-50, -500, -100),
		]
	var obj = explosion.instance()
	obj.global_position = rocket.global_position
	add_child(obj)
	obj.set_as_toplevel(true)
	obj.spawn_sphere(speeds)
	#print(obj.global_position, rocket.global_position)
