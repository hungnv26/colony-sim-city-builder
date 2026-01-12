extends RefCounted

class_name GameTileData

# Terrain types matching our SVG terrain generator
enum TerrainType {
	GRASS,
	DIRT,
	STONE,
	WATER,
	SAND,
	SNOW
}

# Resource node types
enum ResourceType {
	NONE,
	TREE,
	ROCK,
	ORE_IRON,
	ORE_GOLD
}

# Tile properties
var terrain_type: TerrainType = TerrainType.GRASS
var elevation: float = 0.0  # For future height-based mechanics
var resource_type: ResourceType = ResourceType.NONE
var resource_amount: int = 0
var is_walkable: bool = true
var terrain_variation: int = 0  # Which SVG variation to use (0-2)

# Tile coordinates
var grid_position: Vector2i = Vector2i.ZERO

func _init(pos: Vector2i = Vector2i.ZERO, terrain: TerrainType = TerrainType.GRASS) -> void:
	grid_position = pos
	terrain_type = terrain
	terrain_variation = randi() % 3  # Random variation 0-2
	_update_walkability()

func set_terrain(new_terrain: TerrainType) -> void:
	terrain_type = new_terrain
	_update_walkability()

func set_resource(type: ResourceType, amount: int = 0) -> void:
	resource_type = type
	resource_amount = amount
	if type != ResourceType.NONE:
		_update_walkability()

func harvest_resource(amount: int = 1) -> int:
	var harvested = min(amount, resource_amount)
	resource_amount -= harvested
	if resource_amount <= 0:
		resource_type = ResourceType.NONE
		_update_walkability()
	return harvested

func _update_walkability() -> void:
	# Water is not walkable, resources block walking
	is_walkable = terrain_type != TerrainType.WATER and resource_type == ResourceType.NONE

func get_terrain_name() -> String:
	match terrain_type:
		TerrainType.GRASS: return "grass"
		TerrainType.DIRT: return "dirt"
		TerrainType.STONE: return "stone"
		TerrainType.WATER: return "water"
		TerrainType.SAND: return "sand"
		TerrainType.SNOW: return "snow"
		_: return "grass"

func get_resource_name() -> String:
	match resource_type:
		ResourceType.TREE: return "tree"
		ResourceType.ROCK: return "rock"
		ResourceType.ORE_IRON: return "iron_ore"
		ResourceType.ORE_GOLD: return "gold_ore"
		_: return "none"
