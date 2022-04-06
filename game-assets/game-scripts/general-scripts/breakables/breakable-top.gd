extends Breakable
onready var positions = $Positions

export var bounce_factor = 1.0

func _on_Trigger_body_entered(body):
	if body.is_class('PlayerPhysics'):
		var player:PlayerPhysics = body
		if player.speed.y <= 0 or (!player.fsm.is_current_state('OnAir') && !player.fsm.is_current_state("Rolling")):
			return
		var speed = body.speed.y
		global_sounds.play('CliffBreaking')
		global_sounds.play('WallBreak')
		for i in positions.get_children():
			var p : Vector2 = i.position
			var spy = speed * cos(positions.position.angle_to(p))
			var spx = speed/2 * -sin(positions.position.angle_to(p))
			spawnBlock(p - Vector2(0, -16), Vector2(spx, spy), body)
			queue_free()
		if player.fsm.is_current_state('OnAir'):
			player.speed.y += player.speed.y * -bounce_factor
			player.move_and_slide_preset()
