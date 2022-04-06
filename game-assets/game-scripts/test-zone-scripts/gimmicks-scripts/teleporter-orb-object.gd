extends Node2D
tool

export var position_to_go : float = 0.0 setget set_pos_to_go
export var can_teleport: bool = true setget set_can_teleport
onready var sensor = $Sensor
onready var shoot_position = $ShootPosition
onready var charge_sfx = $charge
onready var warp_sfx = $warp
onready var sprite = $Sprite
onready var animator : AnimationPlayer = $Sprite/AnimationPlayer
onready var particles : CPUParticles2D = $Particles
onready var drawer : Node2D = $Drawer

var players_on_queue : Array setget set_players_on_queue

class TeleportOrbState extends State:
	var vt : Node2D
	var line_width : float = 0.0
	var to : Vector2 = Vector2.ZERO
	const trail_scene = preload("res://general-objects/resources/particles-resources/trail-particle.res")
	func enter(host, prev_state):
		start_gimmick(host)
	func draw_ext(host):
		if !host.fsm.is_current_state(self.name):return
		var thir = line_width / 6
		var from = Vector2(0, -7)
		vt.drawer.draw_line(from, to, Color(0x308060cc), line_width)
		vt.drawer.draw_line(from, to, Color(0xffffff30), line_width)
		vt.drawer.draw_line(from, to, Color(0xffffff30), thir*5)
		vt.drawer.draw_line(from, to, Color.white, thir*3)
	
	func start_gimmick(host):
		host.player_camera.follow_player = false
		var trail = trail_scene.instance()
		trail.to_follow = host
		add_child(trail)
		host.erase_state()
		var trail_reverse = trail_scene.instance()
		trail_reverse.to_follow = host
		trail_reverse.speed *= -1
		trail_reverse.rotation_border = deg2rad(180)
		add_child(trail_reverse)
		host.play_specific_anim_temp("Rolling")
		var tween = Tween.new()
		add_child(tween)
		
		tween.interpolate_property(self, "to:y", to.y, vt.position_to_go + (sign(vt.position_to_go) * 96), 0.5,Tween.TRANS_SINE,Tween.EASE_OUT)
		tween.interpolate_property(self, "line_width", line_width, 2.0, 2.0,Tween.TRANS_SINE,Tween.EASE_OUT)
		
		tween.interpolate_property(host, "global_position", host.global_position, vt.shoot_position.global_position, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.interpolate_property(host.player_camera, "global_position", host.player_camera.global_position, vt.shoot_position.global_position, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.interpolate_property(trail, "speed", trail.speed, 20.0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.interpolate_property(trail_reverse, "speed", trail_reverse.speed, -20.0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		vt.charge_sfx.play()
		
		
		yield(tween, "tween_all_completed")
		yield(get_tree().create_timer(0.7), "timeout")
		vt.warp_sfx.play()
		tween.interpolate_property(self, "line_width", line_width, 32.0, 0.1,Tween.TRANS_SINE,Tween.EASE_OUT)
		host.global_position = vt.global_position + (Vector2.DOWN * (vt.position_to_go + (50 * -sign(vt.position_to_go))))
		tween.interpolate_property(host.player_camera, "global_position:y", host.player_camera.global_position.y, host.global_position.y, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween.start()
		host.player_camera.follow_player = true
		yield(tween,"tween_all_completed")
		tween.interpolate_property(host, "global_position", host.global_position, vt.global_position + (Vector2.DOWN * vt.position_to_go), 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_completed")
		tween.queue_free()
		
		trail.queue_free()
		host.fsm.erase_state(self)
	
	func step(host, delta):
		vt.drawer.modulate.a = 0.8 if get_tree().get_frame() % 4 == 0 else 1.0
		vt.drawer.update()
	
	func exit(host, prev):
		vt.remove_player(host)
		vt.drawer.modulate.a = 1.0


func _ready():
	animator.playback_speed

func _on_Sensor_body_entered(body):
	if !can_teleport: return
	if body is PlayerPhysics:
		if players_on_queue.has(body):return
		players_on_queue.append(body)
		set_players_on_queue(players_on_queue)
		var state_to_add = TeleportOrbState.new()
		if !animator.is_playing():
			animator.play("start")
			particles.emitting = true
		state_to_add.vt = self
		body.fsm.insert_state(state_to_add)
		drawer.connect("draw", state_to_add, "draw_ext", [body])
		

func remove_player(val : PlayerPhysics) -> void:
	players_on_queue.remove(players_on_queue.find(val))
	set_players_on_queue(players_on_queue)
	drawer.update()

func _draw():
	if !can_teleport or !Engine.editor_hint: return
	draw_line(Vector2.ZERO, Vector2(0, position_to_go), Color(0x308060cc), 24.0, true)

func set_pos_to_go(val : float) -> void:
	position_to_go = val
	update()

func set_can_teleport(val : bool) -> void:
	can_teleport = val
	if has_node("Sensor"):
		var sensor = $Sensor
		sensor.monitoring = can_teleport
		if sensor.has_node("CollisionShape2D"):
			sensor.get_node("CollisionShape2D").set_deferred("disabled", !can_teleport)
	update()

func set_players_on_queue(val : Array) -> void:
	players_on_queue = val
	if !players_on_queue.empty(): return
	animator.play("RESET")
	particles.emitting = false

func increment_anim_speed():
	if animator.playback_speed < 6.0:
		animator.playback_speed += 0.5
