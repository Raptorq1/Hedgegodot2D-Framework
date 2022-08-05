extends Node2D
tool
var players = []
var next
var prev
onready var coll = $Collision
var to_top : bool = false
var speed = 0.0

export var chain_size : float = 16.0 setget _set_chain_size
export var chain_length : int = 1 setget _set_chain_length
export(float, 0, 1, 0.1) var grab_position_from : float = 1.0 setget _set_grab_position_from
export(float, 0, 1, 0.1) var grab_position : float = 1.0 setget _set_grab_position
export(float, 0, 1, 0.1) var grab_position_to : float = 1.0
export var animation_duration : float = 1.0
export var can_move_right_top:bool
export var can_move_right_bottom:bool
export var can_move_left_top:bool
export var can_move_left_bottom:bool

func _ready() -> void:
	set_physics_process(false)
	if !Engine.editor_hint:
		_set_grab_position(grab_position_from)

func _set_chain_size(val : float) -> void:
	chain_size = val
	update_grab ()

func _set_chain_length ( val : int ) -> void:
	chain_length = max(val, 0)
	update_grab ()

func _set_grab_position_from (val : float) -> void:
	grab_position_from = min(1.0, max(0.0, val))
	grab_position = grab_position_from
	update_grab ()

func _set_grab_position (val : float) -> void:
	grab_position = min(1.0, max(0.0, val))
	update_grab ()

func update_grab() -> void:
	var chain = get_node_or_null('Chain')
	var grab  = get_node_or_null('Collision')
	if chain && grab:
		var total_size = chain_size * chain_length
		chain.offset.y = -total_size/2
		chain.position.y = grab_position * (total_size)
		chain.region_rect = Rect2(Vector2(0, 0), Vector2(7, chain_length*chain_size))
		grab.position.y = (total_size * grab_position) + 20
		update()


func _on_Collision_body_shape_entered(body_rid: RID, body: Node, body_shape: int, local_shape: int) -> void:
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		if p.suspended_jump:
			return
		if !players.has(p):
			players.append(p)
		if players.size() > 0:
			to_top = true
			var grab = get_node_or_null('Collision')
			if !p.fsm.is_current_state('Suspended'):
				p.global_position.x = grab.global_position.x
			p.fsm.change_state('Suspended')
			p.global_position.y = grab.global_position.y + Utils.Collision.get_height_of_shape(p.main_collider.shape) + 10
			p.player_camera.followUp = false
			p.player_camera.followDown = false
			set_physics_process(true)
			p.suspended_can_left = false
			p.suspended_can_right = false


func _on_Collision_body_shape_exited(body_id: RID, body: Node, body_shape: int, local_shape: int) -> void:
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		if p.suspended_jump:
			pass
			#p.suspended_jump = false
		p.player_camera.followUp = true
		p.player_camera.followDown = true
		players.remove(players.find(p))
		if players.size() <= 0:
			to_top = false
			set_physics_process(true)
			

func _physics_process(delta: float) -> void:
	var direction = Utils.Math.bool_sign(to_top) * Utils.Math.bools_sign(grab_position_from>=grab_position_to, grab_position_from<grab_position_to)
	
	for p in players:
		if p.global_position.x != global_position.x:
			p.global_position.x += (global_position.x - p.global_position.x) * delta
			if abs(p.global_position.x - global_position.x) < 1:
				p.global_position.x = global_position.x
			return
	var abs_speed = abs(speed)
	var abs_grab_pos = abs(grab_position)
	
	var top_pos = min(grab_position_from, grab_position_to)
	var bottom_pos = max(grab_position_from, grab_position_to)
	
	var half_pos = abs(top_pos - bottom_pos)
	var max_speed = 300
	if ((abs_grab_pos > half_pos and direction < 0) or (abs_grab_pos <= half_pos and direction > 0)) or !to_top:
		speed += direction*2 * delta
	elif (abs_grab_pos <= half_pos and to_top and direction < 0) or (abs_grab_pos > half_pos and to_top and direction > 0):
		speed = (grab_position_to - grab_position) * 2
		if abs(speed) < 0.3:
			speed = 0.3 * sign((grab_position_to - grab_position))
	speed = clamp(speed, -max_speed, max_speed)
	_set_grab_position(clamp(grab_position + (speed * delta), top_pos, bottom_pos))
	
	for p in players:
		if p.global_position.x != global_position.x:
			return
		if p.fsm.current_state == "Suspended":
			p.global_position.y = coll.global_position.y + Utils.Collision.get_height_of_shape(p.main_collider.shape) + 10
			if p.player_camera.global_position.y != p.global_position.y:
				p.player_camera.global_position.y += (p.global_position.y - p.player_camera.global_position.y) * delta * 10
		else:
			players.remove(players.find(p))
	
	if (grab_position <= top_pos and direction < 0) or (grab_position >= bottom_pos and direction > 0):
		set_physics_process(false)
		speed = 0
	
	if grab_position > top_pos and grab_position < bottom_pos:
		_set_players_props("suspended_can_left", false)
		_set_players_props("suspended_can_right", false)
	else:
		if grab_position >= bottom_pos:
			_set_players_props("suspended_can_left", can_move_left_bottom)
			_set_players_props("suspended_can_right", can_move_right_bottom)
		elif grab_position <= top_pos:
			_set_players_props("suspended_can_left", can_move_left_top)
			_set_players_props("suspended_can_right", can_move_right_top)

func _set_players_props(prop: String, value) -> void:
	for i in players.size():
		if !players[i]:
			continue
		var p : PlayerPhysics = players[i]
		if p.fsm.current_state != "Suspended":
			players.remove(i)
			continue
		p.set(prop, value)
		
