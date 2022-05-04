extends Area2D


export var to_right: bool = true

func _on_EndPlatformThrow_body_entered(body):
	if body.is_class('PlayerPhysics'):
		var p : PlayerPhysics = body as PlayerPhysics
		if sign(p.speed.x) != Utils.Math.bool_sign(to_right):
			return
		if p.is_grounded && abs(p.gsp) > 270:
			p.speed.y = p.gsp/1.5 * -cos(p.rotation)
			p.throwed = true
			p.move_and_slide_preset()
			p.fsm.change_state('OnAir')
			p.fsm.play_specific_anim_temp("Rotating", 3.0, true, 3.0)
