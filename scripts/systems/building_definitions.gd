## Registry of all building definitions
class_name BuildingDefinitions
extends RefCounted

const BuildingDataScript = preload("res://scripts/systems/building_data.gd")

## All registered building definitions
static var _definitions: Dictionary = {}

## Register all building definitions
static func initialize() -> void:
	if not _definitions.is_empty():
		return  # Already initialized

	# Storage Buildings
	_register_storage_shed()
	_register_warehouse()

	# Housing Buildings
	_register_sleeping_quarters()
	_register_house()

	# Production Buildings
	_register_workbench()
	_register_kitchen()

	# Utility Buildings
	_register_campfire()

	# Defense Buildings
	_register_wall()

	print("Building definitions initialized: %d buildings registered" % _definitions.size())

## Register: Storage Shed (small storage)
static func _register_storage_shed() -> void:
	var building = BuildingDataScript.new("storage_shed")
	building.display_name = "Storage Shed"
	building.description = "Small storage building for resources"
	building.category = BuildingDataScript.Category.STORAGE
	building.width = 2
	building.height = 2
	building.build_time = 5.0
	building.required_resources = {"wood": 20, "stone": 10}
	building.storage_capacity = 500
	building.sprite_path = "res://assets/sprites/buildings/storage.svg"
	building.color = Color(0.6, 0.4, 0.2)  # Brown
	_definitions["storage_shed"] = building

## Register: Warehouse (large storage)
static func _register_warehouse() -> void:
	var building = BuildingDataScript.new("warehouse")
	building.display_name = "Warehouse"
	building.description = "Large storage building for bulk resources"
	building.category = BuildingDataScript.Category.STORAGE
	building.width = 4
	building.height = 4
	building.build_time = 20.0
	building.required_resources = {"wood": 50, "stone": 30}
	building.storage_capacity = 2000
	building.max_health = 200.0
	building.sprite_path = "res://assets/sprites/buildings/storage.svg"
	building.color = Color(0.5, 0.3, 0.15)  # Dark brown
	_definitions["warehouse"] = building

## Register: Sleeping Quarters (colonist beds)
static func _register_sleeping_quarters() -> void:
	var building = BuildingDataScript.new("sleeping_quarters")
	building.display_name = "Sleeping Quarters"
	building.description = "Provides beds for colonists to rest"
	building.category = BuildingDataScript.Category.HOUSING
	building.width = 3
	building.height = 2
	building.build_time = 8.0
	building.required_resources = {"wood": 30}
	building.sprite_path = "res://assets/sprites/buildings/sleeping_quarters.svg"
	building.color = Color(0.8, 0.7, 0.5)  # Beige
	_definitions["sleeping_quarters"] = building

## Register: House (better housing)
static func _register_house() -> void:
	var building = BuildingDataScript.new("house")
	building.display_name = "House"
	building.description = "Comfortable housing for colonists"
	building.category = BuildingDataScript.Category.HOUSING
	building.width = 3
	building.height = 3
	building.build_time = 15.0
	building.required_resources = {"wood": 40, "stone": 20}
	building.max_health = 150.0
	building.sprite_path = "res://assets/sprites/buildings/house.svg"
	building.color = Color(0.7, 0.6, 0.4)  # Tan
	_definitions["house"] = building

## Register: Workbench (crafting station)
static func _register_workbench() -> void:
	var building = BuildingDataScript.new("workbench")
	building.display_name = "Workbench"
	building.description = "Basic crafting station for tools and items"
	building.category = BuildingDataScript.Category.PRODUCTION
	building.width = 2
	building.height = 1
	building.build_time = 5.0
	building.required_resources = {"wood": 15}
	building.work_speed_bonus = 1.2
	building.sprite_path = "res://assets/sprites/buildings/workbench.svg"
	building.color = Color(0.6, 0.5, 0.3)  # Wood color
	_definitions["workbench"] = building

## Register: Kitchen (food preparation)
static func _register_kitchen() -> void:
	var building = BuildingDataScript.new("kitchen")
	building.display_name = "Kitchen"
	building.description = "Prepare meals and process food"
	building.category = BuildingDataScript.Category.PRODUCTION
	building.width = 3
	building.height = 2
	building.build_time = 12.0
	building.required_resources = {"wood": 25, "stone": 15}
	building.work_speed_bonus = 1.5
	building.sprite_path = "res://assets/sprites/buildings/workbench.svg"
	building.color = Color(0.9, 0.5, 0.2)  # Orange
	_definitions["kitchen"] = building

## Register: Campfire (basic utility)
static func _register_campfire() -> void:
	var building = BuildingDataScript.new("campfire")
	building.display_name = "Campfire"
	building.description = "Provides light and warmth"
	building.category = BuildingDataScript.Category.UTILITY
	building.width = 1
	building.height = 1
	building.build_time = 2.0
	building.required_resources = {"wood": 5}
	building.max_health = 50.0
	building.blocks_movement = false
	building.sprite_path = "res://assets/sprites/buildings/workbench.svg"
	building.color = Color(1.0, 0.5, 0.0)  # Orange/fire
	_definitions["campfire"] = building

## Register: Wall (defense)
static func _register_wall() -> void:
	var building = BuildingDataScript.new("wall")
	building.display_name = "Wall"
	building.description = "Defensive wall to protect your colony"
	building.category = BuildingDataScript.Category.DEFENSE
	building.width = 1
	building.height = 1
	building.build_time = 3.0
	building.required_resources = {"stone": 10}
	building.max_health = 200.0
	building.can_rotate = false
	building.sprite_path = "res://assets/sprites/buildings/wall.svg"
	building.color = Color(0.5, 0.5, 0.5)  # Gray
	_definitions["wall"] = building

## Get a building definition by ID
static func get_definition(building_id: String) -> BuildingDataScript:
	if _definitions.is_empty():
		initialize()

	if _definitions.has(building_id):
		return _definitions[building_id]

	push_error("Building definition not found: %s" % building_id)
	return null

## Get all building definitions
static func get_all_definitions() -> Array:
	if _definitions.is_empty():
		initialize()

	return _definitions.values()

## Get buildings by category
static func get_by_category(category: int) -> Array:
	if _definitions.is_empty():
		initialize()

	var result: Array = []
	for building in _definitions.values():
		if building.category == category:
			result.append(building)

	return result

## Create a new building instance from definition
static func create_instance(building_id: String) -> BuildingDataScript:
	var definition = get_definition(building_id)
	if definition == null:
		return null

	return definition.duplicate_instance()
