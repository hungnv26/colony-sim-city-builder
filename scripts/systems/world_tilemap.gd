extends Node2D

class_name WorldTilemap

# Tile configuration
const TILE_SIZE: int = 32
const CHUNK_SIZE: int = 16  # 16x16 tiles per chunk
const TileDataScript = preload("res://scripts/systems/tile_data.gd")

# World data
var tiles: Dictionary = {}  # Vector2i -> GameTileData
var chunks: Dictionary = {}  # Vector2i (chunk coords) -> Node2D

# Terrain sprite cache
var terrain_sprites: Dictionary = {}
var resource_sprites: Dictionary = {}

# Signals
signal tile_changed(grid_pos: Vector2i, tile_data)

func _ready() -> void:
	_load_terrain_sprites()
	_load_resource_sprites()

func _load_terrain_sprites() -> void:
	# Load all pre-generated terrain SVG sprites
	var terrain_types = ["grass", "dirt", "stone", "water", "sand", "snow"]

	for terrain in terrain_types:
		terrain_sprites[terrain] = []
		for i in range(3):  # 3 variations each
			var path = "res://assets/sprites/terrain/%s_%d.svg" % [terrain, i]
			if ResourceLoader.exists(path):
				terrain_sprites[terrain].append(load(path))
			else:
				push_warning("Terrain sprite not found: %s" % path)

func _load_resource_sprites() -> void:
	# Load resource node sprites
	var resources = ["tree", "rock", "iron_ore", "gold_ore"]

	for resource in resources:
		var path = "res://assets/sprites/resources/%s.svg" % resource
		if ResourceLoader.exists(path):
			resource_sprites[resource] = load(path)
		else:
			push_warning("Resource sprite not found: %s" % path)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(floor(world_pos.x / TILE_SIZE)),
		int(floor(world_pos.y / TILE_SIZE))
	)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * TILE_SIZE, grid_pos.y * TILE_SIZE)

func get_chunk_coord(grid_pos: Vector2i) -> Vector2i:
	return Vector2i(
		int(floor(float(grid_pos.x) / CHUNK_SIZE)),
		int(floor(float(grid_pos.y) / CHUNK_SIZE))
	)

func get_tile(grid_pos: Vector2i):
	return tiles.get(grid_pos)

func set_tile(grid_pos: Vector2i, tile_data) -> void:
	tiles[grid_pos] = tile_data
	tile_data.grid_position = grid_pos
	_render_tile(grid_pos, tile_data)
	tile_changed.emit(grid_pos, tile_data)

func _render_tile(grid_pos: Vector2i, tile_data) -> void:
	# Get or create chunk
	var chunk_coord = get_chunk_coord(grid_pos)
	var chunk = _get_or_create_chunk(chunk_coord)

	# Calculate position within chunk
	var world_pos = grid_to_world(grid_pos)

	# Create sprite for this tile (terrain)
	var sprite = Sprite2D.new()
	sprite.position = world_pos + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
	sprite.name = "Tile_%d_%d" % [grid_pos.x, grid_pos.y]

	# Set terrain texture
	var terrain_name = tile_data.get_terrain_name()
	if terrain_sprites.has(terrain_name) and terrain_sprites[terrain_name].size() > 0:
		var variation_index = tile_data.terrain_variation % terrain_sprites[terrain_name].size()
		sprite.texture = terrain_sprites[terrain_name][variation_index]

	# Remove old sprite if it exists
	var old_sprite = chunk.get_node_or_null(NodePath(sprite.name))
	if old_sprite:
		old_sprite.queue_free()

	chunk.add_child(sprite)

	# Add resource sprite if present
	if tile_data.resource_type != TileDataScript.ResourceType.NONE:
		var resource_sprite = Sprite2D.new()
		resource_sprite.position = world_pos + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
		resource_sprite.name = "Resource_%d_%d" % [grid_pos.x, grid_pos.y]
		resource_sprite.z_index = 1  # Render above terrain

		var resource_name = tile_data.get_resource_name()
		if resource_sprites.has(resource_name):
			resource_sprite.texture = resource_sprites[resource_name]

		# Remove old resource sprite if it exists
		var old_resource = chunk.get_node_or_null(NodePath(resource_sprite.name))
		if old_resource:
			old_resource.queue_free()

		chunk.add_child(resource_sprite)

func _get_or_create_chunk(chunk_coord: Vector2i) -> Node2D:
	if not chunks.has(chunk_coord):
		var chunk = Node2D.new()
		chunk.name = "Chunk_%d_%d" % [chunk_coord.x, chunk_coord.y]
		add_child(chunk)
		chunks[chunk_coord] = chunk
	return chunks[chunk_coord]

func generate_tiles_in_rect(start: Vector2i, size: Vector2i, terrain_type: int) -> void:
	# Generate a rectangle of tiles (terrain_type should be from GameTileData.TerrainType enum)
	for x in range(start.x, start.x + size.x):
		for y in range(start.y, start.y + size.y):
			var grid_pos = Vector2i(x, y)
			var tile = TileDataScript.new(grid_pos, terrain_type)
			set_tile(grid_pos, tile)

func clear_all_tiles() -> void:
	# Clear all tile data
	tiles.clear()

	# Remove all chunks
	for chunk in chunks.values():
		chunk.queue_free()
	chunks.clear()
