extends Area2D
class_name CameraTrigger

export(Vector2) var cam_offset
export(Vector2) var cam_position
export(bool) var animate_enter = false
export(bool) var animate_exit = false
export(float) var animations_duration = 0.5
export(bool) var follow_player
export(bool) var follow_left
export(bool) var follow_right
export(bool) var follow_up
export(bool) var follow_down
export(bool) var reset_when_exit = false
var prev_state = []
func _ready() -> void:
	connect('body_shape_entered', self, '_player_entered')
	connect('body_shape_exited', self, '_player_exited')

func _player_entered(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body.is_class('PlayerPhysics'):
		var player : PlayerPhysics = body
		if !player.im_main_player:
			return
		var camera : PlayerCamera = get_tree().get_current_scene().get_node('PlayerCamera')
		prev_state = [
			camera.follow_player, camera.followLeft, camera.followRight,
			camera.followUp, camera.followDown, camera.horizontal_offset,
			camera.vertical_offset, camera.position
		]
		camera.follow_player = follow_player
		camera.followLeft = follow_left
		camera.followRight = follow_right
		camera.followUp = follow_up
		camera.followDown = follow_down
		if !animate_enter:
			camera.horizontal_offset = cam_offset.x
			camera.vertical_offset = cam_offset.y
			if !follow_player:
				camera.position = position + cam_position
		else:
			var tween: Tween = Tween.new()
			tween.interpolate_property(camera, 'horizontal_offset', camera.horizontal_offset, cam_offset.x, animations_duration)
			tween.interpolate_property(camera, 'vertical_offset', camera.vertical_offset, cam_offset.y, animations_duration)
			if !follow_player:
				tween.interpolate_property(camera, 'position', camera.position, position + cam_position, animations_duration)
			tween.connect('tween_all_completed', self, '_animation_ended', [tween])
			add_child(tween)
			tween.start()

func _animation_ended(tween:Tween) -> void:
	tween.queue_free()

func _player_exited(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body.is_class('PlayerPhysics'):
		var player : PlayerPhysics = body
		if !player.im_main_player:
			return
		var camera : PlayerCamera = get_tree().get_current_scene().get_node('PlayerCamera')
		if reset_when_exit:
			camera.follow_player = true
			camera.followLeft = true
			camera.followRight = true
			camera.followUp = true
			camera.followDown = true
			if !animate_exit:
				camera.horizontal_offset = 0.0
				camera.vertical_offset = 0.0
			else:
				var tween = Tween.new()
				tween.interpolate_property(camera, 'horizontal_offset', camera.horizontal_offset, 0.0, animations_duration)
				tween.interpolate_property(camera, 'vertical_offset', camera.vertical_offset, 0.0, animations_duration)
				tween.connect('tween_all_completed', self, '_animation_ended', [tween])
				add_child(tween)
				tween.start()
			return
		camera.follow_player = prev_state[0]
		camera.followLeft = prev_state[1]
		camera.followRight = prev_state[2]
		camera.followUp = prev_state[3]
		camera.followDown = prev_state[4]
		if !animate_exit:
			camera.horizontal_offset = prev_state[5]
			camera.vertical_offset = prev_state[6]
			if !follow_player:
				camera.position = prev_state[7]
		else:
			var tween: Tween = Tween.new()
			tween.interpolate_property(camera, 'horizontal_offset', camera.horizontal_offset, prev_state[5], animations_duration)
			tween.interpolate_property(camera, 'vertical_offset', camera.vertical_offset, prev_state[6], animations_duration)
			if !follow_player:
				tween.interpolate_property(camera, 'position', camera.position, prev_state[7], animations_duration)
			tween.connect('tween_all_completed', self, '_animation_ended', [tween])
			add_child(tween)
			tween.start()
