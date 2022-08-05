extends Area2D
enum WhichLock {
	TOP, BOTTOM
}

export(WhichLock) var lock = WhichLock.TOP




func _on_ScrewNutLocker_body_entered(body):
	if body is ScrewNut:
		var sn : ScrewNut = body
		var sn_height = 24
		var push_direction = 0
		match lock:
			WhichLock.TOP: 
				sn.lock_top = true
				push_direction = 1
			WhichLock.BOTTOM:
				sn.lock_bottom = true
				push_direction = -1
		sn.position.y = position.y + sn_height * push_direction
		sn.speed = 0


func _on_ScrewNutLocker_body_exited(body):
	if body is ScrewNut:
		var sn : ScrewNut = body
		match lock:
			WhichLock.TOP: sn.lock_top = false
			WhichLock.BOTTOM: sn.lock_bottom = false
