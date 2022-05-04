extends BossArea
tool
func _on_Boss_died(node) -> void:
	boss_defeated = true
	get_tree().create_timer(1.0).connect("timeout", sign_obj, "start_falling")
	change_track()
	if change_area_after_boss_defeated:
		set_player_area_to(post_boss_area)

func change_track():
	var tween = Utils.Nodes.new_tween(self)
	tween.interpolate_property(boss_music_node, "volume_db", boss_music_node.volume_db, -27, 1.0, Tween.TRANS_LINEAR, 1.0)
	tween.start()
	
	yield(tween,"tween_all_completed")
	boss_music_node.stop()
	stage_music_node.volume_db = 0.0
	stage_music_node.play()
