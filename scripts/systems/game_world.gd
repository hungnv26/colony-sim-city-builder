extends Node2D

@onready var terrain_layer: Node2D = $WorldLayer/TerrainLayer
@onready var buildings_layer: Node2D = $WorldLayer/BuildingsLayer
@onready var units_layer: Node2D = $WorldLayer/UnitsLayer
@onready var effects_layer: Node2D = $WorldLayer/EffectsLayer

# Phase 2 world systems
const WorldTilemapScript = preload("res://scripts/systems/world_tilemap.gd")
const TerrainGeneratorScript = preload("res://scripts/systems/terrain_generator.gd")

# Phase 3 colonist systems
const ColonistManagerScript = preload("res://scripts/systems/colonist_manager.gd")

# World data
var world_tilemap: Node2D
var colonist_manager

# World configuration
@export var world_size: Vector2i = Vector2i(100, 100)
@export var world_seed: int = -1
@export var enable_phase2_terrain: bool = true
@export var enable_phase3_colonists: bool = true

func _ready() -> void:
	# Initialize the game world
	_setup_world()

	# Connect input signals
	InputManager.select_requested.connect(_on_select_requested)

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

	# Phase 3: Initialize colonists
	if enable_phase3_colonists:
		colonist_manager = ColonistManagerScript.new()
		add_child(colonist_manager)

		# Spawn colonists at world center
		var spawn_pos = Vector2(world_size.x * 16, world_size.y * 16)  # Center of world
		colonist_manager.initialize(units_layer, spawn_pos)

		# Connect colonist selection to UI
		colonist_manager.colonist_selected.connect(_on_colonist_selected)
		colonist_manager.colonist_deselected.connect(_on_colonist_deselected)

		print("Colonist system initialized with %d colonists" % colonist_manager.get_colonist_count())

func _on_select_requested(screen_position: Vector2) -> void:
	if not colonist_manager:
		return

	# Get the camera to convert screen to world position
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return

	var world_position = camera.get_global_mouse_position()

	# Try to select a colonist at this position
	var colonist = colonist_manager.get_colonist_at_position(world_position)
	if colonist:
		colonist_manager.select_colonist(colonist)
		print("Selected colonist: %s" % colonist.colonist_name)
	else:
		colonist_manager.deselect_colonist()

func _on_colonist_selected(colonist) -> void:
	# Find the game UI and show colonist info
	var game_ui = get_node("/root/GameWorld/CanvasLayer/GameUI")
	if game_ui and game_ui.has_method("show_colonist_info"):
		game_ui.show_colonist_info(colonist)

func _on_colonist_deselected() -> void:
	# Find the game UI and hide colonist info
	var game_ui = get_node("/root/GameWorld/CanvasLayer/GameUI")
	if game_ui and game_ui.has_method("hide_colonist_info"):
		game_ui.hide_colonist_info()
