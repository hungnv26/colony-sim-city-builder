## A* pathfinding implementation for colonist navigation
class_name Pathfinding
extends RefCounted

## A node in the pathfinding grid
class PathNode:
	var position: Vector2i
	var g_cost: float = INF  # Cost from start
	var h_cost: float = 0.0  # Heuristic cost to end
	var f_cost: float = INF  # Total cost (g + h)
	var parent: PathNode = null
	var is_walkable: bool = true

	func _init(pos: Vector2i, walkable: bool = true) -> void:
		position = pos
		is_walkable = walkable

	func calculate_f_cost() -> void:
		f_cost = g_cost + h_cost

## Find a path from start to end position using A*
## Returns an array of Vector2 world positions, or empty array if no path found
static func find_path(start_pos: Vector2, end_pos: Vector2, world) -> Array:
	if world == null:
		return []

	var tilemap = world.get_tilemap()
	if tilemap == null:
		return []

	# Convert world positions to tile coordinates
	var start_tile = tilemap.local_to_map(start_pos)
	var end_tile = tilemap.local_to_map(end_pos)

	# Check if end tile is walkable
	var end_tile_data = tilemap.get_tile_data(start_tile, end_tile)
	if end_tile_data == null:
		return []
	if not end_tile_data.is_walkable:
		# Resources (trees, rocks, ore) block walking, so path to a tile beside them
		end_tile = _nearest_walkable_neighbor(end_tile, start_tile, tilemap)
		if end_tile == Vector2i(-1, -1):
			return []

	# Initialize open and closed sets
	var open_set: Array = []
	var closed_set: Dictionary = {}  # position -> PathNode
	var all_nodes: Dictionary = {}  # position -> PathNode

	# Create start node
	var start_node = PathNode.new(start_tile, true)
	start_node.g_cost = 0
	start_node.h_cost = _heuristic(start_tile, end_tile)
	start_node.calculate_f_cost()
	open_set.append(start_node)
	all_nodes[start_tile] = start_node

	# A* main loop
	while open_set.size() > 0:
		# Find node with lowest f_cost
		var current_node = _get_lowest_f_cost_node(open_set)

		# Remove from open set and add to closed set
		open_set.erase(current_node)
		closed_set[current_node.position] = current_node

		# Check if we reached the goal
		if current_node.position == end_tile:
			return _retrace_path(start_node, current_node, tilemap)

		# Check all neighbors
		var neighbors = _get_neighbors(current_node.position)
		for neighbor_pos in neighbors:
			# Skip if in closed set
			if closed_set.has(neighbor_pos):
				continue

			# Check if walkable
			var tile_data = tilemap.get_tile_data(start_tile, neighbor_pos)
			if tile_data == null or not tile_data.is_walkable:
				continue

			# Calculate costs
			var movement_cost = _get_movement_cost(current_node.position, neighbor_pos)
			var tentative_g_cost = current_node.g_cost + movement_cost

			# Get or create neighbor node
			var neighbor_node: PathNode
			if all_nodes.has(neighbor_pos):
				neighbor_node = all_nodes[neighbor_pos]
			else:
				neighbor_node = PathNode.new(neighbor_pos, true)
				neighbor_node.h_cost = _heuristic(neighbor_pos, end_tile)
				all_nodes[neighbor_pos] = neighbor_node

			# Update node if we found a better path
			if tentative_g_cost < neighbor_node.g_cost:
				neighbor_node.parent = current_node
				neighbor_node.g_cost = tentative_g_cost
				neighbor_node.calculate_f_cost()

				# Add to open set if not already there
				if not open_set.has(neighbor_node):
					open_set.append(neighbor_node)

	# No path found
	return []

## Get the node with the lowest f_cost from the open set
static func _get_lowest_f_cost_node(open_set: Array) -> PathNode:
	var lowest_node = open_set[0]
	for i in range(1, open_set.size()):
		var node = open_set[i]
		if node.f_cost < lowest_node.f_cost or (node.f_cost == lowest_node.f_cost and node.h_cost < lowest_node.h_cost):
			lowest_node = node
	return lowest_node

## Find the walkable neighbor of a tile that is closest to the start tile
## Returns Vector2i(-1, -1) if the tile is fully enclosed
static func _nearest_walkable_neighbor(tile: Vector2i, start_tile: Vector2i, tilemap) -> Vector2i:
	var best = Vector2i(-1, -1)
	var best_distance = INF
	for neighbor_pos in _get_neighbors(tile):
		var tile_data = tilemap.get_tile_data(start_tile, neighbor_pos)
		if tile_data == null or not tile_data.is_walkable:
			continue
		var distance = _heuristic(start_tile, neighbor_pos)
		if distance < best_distance:
			best_distance = distance
			best = neighbor_pos
	return best

## Get all valid neighbor positions (8-directional)
static func _get_neighbors(pos: Vector2i) -> Array:
	return [
		Vector2i(pos.x - 1, pos.y),     # Left
		Vector2i(pos.x + 1, pos.y),     # Right
		Vector2i(pos.x, pos.y - 1),     # Up
		Vector2i(pos.x, pos.y + 1),     # Down
		Vector2i(pos.x - 1, pos.y - 1), # Top-left
		Vector2i(pos.x + 1, pos.y - 1), # Top-right
		Vector2i(pos.x - 1, pos.y + 1), # Bottom-left
		Vector2i(pos.x + 1, pos.y + 1), # Bottom-right
	]

## Calculate heuristic cost (Manhattan distance)
static func _heuristic(from: Vector2i, to: Vector2i) -> float:
	return abs(to.x - from.x) + abs(to.y - from.y)

## Calculate movement cost between adjacent tiles
static func _get_movement_cost(from: Vector2i, to: Vector2i) -> float:
	# Diagonal movement costs more (sqrt(2) ≈ 1.414)
	if abs(to.x - from.x) + abs(to.y - from.y) == 2:
		return 1.414
	return 1.0

## Retrace the path from end to start
static func _retrace_path(start_node: PathNode, end_node: PathNode, tilemap) -> Array:
	var path: Array = []
	var current_node = end_node

	while current_node != start_node:
		# Convert tile position to world position
		var world_pos = tilemap.map_to_local(current_node.position)
		path.append(world_pos)
		current_node = current_node.parent

		# Safety check
		if current_node == null:
			break

	# Reverse the path so it goes from start to end
	path.reverse()
	return path

## Simplify a path by removing unnecessary intermediate points
static func simplify_path(path: Array) -> Array:
	if path.size() <= 2:
		return path

	var simplified: Array = [path[0]]

	for i in range(1, path.size() - 1):
		var prev = path[i - 1]
		var current = path[i]
		var next = path[i + 1]

		# Check if current point is on the same line as prev and next
		var dir1 = (current - prev).normalized()
		var dir2 = (next - current).normalized()

		# If directions are significantly different, keep the point
		if dir1.distance_to(dir2) > 0.01:
			simplified.append(current)

	simplified.append(path[path.size() - 1])
	return simplified
