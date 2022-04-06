extends Boss

const TIME_TO_CHARGE = 1.5
const SHOOT_TIME = 3.0
const SCREEN_SHAKER = preload("res://game-assets/game-scripts/general-scripts/camera-effects/camera-shaker.gd")
const HOTARU = preload("res://zones/test-zone-objects/badnik-objects/hotaru.tscn")
const EXPLOSION_SPAWNER = preload("res://general-objects/players-objects/explosion-generator.tscn")
const BOSS_PUFF = preload("res://general-objects/dusts/boss-puff.tscn")

var max_speed_unit: float = 500
onready var animator = $Character/BodyPlayer
onready var fsm = $FSM
onready var fx = $"../ColorRect"
onready var character:Node2D = $Character
onready var laser_preview:AnimatedSprite = character.get_node("LaserPreview")
onready var laser_sfx:AudioStreamPlayer = $Laser
onready var flash_sfx:AudioStreamPlayer = $Flash
onready var charge_sfx:AudioStreamPlayer = $Charge
onready var boss_hit:AudioStreamPlayer = $Hit
onready var flyup_sfx:AudioStreamPlayer = $FlyUp
onready var timer_charge : Timer = $ChargeTimer
onready var timer_shoot : Timer = $ShootTimer
onready var laser_hitbox: Area2D = $Character/Laser/Area2D
var instanced_hotarus : Array = []

var camera_shake : SCREEN_SHAKER
var rot : float = 0.0
var charging = false setget set_charge
var shoot : bool = false setget set_shoot

func _ready() -> void:
	._ready()
	fsm._on_host_ready(self)

func physics_step(delta):
	rot += delta * 5
	character.position = Utils.Math.angle2Vec2(rot) * 5
	damage_only = charging or shoot

func give_point_to_go():
	var all_positions : PoolVector2Array = [
		Vector2(-150, -58),
		Vector2(150, -58),
		Vector2(-150, 32),
		Vector2(150, 32),
		Vector2(-70, 0),
		Vector2(70, 0),
	]
	return all_positions[round(rand_range(0, 5))]

func move_and_slide_preset():
	return move_and_slide(speed, Vector2.UP)

func appear():
	position = Vector2.ZERO
	$Character/AppearPlayer.animate("Appear")
	yield($Character/AppearPlayer, "animation_finished")
	#print("finish")
	animator.animate('Idle')
	fsm.set_activated(true)
	can_take_hit = true

func set_charge(val : bool):
	charging = val
	if charging:
		charge_sfx.play()
		timer_charge.start(TIME_TO_CHARGE)
	else:
		timer_charge.stop()

func charged_and_shoot():
	set_charge(false)
	set_shoot(true)

func set_shoot(val : bool):
	shoot = val
	if shoot:
		laser_sfx.play()
		timer_shoot.start(SHOOT_TIME)
		for i in area.players:
			camera_shake = SCREEN_SHAKER.new()
			i.player_camera.camera.add_child(camera_shake)
			camera_shake.shake(SHOOT_TIME, 100.0, 2.5, false)
			camera_shake.add_to_group("miniboss-camera-shaker")
	else:
		var miniboss_camera_shaker = get_tree().get_nodes_in_group("miniboss-camera-shaker")
		for i in miniboss_camera_shaker:
			i.queue_free()
		laser_sfx.stop()
		timer_shoot.stop()
		modulate.r = 1.0
	laser_hitbox.set_deferred("monitoring", shoot)
	

func _on_ChargeTimer_timeout() -> void:
	charged_and_shoot()


func _on_ShootTimer_timeout() -> void:
	set_shoot(false)


func _on_TZAct1Boss_damage(pre_hit_hp, current_hp) -> void:
	
	if current_hp == 6 or current_hp == 4 or current_hp == 2:
		var hotaru = HOTARU.instance()
		instanced_hotarus.push_back(hotaru)
		var current_hotaru = instanced_hotarus.size()
		if !area.has_node("Hotaru%d" % current_hotaru):return
		max_speed_unit += 50
		var hotaru_pos : Position2D = area.get_node("Hotaru%d" % current_hotaru)
		print(hotaru_pos)
		hotaru.position.x = hotaru_pos.position.x
		hotaru.position.y = - area.extents.y * 1.5
		hotaru.boss = self
		area.add_child(hotaru)
		var tween = Tween.new()
		tween.interpolate_property(hotaru, "position:y", hotaru.position.y, hotaru_pos.position.y, 0.75,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		area.add_child(tween)
		tween.start()
		tween.connect("tween_all_completed", tween, "ended")


func on_damage():
	boss_hit.play()
	can_take_hit = false
	for i in 60:
		if get_tree().get_frame() % 4 == 0:
			modulate.r = 3.0
			modulate.g = 3.0
			modulate.b = .0
			modulate.a = 0.5
		else:
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0
			modulate.a = 1.0
		yield(get_tree(),"idle_frame") 
	can_take_hit = true
	modulate.r = 1.0
	modulate.g = 1.0
	modulate.b = 1.0
	modulate.a = 1.0
	
func on_destroy():
	can_take_hit = false
	set_shoot(false)
	set_charge(false)
	fsm.set_activated(false)
	animator.stop()
	for i in instanced_hotarus:
		var boss_puff = BOSS_PUFF.instance()
		boss_puff.position = i.position
		area.add_child(boss_puff)
		i.queue_free()
	var explosion_generator = EXPLOSION_SPAWNER.instance()
	add_child(explosion_generator)
	explosion_generator.position = Vector2.ZERO
	explosion_generator.connect("finished", self, "make_invisible")
	explosion_generator.connect("explosion_cleared", self, "disappear")

func make_invisible():
	animator.animate("RESET")
	character.set_visible(false)

func disappear():
	emit_signal("died", self)
	queue_free()
