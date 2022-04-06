extends Area2D


export var to_right: bool = true

func _on_EndPlatformThrow_body_shape_entered(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body.is_class('PlayerPhysics'):
		var p : PlayerPhysics = body as PlayerPhysics
		#print(sign(p.speed.x), Utils.sign_bool(to_right))
		
		if sign(p.speed.x) != Utils.Math.bool_sign(to_right):
			return
		if p.is_grounded && abs(p.gsp) > 270:
			p.speed.y = p.gsp/1.5 * -cos(p.rotation)
			p.throwed = true
			p.move_and_slide_preset()
			p.fsm.change_state('OnAir')


func _on_EndPlatformThrow_body_entered(body):
	if body.is_class('PlayerPhysics'):
		var p : PlayerPhysics = body as PlayerPhysics
		#print(sign(p.speed.x), Utils.sign_bool(to_right))
		
		if sign(p.speed.x) != Utils.Math.bool_sign(to_right):
			return
		if p.is_grounded && abs(p.gsp) > 270:
			p.speed.y = p.gsp/1.5 * -cos(p.rotation)
			p.throwed = true
			p.move_and_slide_preset()
			p.fsm.change_state('OnAir')
