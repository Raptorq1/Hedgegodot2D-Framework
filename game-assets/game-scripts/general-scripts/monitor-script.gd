extends KinematicBody2D
class_name ItemBox
tool
signal exploded
var yspeed = 0.0
onready var spawn_pos = global_position
var explode : PackedScene = preload('res://general-objects/item-boxes/item-box-explosion-object.tscn')

onready var base_sprite = $base
onready var object_sprite = $Display/ObjectIndicator
onready var explode_area = $ExplodeArea
onready var cshape : CollisionShape2D = Utils.Nodes.get_node_by_type(self, 'CollisionShape2D')

func _ready() -> void:
	set_physics_process(false)
	if !Engine.editor_hint:
		for i in get_children():
			if i is Area2D:
				i.connect('body_entered', self, '_on_ExplodeArea_body_entered')
		if !get_tree().get_current_scene().has_node('Players'):
			return
		#var player = get_tree().current_scene.get_node('Players').get_node('Player').CHARACTER_SELECTED

func _action(player : PlayerPhysics) -> void:
	pass

func _push_player(player : PlayerPhysics) -> void:
	if player.is_grounded:return
	if player.fsm.current_state == "OnAir":
		if player.speed.y < 0:
			player.speed.y *= 0.75
		else:
			player.speed.y *= -1

func _on_ExplodeArea_body_entered(body: Node) -> void:
	if body is PlayerPhysics:
		if body.global_position.y < $JumpPosition.global_position.y:
			emit_signal('exploded')
			$AnimationPlayer.play('JumpExplode')
			var explosion_obj : AnimatedSprite = explode.instance()
			explosion_obj.position = base_sprite.position + Vector2(0, -8)
			add_child(explosion_obj)
			cshape.set_deferred('disabled', true)
			explode_area.queue_free()
			for i in base_sprite.get_children():
				i.queue_free()
			base_sprite.frame = int(rand_range(1, 3))
			get_node("/root/AutoloadSoundMachine").play('Destroy')
			_push_player(body)
			get_tree().create_timer(0.5).connect('timeout', self, '_timeout_action', [body])
			return
		if body.speed.y < 0:
			yspeed = body.speed.y if body.speed.y > -200 else -200
			set_physics_process(true)
			
			body.speed.y = 10

func _physics_process(delta: float) -> void:
	yspeed += 600 * delta
	
	yspeed = move_and_slide(Vector2.DOWN * yspeed, Vector2.UP, true, 4, 0, false).y
	#print(yspeed)
	if is_on_floor():
		yspeed = 0
		set_physics_process(false)

func _timeout_action(body : Node) -> void:
	_action(body)
