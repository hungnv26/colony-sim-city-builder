class_name TerrainGenerator

const TileDataScript = preload("res://scripts/systems/tile_data.gd")

# Generate procedural terrain using noise
static func generate_world(tilemap, world_size: Vector2i, seed_value: int = -1) -> void:
	if seed_value >= 0:
		seed(seed_value)

	# Create noise for terrain generation
	var noise = FastNoiseLite.new()
	noise.seed = randi() if seed_value < 0 else seed_value
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05

	# Create moisture noise for biome variation
	var moisture_noise = FastNoiseLite.new()
	moisture_noise.seed = noise.seed + 1000
	moisture_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	moisture_noise.frequency = 0.03

	print("Generating world terrain: %dx%d tiles (Seed: %d)" % [world_size.x, world_size.y, noise.seed])

	# Generate tiles
	for x in range(world_size.x):
		for y in range(world_size.y):
			var grid_pos = Vector2i(x, y)

			# Get noise values
			var elevation = noise.get_noise_2d(float(x), float(y))
			var moisture = moisture_noise.get_noise_2d(float(x), float(y))

			# Determine terrain type based on elevation and moisture
			var terrain_type = _determine_terrain(elevation, moisture)

			# Create tile
			var tile = TileDataScript.new(grid_pos, terrain_type)
			tile.elevation = elevation
			tilemap.set_tile(grid_pos, tile)

	print("Terrain generation complete!")

	# Place resources
	_place_resources(tilemap, world_size, noise.seed)

static func _determine_terrain(elevation: float, moisture: float) -> int:
	# Water: very low elevation
	if elevation < -0.2:
		return TileDataScript.TerrainType.WATER

	# Sand: low elevation near water
	if elevation < -0.05:
		return TileDataScript.TerrainType.SAND

	# Snow: high elevation
	if elevation > 0.4:
		return TileDataScript.TerrainType.SNOW

	# Stone: high elevation but not quite snow
	if elevation > 0.25:
		return TileDataScript.TerrainType.STONE

	# Grass vs Dirt based on moisture
	if moisture > 0.1:
		return TileDataScript.TerrainType.GRASS
	else:
		return TileDataScript.TerrainType.DIRT

static func _place_resources(tilemap: WorldTilemap, world_size: Vector2i, noise_seed: int) -> void:
	# Create noise for resource placement
	var resource_noise = FastNoiseLite.new()
	resource_noise.seed = noise_seed + 5000
	resource_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	resource_noise.frequency = 0.1

	print("Placing natural resources...")

	var trees_placed = 0
	var rocks_placed = 0
	var ore_placed = 0

	for x in range(world_size.x):
		for y in range(world_size.y):
			var grid_pos = Vector2i(x, y)
			var tile = tilemap.get_tile(grid_pos)

			if not tile or not tile.is_walkable:
				continue

			var resource_value = resource_noise.get_noise_2d(float(x), float(y))

			# Trees on grass (30% chance in suitable areas)
			if tile.terrain_type == TileDataScript.TerrainType.GRASS and resource_value > 0.4:
				tile.set_resource(TileDataScript.ResourceType.TREE, 50 + randi() % 50)
				trees_placed += 1

			# Rocks on stone/dirt (20% chance)
			elif (tile.terrain_type == TileDataScript.TerrainType.STONE or tile.terrain_type == TileDataScript.TerrainType.DIRT) and resource_value > 0.6:
				tile.set_resource(TileDataScript.ResourceType.ROCK, 30 + randi() % 30)
				rocks_placed += 1

			# Ore on stone (10% chance)
			elif tile.terrain_type == TileDataScript.TerrainType.STONE and resource_value > 0.75:
				var ore_type = TileDataScript.ResourceType.ORE_IRON if randf() > 0.2 else TileDataScript.ResourceType.ORE_GOLD
				tile.set_resource(ore_type, 20 + randi() % 30)
				ore_placed += 1

	print("Resources placed: %d trees, %d rocks, %d ore deposits" % [trees_placed, rocks_placed, ore_placed])
