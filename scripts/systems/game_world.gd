extends Node2D

@onready var terrain_layer: Node2D = $WorldLayer/TerrainLayer
@onready var buildings_layer: Node2D = $WorldLayer/BuildingsLayer
@onready var units_layer: Node2D = $WorldLayer/UnitsLayer
@onready var effects_layer: Node2D = $WorldLayer/EffectsLayer

const TestWorldContent = preload("res://scripts/systems/test_world_content.gd")

func _ready() -> void:
	# Initialize the game world
	_setup_world()

func _setup_world() -> void:
	# Add temporary test content for Phase 1 visualization
	var test_content = TestWorldContent.new()
	terrain_layer.add_child(test_content)

	print("Game world initialized with test content")
