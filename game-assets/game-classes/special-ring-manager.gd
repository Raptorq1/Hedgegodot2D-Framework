extends Node2D
tool

onready var particles : CPUParticles2D = $CPUParticles2D
onready var sprite = get_node('SpecialRingSprite')
onready var viewport_model = sprite.get_node('3DVisual')
onready var model = viewport_model.get_node('EmeraldRing')
onready var tween : Tween = $Tween

func _ready() -> void:
	var texture = viewport_model.get_texture()
	if texture:
		sprite.texture = texture


func _on_VisibilityEnabler2D_screen_entered() -> void:
	model.spawn()
	tween.interpolate_property(particles, "emission_sphere_radius", particles.emission_sphere_radius, 70.0, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	particles.set_emitting(true)


func _on_VisibilityEnabler2D_screen_exited() -> void:
	model.unspawn()
	tween.interpolate_property(particles, "emission_sphere_radius", particles.emission_sphere_radius, 0.01, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	particles.set_emitting(false)
