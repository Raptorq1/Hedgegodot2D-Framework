extends Node2D
tool

const height : int = 40
const width : int = 24

export var length : int = 1 setget _set_length

func _set_length(val : int) -> void:
	length = max(1, val)
	update_grabs()

func update_grabs () -> void:
	var sp = get_node_or_null('GrabTopArea/Grab')
	var coll_size = get_node_or_null("GrabTopArea/MainShape")
	var move_area
	if sp && coll_size:
		coll_size.shape.extents.x = (width/2 * length)-4
		coll_size.position.x = (width/2 * length) - (width / 2)
		sp.position.x = (width/2 * length) - (width/3)
		sp.region_rect.size.x = width * length



func _on_GrabTopArea_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		if p.suspended_jump:
			return
		if p.fsm.current_state != 'Suspended':
			p.fsm.change_state('Suspended')
			var grab = get_node_or_null('GrabTopArea')
			var snap : Vector2
			snap.y = global_position.y + Utils.Collision.get_height_of_shape(p.main_collider.shape) + 10
			var size = (global_position.x + (24*(length-1))) -  global_position.x
			var diff = round((p.global_position.x - global_position.x)/24)*24
			snap.x = diff + global_position.x
			if snap.x > global_position.x + 24 * (length-2):
				snap.x -= 24
			elif snap.x < global_position.x:
				snap.x += 24
			#print('d: %f, sz: %f, sn: %f, gb: %f' % [diff, size, snap.x, global_position.x])
			p.global_position.y = snap.y
			p.global_position.x = snap.x


func _on_GrabTopArea_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		if p.suspended_jump:
			pass
			#p.suspended_jump = false
