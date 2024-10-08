extends Area2D


export var to_right: bool = true

func _on_EndPlatformThrow_body_entered(body):
	if body.is_class('PlayerPhysics'):
		var p : PlayerPhysics = body as PlayerPhysics
		if sign(p.speed.x) != Utils.Math.bool_sign(to_right):
			return
		if p.is_grounded and abs(p.gsp) > 270:
			p.fsm.change_state('OnAir')
			p.speed.y = p.gsp/1.5 * -cos(p.rotation)
			p.erase_snap()
			p.is_grounded = false
			p.throwed = true
			p.move_and_slide_preset()
			p.play_specific_anim_until("Rotating", 3.0, true)
