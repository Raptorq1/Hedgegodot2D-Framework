extends StateChar

var drop_press : bool;
var drop_charging : bool
var drop_dust : PackedScene = preload("res://general-objects/players-objects/drop-dash-dust.tscn");
var drop_timer
var can_attack : bool = false
var attacked : bool = false

func state_enter(host, prev_statem, state = null):
	drop_press = true
	drop_charging = false

func state_physics_process(host, delta, state = null):
	if host.spring_loaded or host.spring_loaded_v:
		cancel_drop()

func state_exit(host, next_state, state = null) -> void:
	if next_state == "OnGround" or next_state == "Idle":
		if drop_charging:
			var dust:Node2D = drop_dust.instance();
			add_child(dust);
			dust.position = host.position;
			dust.get_child(0).scale.x = host.character.scale.x
			if host.player_camera:
				host.player_camera.delay(0.1);
			host.fsm.call_deferred("change_state", "Rolling")
			if abs(host.gsp) < host.selected_character_node.drp_max:
				#print(host.gsp)
				host.gsp = (host.gsp / 4) if (sign(host.character.scale.x) == sign(host.gsp)) else host.gsp / 2
				host.gsp += host.selected_character_node.drp_spd * host.character.scale.x;
				host.gsp = min(host.gsp, host.selected_character_node.drp_max)
				host.gsp = max(host.gsp, -host.selected_character_node.drp_max)
				
			host.audio_player.play("spin_dash_release")
	cancel_drop()
	attacked = false
	can_attack = false

func state_animation_process(host: PlayerPhysics, delta:float, animator:CharacterAnimator, state:State = null):
	var anim_name = animator.current_animation
	var anim_speed = animator.get_playing_speed()
	if !state:
		return
	if state.has_jumped or state.has_rolled:
		if drop_charging:
			state.set_state_animation_processing(false)
			anim_name = 'DropCharge';
			anim_speed = 4.5;
	
	var inst = host.player_vfx.vfx['InstaShield'] as AnimationPlayer
	animator.animate(anim_name, anim_speed, true)

func _dropTimeOut(host, state) -> void:
	drop_charging = true;
	host.audio_player.play('drop_dash_charge');
	drop_timer.queue_free()
	drop_timer = null

func cancel_drop() -> void:
	drop_press = false;
	drop_charging = false;
	if drop_timer:
		drop_timer.queue_free()
		drop_timer = null

func state_input(host : PlayerPhysics, event, state:State=null):
	var ui_jump = "ui_jump_i%d" % host.player_index
	if state.has_jumped:
		if !host.spring_loaded:
			if host.selected_character_node.insta_shield:
				if Input.is_action_just_released(ui_jump) and state.has_jumped:
					if !attacked:
						can_attack = state.has_jumped
				if Input.is_action_just_pressed(ui_jump) and can_attack:
					#print(host.shield_container.activated)
					if host.shield_container.activated:
						handle_shield_attack(host)
						return
					attacked = true
					host.invulnerable_until(host.get_tree().create_timer(0.15), "timeout")
					host.player_vfx.play('InstaShield', true)
					host.audio_player.play('insta_shield')
					can_attack = false
					state.roll_jump = false
					attack(host)
		if host.selected_character_node.drop_dash and !host.shield_container.activated:
			handle_drop_charge(host, event, state)

func handle_drop_charge(host, event, state:State):
	var ui_jump = "ui_jump_i%d" % host.player_index
	if !Input.is_action_pressed(ui_jump):
		drop_press = false
	if Input.is_action_just_pressed(ui_jump) && !drop_press:
		drop_press = true
		drop_timer = Timer.new()
		host.add_child(drop_timer)
		drop_timer.start(0.325)
		drop_timer.connect("timeout", self, "_dropTimeOut", [host,state])
	if Input.is_action_just_released(ui_jump):
		cancel_drop()

func handle_shield_attack(host : PlayerPhysics):
	var shield : Shield = host.shield_container.shield
	shield.use_hability(host)
	attacked = true
	can_attack = false
	host.is_attacking = true
	yield(host.shield_container.shield, "hability_ended")
	host.is_attacking = false

func attack(host):
	host.is_attacking = true
	var timer = host.get_tree().create_timer(0.2)
	host.invulnerable_until(timer, "timeout")
	yield(timer ,"timeout")
	host.is_attacking = false
