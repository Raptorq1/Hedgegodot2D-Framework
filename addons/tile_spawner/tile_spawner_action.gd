extends Node

enum Align {
	NONE,
	ROUND,
	FLOOR,
	CEIL,
	TRUNCATE
}

const UUID_TILE_SPAWNER_CONTROLS = "be2d8857-0633-431f-bc92-302da269bccd"
const UUID_TILE_SPAWNER = "ddfc5ec5-af82-4234-8aca-24678ee59958"

static func spawn_from_tilemap(tree, tile_spawner):
	# Validate & get tilemap node
	var source_tilemap : TileMap = tile_spawner.get_source_tilemap()
	if source_tilemap == null or not source_tilemap is TileMap:
		# Ensure the node select for source tilemap is correct
		print("Error: Source tilemap must be a TileMap!")
		return

	# Validate & get target node
	var target_node = tile_spawner.get_target_node()
	if target_node == null or not target_node is CanvasItem:
		# Ensure the node select for source tilemap is correct
		print("Error: Target node must be a CanvasItem!")
		return

	# Validate & get the mapping
	var mapping_path = tile_spawner.mapping
	#var mapping_file = File.new()
	if mapping_path == null:
		# Make sure the mapping file exists
		print("Error: Mapping file for TileSpawner does not exist!")
		return
	#if mapping_file.open(tile_spawner.mapping, File.READ) != OK:
		# Make sure the mapping file opened
	#	print("Error: Could not open the mapping file for TileSpawner!")
	#	return
	var mapping_res:TileSpawnerResource = tile_spawner.mapping
	#mapping_file.close()
	if !mapping_res is TileSpawnerResource:
		# Make sure the mapping file is formatted correctly
		print("Error: Mapping file for TileSpawner must be a res object!")
		return
	var mapping = mapping_res.objects
	#print(mapping)

	# Using the tilemap's cell_tile_origin, find an offset for each node
	var origin_offset = Vector2()
	if source_tilemap.cell_tile_origin == TileMap.TILE_ORIGIN_TOP_LEFT:
		origin_offset = source_tilemap.cell_size / 2
	elif source_tilemap.cell_tile_origin == TileMap.TILE_ORIGIN_CENTER:
		origin_offset = source_tilemap.cell_size
	elif source_tilemap.cell_tile_origin == TileMap.TILE_ORIGIN_BOTTOM_LEFT:
		origin_offset = Vector2(source_tilemap.cell_size.x / 2, source_tilemap.cell_size.y * 3 / 2)

	# Optionally, clear children in the target node
	if tile_spawner.clear_children_before_baking:
		unparent_children(target_node)

	# For each tile, spawn a child into the target node
	for cellv in source_tilemap.get_used_cells():
		# Figure out the tile name for this cell
		var tile_set = source_tilemap.tile_set
		var tile_index = source_tilemap.get_cellv(cellv)
		var tile_name = tile_set.tile_get_name(tile_index)

		# Ignore tiles with no mapping
		if not mapping.has(tile_name):
			continue

		# Get the mapping entry for this tile name
		var mapping_entry = mapping[tile_name]

		# Using the entry, find the scene path for this tile name
		var scene_path = mapping_entry['scene']

		# Add the child
		var child : Node2D = spawn_child(tree.get_edited_scene_root(), target_node, scene_path)

		# Find the transform for the tile
		var orientation_transform : Transform2D = get_cell_orientation_transform(source_tilemap, cellv)
		var tile_transform : Transform2D = source_tilemap.global_transform * orientation_transform

		# Compute origin of the tile
		var origin : Vector2 = source_tilemap.global_transform.xform(source_tilemap.map_to_world(cellv) + origin_offset)
		# Snap origin to pixel grid
		origin = snap_to_pixel_grid(origin, tile_spawner.grid_alignment)
		tile_transform.origin = origin
		
		var offset: Vector2 = Vector2.ZERO
		if !source_tilemap.centered_textures:
			offset = source_tilemap.cell_size
			#print("name: %s, orot: %f, oscale: %s" % [child.name, rad2deg(tile_transform.get_rotation()), tile_transform.get_scale()])
			if floor(rad2deg(abs(orientation_transform.get_rotation()))) == 180 or orientation_transform.get_scale().y < 0:
				offset.y *= -1
			elif floor(rad2deg(orientation_transform.get_rotation())) == 90:
				offset.x *= -1
		# Set the transform
		child.global_transform = tile_transform
		
		child.global_transform.origin = child.global_transform.origin + (offset/2)
		
		# Set all properties of instance
		if mapping_entry.has('properties'):
			var scene_props = mapping_entry['properties']
			for k in scene_props:
				var v = scene_props[k]
				child.set(k, v)

static func unparent_children(parent_node):
	var nodes = []
	for child_node in parent_node.get_children():
		parent_node.remove_child(child_node)
		child_node.set_owner(null)
		nodes.push_back(child_node)
	return nodes

static func spawn_child(scene_root, parent, scene_path):
	var node
	node = load(scene_path).instance()
	node.filename = scene_path
	parent.add_child(node)
	node.position = Vector2(0,0)
	node.set_owner(scene_root)
	node.set_name(node.name)
	return node

# Given a vector and an alignment type, return a new, aligned version
# of that vector
static func snap_to_pixel_grid(vec, align):
	if align == Align.ROUND:
		return Vector2(round(vec.x), round(vec.y))
	elif align == Align.FLOOR:
		return Vector2(floor(vec.x), floor(vec.y))
	elif align == Align.CEIL:
		return Vector2(ceil(vec.x), ceil(vec.y))
	elif align == Align.TRUNCATE:
		return Vector2(int(vec.x), int(vec.y))
	else:
		return vec

# Given a TileMap and a cell coordinate, return a Transform that represents
# the given rotation/mirroring etc.
static func get_cell_orientation_transform(tile_map, cellv) -> Transform2D:
	var transform = Transform2D(Vector2(1, 0), Vector2(0, 1), Vector2(0, 0))
	if tile_map.is_cell_transposed(cellv.x, cellv.y):
		var x_axis = Vector2(transform.x.x, transform.x.y)
		transform.x = -Vector2(transform.y.x, transform.y.y)
		transform.y = -x_axis
	if tile_map.is_cell_x_flipped(cellv.x, cellv.y):
		transform.x = -transform.x
	if tile_map.is_cell_y_flipped(cellv.x, cellv.y):
		transform.y = -transform.y

	return transform

# Given a node, free all children of that node
static func free_children(parent_node):
	for child_node in parent_node.get_children():
		child_node.free()
