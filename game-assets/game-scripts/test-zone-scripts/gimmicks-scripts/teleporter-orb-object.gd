extends Node2D
tool

export var can_teleport: bool = true setget set_can_teleport
var position_to_teleport : float = 0.0 setget set_pos_to_tp
onready var sensor = $Sensor
onready var pre_tp_position = $PreTPPosition
onready var charge_sfx = $charge
onready var warp_sfx = $warp
onready var sprite = $Sprite
onready var animator : AnimationPlayer = $Sprite/AnimationPlayer
onready var particles : CPUParticles2D = $Particles
onready var drawer : Node2D = $Drawer

var players_on_queue : Array setget set_players_on_queue

class TeleportOrbState extends State:
	var tween : Tween
	var vt : Node2D
	var line_width : float = 0.0
	var to : Vector2 = Vector2.ZERO
	const trail_scene = preload("res://general-objects/resources/particles-resources/trail-particle.res")
	var trail_clockwise : Node2D
	var trail_counter_clockwise: Node2D
	
	func state_enter(host, prev_state):
		tween = Utils.Nodes.new_tween(host)
		start_gimmick(host)

	func draw_ext(host):
		if !host.fsm.is_current_state(name):return
		var thir = line_width / 6
		var from = Vector2(0, -7)
		vt.drawer.draw_line(from, to, Color(0x308060cc), line_width)
		vt.drawer.draw_line(from, to, Color(0xffffff30), line_width)
		vt.drawer.draw_line(from, to, Color(0xffffff30), thir*5)
		vt.drawer.draw_line(from, to, Color.white, thir*3)

	func start_gimmick(host):
		host.player_camera.follow_player = false
		trail_clockwise = trail_scene.instance()
		trail_clockwise.to_follow = host
		
		trail_counter_clockwise = trail_scene.instance()
		trail_counter_clockwise.to_follow = host
		trail_counter_clockwise.speed *= -1
		trail_counter_clockwise.rotation_border = deg2rad(180)
		
		host.add_child(trail_clockwise)
		host.add_child(trail_counter_clockwise)
		
		host.erase_state()
		host.play_specific_anim_until("Rolling")
		charge(host)
	
	func charge(host):
##		For 3.5+ Only:
#		tween.tween_property(self, "to:y", vt.position_to_go + (sign(vt.position_to_teleport) * 96), 0.5)
#		tween.tween_property(self, "line_width", 2.0, 2.0)
#		tween.tween_property(host, "global_position", vt.pre_tp_position.global_position, 2.0)
#		tween.tween_property(host.player_camera, "global_position", vt.pre_tp_position.global_position, 2.0)
#		tween.tween_property(trail, "speed", 20.0, 2.0)
#		tween.tween_property(trail_reverse, "speed", -20.0, 2.0)
		var time = 2.75
		# tween lazer width and height
		tween.interpolate_property(self, "to:y", to.y, vt.position_to_teleport + (sign(vt.position_to_teleport) * 96), 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween.interpolate_property(self, "line_width", line_width, 2.0, time, Tween.TRANS_SINE, Tween.EASE_OUT)
		
		# tween player and camera position value to "pre_tp_position" (Position it will be before teleport)
		tween.interpolate_property(host, "global_position", host.global_position, vt.pre_tp_position.global_position, time, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween.interpolate_property(host.player_camera, "global_position", host.player_camera.global_position, vt.pre_tp_position.global_position, time, Tween.TRANS_SINE, Tween.EASE_OUT)
		
		# increase trail position
		var time_trail = 2.0
		tween.interpolate_property(trail_clockwise, "speed", trail_clockwise.speed, 25.0, time_trail)
		tween.interpolate_property(trail_counter_clockwise, "speed", trail_counter_clockwise.speed, -25.0, time_trail)
		
		var amount_max = 250
		tween.interpolate_property(trail_clockwise.front, "amount", trail_clockwise.front, amount_max, time_trail)
		tween.interpolate_property(trail_clockwise.back, "amount", trail_clockwise.front, amount_max, time_trail)
		tween.interpolate_property(trail_counter_clockwise.front, "amount", trail_counter_clockwise.front, amount_max, time_trail)
		tween.interpolate_property(trail_counter_clockwise.back, "amount", trail_counter_clockwise.front, amount_max, time_trail)

		
		vt.charge_sfx.play()
		tween.start()
		
		tween.connect("tween_all_completed", self, "teleport", [host], CONNECT_ONESHOT)

	func teleport(host):
		vt.warp_sfx.play()
		
		# Tween lazer width
		tween.interpolate_property(self, "line_width", line_width, 32.0, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
		
		host.global_position = vt.global_position + (Vector2.DOWN * (vt.position_to_teleport + (50 * -sign(vt.position_to_teleport))))
		
		# Tween camera to new player position
		tween.interpolate_property(host.player_camera, "global_position:y", host.player_camera.global_position.y, host.global_position.y, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
		host.player_camera.follow_player = true
		
		tween.start()
		tween.connect("tween_all_completed", self, "ascend_fx", [host])

	func ascend_fx(host):
		# Tween player position above the teleport position (Visual effect only)
		tween.interpolate_property(self, "line_width", line_width, 1, 0.25, Tween.TRANS_SINE, Tween.EASE_IN, 0.25)
		tween.interpolate_property(host, "global_position", host.global_position, vt.global_position + (Vector2.DOWN * vt.position_to_teleport), 1.0)
		tween.start()
		tween.connect("tween_all_completed", self, "end_gimmick", [host])

	func end_gimmick(host):
		trail_clockwise.queue_free()
		trail_counter_clockwise.queue_free()
		tween.queue_free()
		
		host.fsm.erase_state(name, "OnAir")
		host.speed = Vector2.ZERO

	
	func state_physics_process(host, delta):
		vt.drawer.modulate.a = 0.8 if host.get_tree().get_frame() % 4 == 0 else 1.0
		vt.drawer.update()
	
	func state_exit(host, prev):
		vt.remove_player(host)
		vt.drawer.modulate.a = 1.0

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
	var circles_radius = 12
	var circle_color = Color(0x60b090cc)
	draw_line(Vector2.ZERO, Vector2(0, position_to_teleport), Color(0x308060cc), 24.0, true)
	if has_node("PreTPPosition"):
		draw_circle($PreTPPosition.position, circles_radius, circle_color)
	draw_circle(Vector2.DOWN * position_to_teleport, circles_radius, circle_color)

func set_pos_to_tp(val : float) -> void:
	position_to_teleport = val
	update()

func set_can_teleport(val : bool) -> void:
	can_teleport = val
	if has_node("Sensor"):
		var sensor = $Sensor
		sensor.monitoring = can_teleport
		if sensor.has_node("CollisionShape2D"):
			sensor.get_node("CollisionShape2D").set_deferred("disabled", !can_teleport)
	update()
	property_list_changed_notify()

func set_players_on_queue(val : Array) -> void:
	players_on_queue = val
	if !players_on_queue.empty(): return
	animator.play("RESET")
	particles.emitting = false

func increment_anim_speed():
	if animator.playback_speed < 6.0:
		animator.playback_speed += 0.5

func _get_property_list():
	var props := []
	if can_teleport:
		props.append({
			"name": "position_to_teleport",
			"type": TYPE_REAL
		})
	
	return props
