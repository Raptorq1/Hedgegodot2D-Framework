extends Node2D
tool

class_name PlayerCamera

export(bool) var enabled = true

export(float) var vertical_offset setget _set_ver_offset
export(float) var horizontal_offset setget _set_hor_offset

export(bool) var follow_player = true;
export(bool) var followUp = false;
export(bool) var followLeft = true;
export(bool) var followRight = true;
export(bool) var followDown = true;


export(float) var LEFT = -16 setget _set_left
export(float) var RIGHT = .0 setget _set_right
export(float) var GROUND_TOP = .0 setget _set_gtop
export(float) var GROUND_BOTTOM = .0 setget _set_gbottom
export(float) var AIR_TOP = 48 setget set_air_top
export(float) var AIR_BOTTOM = -16 setget set_air_bottom

export(float) var SCROLL_UP = -104
export(float) var SCROLL_DOWN = 88
export(float) var SCROLL_SPEED = 120
export(float) var SCROLL_DELAY = 2

onready var camera_scroll = $CameraScroll
onready var camera : Camera2D = $CameraScroll/Camera2D

var scroll_timer : float
export(bool) var rotate_with_player:bool = false
var stuck_in_object:bool
var object_to_stuck : Node2D;
var secondary_target:Node2D;

func camera_ready(player : PlayerPhysics) -> void:
	position = player.position
	set_as_toplevel(true)

func can_scroll(delta : float):
	if scroll_timer > 0:
		scroll_timer -= delta
		return false
	
	return true

func _set_left(val : float) -> void:
	LEFT = val
	update()
func _set_right(val : float) -> void:
	RIGHT = val
	update()
func _set_gtop(val : float) -> void:
	GROUND_TOP = val
	update()
func _set_gbottom(val : float) -> void:
	GROUND_BOTTOM = val
	update()
func set_air_top(val : float) -> void:
	AIR_TOP = val
	update()
func set_air_bottom(val : float) -> void:
	AIR_BOTTOM = val
	update()

func _set_hor_offset(val : float) -> void:
	if camera:
		horizontal_offset = val
		camera.position.x = horizontal_offset

func _set_ver_offset(val : float) -> void:
	if camera:
		vertical_offset = val
		camera.position.y = vertical_offset

func camera_step(player : PlayerPhysics, delta : float):
	if !stuck_in_object:
		horizontal_border(player, delta)
		vertical_border(player, delta)
		vertical_scrolling(player, delta);
		if rotate_with_player:
			if !secondary_target:
				return
			var dir = (player.position - secondary_target.position).normalized();
			rotation = lerp_angle(rotation, player.rotation, delta*10)
			position += (secondary_target.position - position) * delta * 10
			position.y -= 20 * cos(rotation);
			position.x -= 20 * -sin(rotation)
		else:
			rotation = lerp_angle(rotation, 0, delta*10)
	else:
		if object_to_stuck:
			var vel_default = 4
			if object_to_stuck.position.x > position.x + RIGHT:
				position.x += min(object_to_stuck.position.x - (position.x + RIGHT), vel_default)
			elif player.position.x < position.x + LEFT:
				position.x += max(object_to_stuck.position.x - (position.x + LEFT), -vel_default)
			
			if object_to_stuck.position.y > position.y + GROUND_TOP:
				position.y += min(object_to_stuck.position.y - (position.y + GROUND_TOP), vel_default)
			elif object_to_stuck.position.y < position.y + GROUND_BOTTOM:
				position.y += max(object_to_stuck.position.y - (position.y + GROUND_BOTTOM), -vel_default)

func horizontal_border(player : PlayerPhysics, delta:float):
	if !follow_player:
		return
	var speed_x : float
	if player.position.x > position.x + RIGHT && followRight:
		speed_x = min(player.position.x - (position.x + RIGHT), 16)
	elif player.position.x < position.x + LEFT && followLeft:
		speed_x = max(player.position.x - (position.x + LEFT), -16)
	position.x += speed_x

func vertical_border(player : PlayerPhysics, delta:float):
	if !follow_player:
		return
	var vel : float;
	if player.is_grounded:
		var player_cam_offset = player.position.y - position.y
		if player_cam_offset != 0:
			if abs(player.speed.y) <= 360:
				vel = max(min(player_cam_offset, 6), -6)
			else:
				vel = max(min(player_cam_offset, 16), -16)
			if (vel < 0 && !followUp) || (vel > 0 && !followDown):
				return
			position.y += vel
		return
	
	if player.position.y < position.y - AIR_TOP:
		position.y += max(player.position.y - (position.y - AIR_TOP), -16)
	elif player.position.y > position.y + AIR_BOTTOM:
		position.y += min(player.position.y - (position.y + AIR_BOTTOM), 16)

func vertical_scrolling(player : PlayerPhysics, delta : float):
	var scroll_back = true
	var scroll_world = camera_scroll.global_position
	
	if player.fsm.is_current_state("LookUp"):
		if can_scroll(delta):
			camera_scroll.position.y -= SCROLL_SPEED * delta
			camera_scroll.position.y = max(camera_scroll.position.y, SCROLL_UP)
			scroll_back = false
	elif player.fsm.is_current_state("Crouch"):
		if can_scroll(delta):
			camera_scroll.position.y += SCROLL_SPEED * delta
			camera_scroll.position.y = min(camera_scroll.position.y, SCROLL_DOWN)
			scroll_back = false
	else:
		scroll_timer = SCROLL_DELAY
	
	if scroll_back:
		if camera_scroll.position.y > 0:
			camera_scroll.position.y -= SCROLL_SPEED * delta
			camera_scroll.position.y = max(camera_scroll.position.y, 0)
		elif camera_scroll.position.y < 0:
			camera_scroll.position.y += SCROLL_SPEED * delta
			camera_scroll.position.y = min(camera_scroll.position.y, 0)

func delay(secs:float = -1):
	follow_player = false
	var timer = Timer.new();
	self.add_child(timer);
	timer.start(secs);
	timer.connect("timeout", self, "followAgain", [timer]);
	

func followAgain(timerNode:Timer):
	remove_child(timerNode);
	follow_player = true

func _draw() -> void:
	#if Engine.editor_hint:
	if !Engine.editor_hint:
		return
	var drag_color: Color = Color.aqua
	var drag_color_g: Color = Color.blueviolet
	draw_line(Vector2(LEFT, AIR_BOTTOM), Vector2(LEFT, -AIR_TOP), drag_color, 2.0)
	draw_line(Vector2(LEFT, -AIR_TOP), Vector2(RIGHT, -AIR_TOP), drag_color, 2.0)
	draw_line(Vector2(RIGHT, -AIR_TOP), Vector2(RIGHT, AIR_BOTTOM), drag_color, 2.0)
	draw_line(Vector2(RIGHT, AIR_BOTTOM), Vector2(LEFT, AIR_BOTTOM), drag_color, 2.0)
	draw_line(Vector2(LEFT, -GROUND_TOP), Vector2(RIGHT, -GROUND_TOP), drag_color_g, 2.0)
	draw_line(Vector2(LEFT, GROUND_BOTTOM), Vector2(RIGHT, GROUND_BOTTOM), drag_color_g, 2.0)
