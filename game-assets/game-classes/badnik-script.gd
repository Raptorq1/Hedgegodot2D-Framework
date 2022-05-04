extends Hurtable
class_name Badnik

signal exploded
export var remove_parent_when_die: bool = true
var explosion_scene = preload("res://general-objects/little-explosion.tscn");
export var max_speed:Vector2 = Vector2(70,0);
var speed:Vector2 = Vector2.ZERO;
export var to_right:bool = false setget set_to_right;
export(String) var main_anim_name = "none";
export(float) var init_timer = 1;
var time:float = init_timer;
onready var explode_audio_player = get_tree().get_root().get_node("GlobalSounds")
var can_hurt: bool = true

func explode(player):
	explode_audio_player.play('Destroy');
	if player.fsm.current_state == "OnAir":
		if player.speed.y < 0:
			player.speed.y *= 0.75
		else:
			player.speed.y *= -1
	var explosion_instance = explosion_scene.instance();
	explosion_instance.set_as_toplevel(true)
	get_tree().get_current_scene().add_child(explosion_instance);
	explosion_instance.global_position = global_position;
	if get_parent() is BadnikContainer and remove_parent_when_die:
		get_parent().queue_free()
	else:
		queue_free()
	emit_signal("exploded")

func get_class():
	return "Badnik"

func is_class(class_name_value:String):
	return class_name_value == get_class()

func set_to_right(_val : bool): pass

func side_switch(_val : bool): pass
