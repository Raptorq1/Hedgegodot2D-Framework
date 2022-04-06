extends Area2D
tool

var dive : PackedScene = preload('res://general-objects/water-dive-object.tscn')
onready var coll_shape:CollisionShape2D = Utils.Nodes.get_node_by_type(self, 'CollisionShape2D')
export var size : Vector2
var overlaps:Dictionary
export var color : Color = Color(0, 0.5, 0.7, 0.5) setget _update_color
func _ready() -> void:
	var edi_coll_shape : CollisionShape2D = Utils.Nodes.get_node_by_type(self, 'CollisionShape2D')
	size = edi_coll_shape.shape.extents

func spawn_dive(p : PlayerPhysics, overlap:Array, local_shape:int):
	var dive_obj : AnimatedSprite = dive.instance()
	var overlapp = overlap[0]
	var shape_owner = shape_owner_get_owner(local_shape)
	var shape_owner_id = shape_find_owner(local_shape)
	var shape_collided = shape_owner_get_shape(shape_owner_id, local_shape)
	print(overlapp, shape_owner.position.y - shape_collided.extents.y)
	var minx : float
	var maxx : float
	if shape_collided is RectangleShape2D:
		var sh : RectangleShape2D = shape_collided
		if overlapp.y > shape_owner.position.y - sh.extents.y:
			return
		maxx = shape_owner.position.x + sh.extents.x
		minx = shape_owner.position.x - sh.extents.x
	elif shape_collided is ConvexPolygonShape2D:
		var sh : ConvexPolygonShape2D = shape_collided
		minx = Utils.UArray.get_x_of_poolvec2(sh.points).min()
		maxx = Utils.UArray.get_x_of_poolvec2(sh.points).max()
		pass
	dive_obj.position = overlapp+position
	dive_obj.position.x = position.x - min(maxx-44, max(minx+44, position.x-p.position.x))
	#print(minx, maxx)
	dive_obj.position.y -= 32
	dive_obj.z_index = 100
	dive_obj.set_as_toplevel(true)
	add_child(dive_obj)
	return dive_obj

func _draw() -> void:
	if !size:
		size = Utils.Nodes.get_node_by_type(self, 'CollisionShape2D').shape.extents
	if !coll_shape:
		coll_shape = Utils.Nodes.get_node_by_type(self, 'CollisionShape2D')
	draw_rect(Rect2(coll_shape.position-size, size*2), color)
	#print(size)

func _update_color(val : Color) -> void:
	color = val
	update()


func _on_WaterLevel_area_shape_entered(area_rid: RID, area: Area2D, area_shape: int, local_shape: int) -> void:
	if Engine.editor_hint || !area:
		return
	if area.name == 'WaterSensor':
		var p : PlayerPhysics = area.get_parent()
		p.underwater = true
		overlaps[p] = Utils.Collision.get_area2D_coll_overlap(self, area_rid, area, area_shape, local_shape)
		if overlaps.has(p):
			spawn_dive(p, overlaps[p], local_shape)


func _on_WaterLevel_area_shape_exited(area_id: int, area: Area2D, area_shape: int, local_shape: int) -> void:
	if Engine.editor_hint || !area:
		return
	if area.name == 'WaterSensor':
		var p : PlayerPhysics = area.get_parent()
		p.underwater = false
		if overlaps.has(p):
			spawn_dive(p, overlaps[p], local_shape)
			overlaps.erase(p)
