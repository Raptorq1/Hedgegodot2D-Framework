tool
extends Area2D

enum ActivateType {
	TOGGLE=0, ACTIVATE=1, DEACTIVATE=2
}

export(ActivateType) var activate_type:int = 0
export var spin = true
export var impulse = true
export var by_scale = true
export var right = true

func _on_AutoSpin_body_entered(body):
	if body.is_class("PlayerPhysics"):
		#print("auto_roll")
		var player:PlayerPhysics = body
		if impulse:
			if !player.constant_roll:
				if by_scale:
					player.gsp += 300 * player.side
				else:
					player.gsp += 300 * Utils.Math.bool_sign(right)
		if spin:
			var type = {
				ActivateType.TOGGLE: !player.constant_roll,
				ActivateType.ACTIVATE: true,
				ActivateType.DEACTIVATE: false,
			}
			#print(type[activate_type])
			player.constant_roll = type[activate_type]
