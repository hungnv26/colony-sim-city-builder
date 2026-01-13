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

# Phase 4 building systems
const BuildingManagerScript = preload("res://scripts/systems/building_manager.gd")

# Phase 5 harvest systems
const HarvestManagerScript = preload("res://scripts/systems/harvest_manager.gd")

# World data
var world_tilemap: Node2D
var colonist_manager
var building_manager
var harvest_manager

# World configuration
@export var world_size: Vector2i = Vector2i(100, 100)
@export var world_seed: int = -1
@export var enable_phase2_terrain: bool = true
@export var enable_phase3_colonists: bool = true
@export var enable_phase4_buildings: bool = true
@export var enable_phase5_harvesting: bool = true

func _ready() -> void:
	# Initialize the game world
	_setup_world()

	# Connect input signals
	InputManager.select_requested.connect(_on_select_requested)
	InputManager.right_click_requested.connect(_on_right_click_requested)

func _process(_delta: float) -> void:
	# Update building placement preview
	if building_manager and building_manager.is_placing_building:
		var mouse_pos = get_global_mouse_position()
		building_manager.update_placement_preview(mouse_pos, world_tilemap)

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

	# Phase 4: Initialize building system
	if enable_phase4_buildings:
		building_manager = BuildingManagerScript.new()
		add_child(building_manager)
		building_manager.initialize(buildings_layer)

		# Connect building signals
		building_manager.placement_mode_changed.connect(_on_placement_mode_changed)
		building_manager.construction_needed.connect(_on_construction_needed)

		print("Building system initialized")

	# Phase 5: Initialize harvest system
	if enable_phase5_harvesting and colonist_manager and world_tilemap:
		harvest_manager = HarvestManagerScript.new()
		add_child(harvest_manager)
		harvest_manager.initialize(colonist_manager, world_tilemap, effects_layer)

		print("Harvest system initialized")

func _on_select_requested(_screen_position: Vector2) -> void:
	# Get world position
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return

	var world_position = camera.get_global_mouse_position()

	# Check if we're in building placement mode
	if building_manager and building_manager.is_placing_building:
		# Confirm building placement
		building_manager.confirm_placement(world_tilemap)
		return

	# Otherwise try to select a colonist
	if not colonist_manager:
		return

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

# Public API for accessing world systems

func get_tilemap():
	# Return the world tilemap for pathfinding and AI systems
	return world_tilemap

func get_building_manager():
	# Return the building manager for construction tasks
	return building_manager

func _on_placement_mode_changed(is_active: bool) -> void:
	# Handle placement mode changes
	if is_active:
		print("Building placement mode activated")
	else:
		print("Building placement mode deactivated")

func _on_construction_needed(building) -> void:
	# Assign a colonist to construct this building
	if colonist_manager:
		colonist_manager.assign_construction_task(building)

func _on_right_click_requested(_screen_position: Vector2) -> void:
	# Get world position
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return

	var world_position = camera.get_global_mouse_position()

	# Don't handle right-click if in building placement mode
	if building_manager and building_manager.is_placing_building:
		return

	# Check if we're clicking on a resource and designate it for harvest
	if harvest_manager and world_tilemap:
		var tile_pos = world_tilemap.world_to_grid(world_position)
		var tile_data = world_tilemap.get_tile(tile_pos)

		if tile_data and tile_data.resource_type != 0:  # ResourceType.NONE = 0
			harvest_manager.designate_harvest(tile_pos)
