extends KinematicBody2D
signal sign_positioned
export(NodePath) var boss_area

var sparkle : PackedScene = preload('res://general-objects/ring-sparkle-object.tscn')
export var start_from_air : bool
export var jump_when_pass : bool
var speed : Vector2 = Vector2.ZERO
export var GRV:float = 110
export var DEC:float = 10
var was_in_air : bool 
onready var ray_cast: RayCast2D = $RayCast2D
onready var anim_player: AnimationPlayer = $Animation/AnimationPlayer
onready var tween: Tween = $Tween
onready var vic_timer : Timer = $VictoryTimer
onready var spark_timer : Timer = $SparkleTimer
onready var audio_player : AudioPlayer = $AudioPlayer

func _ready() -> void:
	if boss_area:
		get_node(boss_area).sign_obj = self
	set_physics_process(false)

func start_falling():
	if start_from_air:
		set_physics_process(true)
		audio_player.play('twinkle')
		anim_player.playback_speed = 15.0
		anim_player.play('Rotating', -1, 1)
		was_in_air = true
		#audio_player.play('sign-post')
		spark_timer.start(0.25)

func _on_Area_body_shape_entered(body_id: RID, body: Node, body_shape: int, local_shape: int) -> void:
	if body is PlayerPhysics:
		for i in get_tree().get_nodes_in_group("Players"):
			add_collision_exception_with(i)
		if !is_physics_processing() && !was_in_air:
			speed.y = -150
			if jump_when_pass:
				set_physics_process(true)
			anim_player.playback_speed = 15.0
			anim_player.play('Rotating', -1, 1)
			was_in_air = true
			audio_player.play('sign-post')
			spark_timer.start(0.25)
		else:
			if is_physics_processing():
				var prev_sp = speed
				speed.x = clamp(body.speed.x, -110, 110) if abs(body.speed.x) >= 110 else speed.x
				speed.y = clamp(body.speed.y, -110, -50) if abs(body.speed.y) >= 50 else speed.y
				if speed != prev_sp:
					audio_player.play('twinkle')
	
func _physics_process(delta: float) -> void:
	speed = move_and_slide(speed)
	if ray_cast.is_colliding() && (ray_cast.get_collision_point() - position).y <= 32 && speed.y >= 0:
		set_physics_process(false)
		speed.x = 0
		spark_timer.stop()
	speed.y += GRV * delta
	speed.x += -sign(speed.x) * DEC * delta

func can_stop():
	if is_physics_processing():
		return
	if anim_player.playback_speed > 10:
		anim_player.playback_speed = 10
		return
	anim_player.playback_speed -= 5
	if anim_player.playback_speed <= 0:
		anim_player.stop(false)
		anim_player.seek(2.0, true)
		vic_timer.start(1)
	spark_timer.stop()

func _on_VictoryTimer_timeout() -> void:
	anim_player.playback_speed = 1.5
	anim_player.play('finished_animation', -1, 1.0, false)
	vic_timer.stop()
	get_node("../ActContainer").connect_and_mute(self, "emit_signal", ["sign_positioned"])

func _on_SparkleTimer_timeout() -> void:
	var spark_obj : Node2D = sparkle.instance()
	spark_obj.set_as_toplevel(true)
	spark_obj.animation = 2
	spark_obj.position = global_position
	var angle = randf() * TAU
	spark_obj.position += Vector2(cos(angle), sin(angle)) * rand_range(0, 30)
	add_child(spark_obj)
	spark_obj.z_index = 100
	spark_timer.start(0.1)
