tool
extends StaticNode2D
signal pushed_by_spring

export(Resource) var spring_values : Resource setget set_spring_values
export var use_parent_rotation:bool = false
onready var skin : AnimatedSprite = $Skin;
onready var jump_collide = $JumpArea/JumpCollide
onready var anim_player:AnimationPlayer = $AnimationPlayer

func _ready():
	set_rotation_degrees(rotation_degrees)

func set_rotation_degrees(val : float) -> void:
	.set_rotation_degrees(val)
	var scale_change = 1.0
	if val == 90 || val == 180 || val == -90 || val == 270:
		scale_change = -1.0
	skin.scale.x = -scale_change

func _on_JumpArea_body_entered(body):
	if body is PlayerPhysics:
		var player:PlayerPhysics = body;
		var abs_p_angle = abs(player.rotation_degrees)
		var my_rotation =  rotation_degrees if !use_parent_rotation else get_parent().rotation_degrees
		var abs_rot = abs(my_rotation)
		anim_player.play("Push", -1, 2);
		player.audio_player.play('spring');
		#var ground_angle = player.ground_angle();
		var sp : float = -spring_values.push_force * cos(deg2rad(my_rotation));
		if abs_rot == 0 or abs_rot == 180:
			if player.is_grounded:
				#player.set_ground_rays(false)
				player.is_grounded = false
				player.fsm.change_state("OnAir")
			player.snap_margin = 0
			player.speed.y = sp
			if abs_p_angle > 22.5 && abs_p_angle < 155: 
				pass
			player.spring_loaded_v = true
			player.play_specific_anim_until("SpringJump", 3.25, true, player.fsm, "state_changed")
				#player.position.y += player.speed.y * get_physics_process_delta_time()
			player.rotation = 0
		elif abs_rot == 90 or abs_rot == 270:
			if player.is_grounded:
				match player.ground_mode:
					0:
						player.gsp = spring_values.push_force*1.5 * sin(deg2rad(my_rotation));
					_:
						if abs(player.ground_mode) == 1:
							player.speed.x = spring_values.push_force * -player.ground_mode;
							player.speed = player.move_and_slide(player.speed)
							player.speed.y = 0;
						player.is_grounded = false;
						player.fsm.change_state("OnAir")
			else:
				player.speed.x = spring_values.push_force * 1.5 * sin(deg2rad(my_rotation));
		player.spring_loaded = true
		player.speed = player.move_and_slide_preset()

func set_spring_values(val : Resource):
	if !val is SpringResource or val == null: return 
	spring_values = val
	var spr : SpringResource = val as SpringResource
	if has_node("AnimationPlayer"):
		var e_anim_player = $AnimationPlayer
		for i in e_anim_player.get_animation_list():
			e_anim_player.remove_animation(i)
		e_anim_player.add_animation(spr.idle_animation.get_name(), spr.idle_animation)
		e_anim_player.add_animation(spr.push_animation.get_name(), spr.push_animation)
	if has_node("Skin"):
		var e_skin = $Skin
		e_skin.set_sprite_frames(spr.sprite_frames)
	
func _on_AnimationPlayer_animation_finished(anim_name):
	anim_player.play("RESET");
