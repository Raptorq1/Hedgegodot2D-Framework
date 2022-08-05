tool
extends Area2D

enum ActivateType {
	TOGGLE=0, ACTIVATE=1, DEACTIVATE=2
}

export(ActivateType) var activate_type:int = 0
export var constant:bool = true
export var spin = true
var boost_on_activate = true setget set_boost_on_activate
var boost_on_deactivate: bool = false setget set_boost_on_deactivate
var boost_speed:float = 300.0
var to_center: bool = false setget set_to_center
var by_side = true setget set_by_side
var to_right = true

func _on_AutoSpin_body_entered(body):
	if body.is_class("PlayerPhysics"):
		var player:PlayerPhysics = body
		if player.is_grounded == false:
			player.fsm.connect("state_changed", self, 'intermediate_fn', [], CONNECT_ONESHOT)
			return
		handle_player(player)

func _on_AutoSpin_body_exited(body: Node) -> void:
	if body.is_class("PlayerPhysics"):
		var player:PlayerPhysics = body
		if player.fsm.is_connected("state_changed", self, 'intermediate_fn'):
			player.fsm.disconnect("state_changed", self, 'intermediate_fn')

func intermediate_fn(prev_state, cur_state, p):
	handle_player(p)

func handle_player(player:PlayerPhysics):
	if player.is_grounded == false: return
	if spin:
		if constant:
			match activate_type:
				ActivateType.TOGGLE: deactivate_player(player) if player.constant_roll else activate_player(player)
				ActivateType.ACTIVATE: activate_player(player)
				ActivateType.DEACTIVATE: deactivate_player(player)
				_: return
		else:
			if boost_on_activate:
				boost_player(player)
			player.fsm.change_state("Rolling")

func activate_player(player:PlayerPhysics):
	if boost_on_activate:
		boost_player(player)
	player.constant_roll = true

func deactivate_player(player:PlayerPhysics):
	if boost_on_deactivate:
		boost_player(player)
	player.constant_roll = false

func boost_player(player):
	if to_center:
		player.gsp += boost_speed * sign(global_position.x - player.global_position.x)
	else:
		if by_side:
			player.gsp += boost_speed * player.side
		else:
			player.gsp += boost_speed * Utils.Math.bool_sign(to_right)

func _get_property_list() -> Array:
	var props : Array = []
	
	props.append({
		"name": "boost/boost_on_activate",
		"type": TYPE_BOOL
	})
	props.append({
		"name": "boost/boost_on_deactivate",
		"type": TYPE_BOOL
	})
	if boost_on_activate or boost_on_deactivate:
		props.append({
			"name": "boost/boost_speed",
			"type": TYPE_REAL
		})
	
	
	props.append({
		"name": "direction/to_center",
		"type": TYPE_BOOL
	})
	
	if !to_center:
		props.append({
			"name": "direction/by_side",
			"type": TYPE_BOOL
		})
	
		if !by_side:
			props.append({
				"name": "direction/to_right",
				"type": TYPE_BOOL
			})
	
	return props

func _set(property: String, value) -> bool:
	match property:
		"direction/to_center":
			set_to_center(value)
			return true
		"direction/by_side":
			set_by_side(value)
			return true
		"direction/to_right":
			to_right = value
			return true
		"boost/boost_on_activate":
			set_boost_on_activate(value)
			return true
		"boost/boost_on_deactivate":
			set_boost_on_deactivate(value)
			return true
		"boost/boost_speed":
			boost_speed = value
			return true
	return false

func _get(property: String):
	match property:
		"direction/to_center":
			return to_center
		"direction/by_side":
			return by_side
		"direction/to_right":
			return to_right
		"boost/boost_on_activate":
			return boost_on_activate
		"boost/boost_on_deactivate":
			return boost_on_deactivate
		"boost/boost_speed":
			return boost_speed

func set_boost_on_activate(val : bool) -> void:
	boost_on_activate = val
	property_list_changed_notify()

func set_boost_on_deactivate(val : bool) -> void:
	boost_on_deactivate = val
	property_list_changed_notify()

func set_by_side(val : bool) -> void:
	by_side = val
	property_list_changed_notify()

func set_to_center(val : bool) -> void:
	to_center = val
	property_list_changed_notify()
