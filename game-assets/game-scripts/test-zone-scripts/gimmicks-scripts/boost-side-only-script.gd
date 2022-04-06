extends Area2D
tool
export var left : bool = true setget set_left
export var speed: float = 760.0
onready var player_controllers = $PlayerControllers
var players_on_queue : Array = []
onready var audio_stream_player = $AudioStreamPlayer2D

class PlayerController extends Node:
	var player:PlayerPhysics
	
	func _physics_process(delta):
		var side = Utils.Math.bool_sign(owner.left)
		if abs(owner.global_position.x - player.global_position.x) < 40:
			player.move_and_slide_preset(Vector2(abs(player.speed.x) * -side, 0))
		if player.is_grounded:
			player.gsp += (player.acc * 8 * -side)
		else:
			player.speed.x += (player.acc * 8 * -side)


func _on_BoostSideOnly_body_entered(body):
	if body is PlayerPhysics:
		if players_on_queue.has(body): return
		players_on_queue.append(body)
		var controller = PlayerController.new()
		controller.player = body
		audio_stream_player.play()
		player_controllers.add_child(controller)
		controller.set_owner(self)


func _on_BoostSideOnly_body_exited(body):
	if body is PlayerPhysics:
		if !players_on_queue.has(body): return
		var position = players_on_queue.find(body)
		players_on_queue.remove(position)
		player_controllers.get_child(position).queue_free()

func set_left(val : bool):
	left = val
	if has_node("CollisionShape2D"):
		$CollisionShape2D.position.x = 33 * -Utils.Math.bool_sign(left)
