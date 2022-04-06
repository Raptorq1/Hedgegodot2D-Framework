extends AnimatedSprite

signal explosion_gen_end(sph)

const explosion = preload('res://general-objects/explosions/boss-explosion-object.tscn')
export var speed : Vector3 = Vector3(0, 0, 0)
const GRAV : float = 1000.0
var friction : float = 40
var z_pos = 0.0
var time_explode_preset = 0.015

func _ready() -> void:
	if speed.z == 0 || z_index == 0:
		z_index = 10
	start_explode()

func _physics_process(delta: float) -> void:
	speed.x += -sign(speed.x) * delta
	speed.z += -sign(speed.z)*100 * delta
	speed.y += (GRAV + (speed.z*1.5)) * delta
	var vec2_speed:Vector2 = Vector2(speed.x, speed.y)
	position += vec2_speed * delta
	z_pos += (speed.z/100) * delta
	scale = Vector2.ONE * (z_pos + 1)
	scale = scale if scale > Vector2.ZERO else Vector2.ZERO
	z_index = int(z_pos*100)
	#print(timer.time_left)
	if time_explode_preset >= 0.08:
		emit_signal("explosion_gen_end", self)

func _on_ScreenSensor_screen_exited() -> void:
	yield(get_tree().create_timer(3.0), "timeout")
	emit_signal("explosion_gen_end", self)
	queue_free()

func start_explode() -> void:
	while true:
		var explosion_obj : AnimatedSprite = explosion.instance()
		explosion_obj.position = position
		explosion_obj.z_index = z_index-1
		explosion_obj.z_as_relative = false
		explosion_obj.scale = scale
		get_parent().add_child(explosion_obj)
		time_explode_preset += 0.0015
		speed_scale -= 0.1
		yield(get_tree().create_timer(time_explode_preset),"timeout")
