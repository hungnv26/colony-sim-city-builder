## Data structure for building definitions
class_name BuildingData
extends RefCounted

## Building categories
enum Category {
	STORAGE,      # Storage buildings
	HOUSING,      # Living quarters
	PRODUCTION,   # Crafting/production buildings
	UTILITY,      # Functional buildings (power, water, etc)
	DEFENSE,      # Walls, turrets, etc
	DECORATION    # Non-functional decorative buildings
}

## Building properties
var building_id: String = ""
var display_name: String = ""
var description: String = ""
var category: Category = Category.STORAGE

## Placement properties
var width: int = 1  # Width in tiles
var height: int = 1  # Height in tiles
var can_rotate: bool = true
var blocks_movement: bool = true

## Construction requirements
var build_time: float = 10.0  # Seconds to construct
var required_resources: Dictionary = {}  # ResourceType -> amount

## Building stats
var max_health: float = 100.0
var storage_capacity: int = 0  # For storage buildings
var work_speed_bonus: float = 1.0  # For production buildings

## Visual
var sprite_path: String = ""
var color: Color = Color.WHITE

## State (used for building instances, not definitions)
var current_health: float = 100.0
var is_constructed: bool = false
var construction_progress: float = 0.0

## Initialize building data
func _init(id: String = "") -> void:
	building_id = id
	display_name = id.capitalize()
	current_health = max_health

## Check if terrain is suitable for this building
func is_terrain_suitable(terrain_type: int) -> bool:
	# By default, can't build on water
	const TileDataScript = preload("res://scripts/systems/tile_data.gd")
	if terrain_type == TileDataScript.TerrainType.WATER:
		return false
	return true

## Get resource cost as formatted string
func get_cost_string() -> String:
	if required_resources.is_empty():
		return "Free"

	var parts: Array = []
	for resource in required_resources:
		parts.append("%s: %d" % [resource, required_resources[resource]])

	return ", ".join(parts)

## Create a copy of this building data (for instances)
func duplicate_instance() -> BuildingData:
	var instance = BuildingData.new(building_id)
	instance.display_name = display_name
	instance.description = description
	instance.category = category
	instance.width = width
	instance.height = height
	instance.can_rotate = can_rotate
	instance.blocks_movement = blocks_movement
	instance.build_time = build_time
	instance.required_resources = required_resources.duplicate()
	instance.max_health = max_health
	instance.storage_capacity = storage_capacity
	instance.work_speed_bonus = work_speed_bonus
	instance.sprite_path = sprite_path
	instance.color = color
	instance.current_health = max_health
	instance.is_constructed = false
	instance.construction_progress = 0.0
	return instance
