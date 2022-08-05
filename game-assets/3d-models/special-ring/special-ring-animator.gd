extends Spatial

onready var _tween : Tween = $Tween
onready var circle = $EmeraldRingObj/Circle
onready var particles: CPUParticles = $CPUParticles
const fade_time = 1.5

func _ready():
	set_process(false)

func spawn():
	_tween.stop_all()
	_tween.interpolate_property(circle, "scale", circle.scale, Vector3.ONE, fade_time,Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	particles.set_emitting(true)
	_tween.start()
	set_process(true)

func unspawn():
	_tween.interpolate_property(circle, "scale", circle.scale, Vector3.ZERO, fade_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	particles.set_emitting(false)
	_tween.start()
	_tween.connect("tween_all_completed", self, "reset")

func reset():
	set_process(false)
	circle.rotation = Vector3.ZERO
	_tween.disconnect("tween_all_completed", self, "reset")

func _process(delta: float) -> void:
	circle.rotation += Vector3(1.0, -1.0, 1.0) * delta
	circle.rotation.x = fmod(circle.rotation.x, 360)
	circle.rotation.y = fmod(circle.rotation.y, -360)
	circle.rotation.z = fmod(circle.rotation.y, 180)
