extends FSM

func _on_TurtleFan_target_sighted():
	change_state("Wait")

func _on_CharacterAnimator_animation_finished(anim_name):
	get_current_state_node()._on_animation_finished(host, anim_name)
