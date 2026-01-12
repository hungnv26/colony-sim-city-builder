extends Node2D

@onready var terrain_layer: Node2D = $WorldLayer/TerrainLayer
@onready var buildings_layer: Node2D = $WorldLayer/BuildingsLayer
@onready var units_layer: Node2D = $WorldLayer/UnitsLayer
@onready var effects_layer: Node2D = $WorldLayer/EffectsLayer

# Phase 2 world systems
const WorldTilemapScript = preload("res://scripts/systems/world_tilemap.gd")
const TerrainGeneratorScript = preload("res://scripts/systems/terrain_generator.gd")

# World data
var world_tilemap: Node2D

# World configuration
@export var world_size: Vector2i = Vector2i(100, 100)
@export var world_seed: int = -1
@export var enable_phase2_terrain: bool = true

func _ready() -> void:
	# Initialize the game world
	_setup_world()

func _setup_world() -> void:
	if enable_phase2_terrain:
		# Phase 2: Create procedural tilemap world
		world_tilemap = WorldTilemapScript.new()
		terrain_layer.add_child(world_tilemap)

		# Generate procedural world
		print("Generating world with size: %dx%d" % [world_size.x, world_size.y])
		TerrainGeneratorScript.generate_world(world_tilemap, world_size, world_seed)

		print("Game world initialized with procedural terrain")
	else:
		# Phase 1: Test content
		const TestWorldContent = preload("res://scripts/systems/test_world_content.gd")
		var test_content = TestWorldContent.new()
		terrain_layer.add_child(test_content)
		print("Game world initialized with test content")
