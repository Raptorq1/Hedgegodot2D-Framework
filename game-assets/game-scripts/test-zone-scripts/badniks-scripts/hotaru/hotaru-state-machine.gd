extends FSM


func _on_CharacterAnimator_animation_finished(anim_name: String) -> void:
	get_current_state_node().state_animation_finished(host, anim_name)


func _on_CharacterAnimator_animation_started(anim_name: String) -> void:
	get_current_state_node().state_animation_started(host, anim_name)
