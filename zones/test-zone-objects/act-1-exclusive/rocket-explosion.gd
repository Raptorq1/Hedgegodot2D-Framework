extends Node2D

const SPHERE = preload('res://zones/test-zone-objects/act-1-exclusive/player-rocket-explosion-sphere.tscn')
const SPHERE_SCRIPT = preload('res://zones/test-zone-objects/act-1-exclusive/rocket-explosion-sphere.gd')
var all_spheres : Array = []
var wait_time = 0.05
var exploding : bool = true

func _ready() -> void:
	set_process(false)
	start()

func spawn_sphere(speeds : PoolVector3Array) -> Array:
	for speed in speeds:
		var sp_object : SPHERE_SCRIPT = SPHERE.instance()
		sp_object.connect('explosion_gen_end', self, '_one_less')
		sp_object.position = Vector2.ZERO
		sp_object.speed = speed
		sp_object.z_as_relative = false
		add_child(sp_object)
		all_spheres.append(sp_object)
	
	return all_spheres

func _one_less(obj) -> void:
	if all_spheres.has(obj):
		all_spheres.remove(all_spheres.find(obj))
	if all_spheres.size() <= 0:
		exploding = false
		queue_free()

func start() -> void:
	while true:
		if !exploding: break
		wait_time += 0.0015
		$AudioStreamPlayer.play()
		yield(get_tree().create_timer(wait_time), "timeout")
