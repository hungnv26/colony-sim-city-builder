## Manages all buildings in the game world
class_name BuildingManager
extends Node

const BuildingScript = preload("res://scripts/entities/building.gd")
const BuildingDefinitionsScript = preload("res://scripts/systems/building_definitions.gd")
const BuildingDataScript = preload("res://scripts/systems/building_data.gd")

# Type alias for Building class
const Building = BuildingScript

## All placed buildings
var buildings: Array = []  # Array of Building nodes

## Building layer (parent node for building instances)
var building_layer: Node2D = null

## Currently selected building for placement (preview mode)
var placement_preview: Building = null
var is_placing_building: bool = false
var current_placement_id: String = ""

## Signals
signal building_placed(building: Building)
signal building_removed(building: Building)
signal placement_mode_changed(is_active: bool)
signal construction_needed(building: Building)

func _ready() -> void:
	# Initialize building definitions
	BuildingDefinitionsScript.initialize()

## Initialize the building manager
func initialize(layer: Node2D) -> void:
	building_layer = layer
	print("Building manager initialized")

## Start placement mode for a building type
func start_placement_mode(building_id: String) -> void:
	if is_placing_building:
		cancel_placement_mode()

	var definition = BuildingDefinitionsScript.get_definition(building_id)
	if definition == null:
		push_error("Cannot start placement: building definition not found: %s" % building_id)
		return

	current_placement_id = building_id
	is_placing_building = true

	# Create preview building
	placement_preview = BuildingScript.new()
	var preview_data = definition.duplicate_instance()
	placement_preview.initialize(preview_data, Vector2i.ZERO)
	placement_preview.modulate = Color(1, 1, 1, 0.5)  # Semi-transparent
	building_layer.add_child(placement_preview)

	placement_mode_changed.emit(true)
	print("Started placement mode for: %s" % definition.display_name)

## Update placement preview position
func update_placement_preview(world_position: Vector2, tilemap) -> void:
	if not is_placing_building or placement_preview == null:
		return

	# Convert world position to grid position
	var grid_pos = tilemap.world_to_grid(world_position)

	# Update preview position
	placement_preview.grid_position = grid_pos
	const TILE_SIZE = 32
	placement_preview.global_position = Vector2(
		grid_pos.x * TILE_SIZE + (placement_preview.building_data.width * TILE_SIZE) / 2.0,
		grid_pos.y * TILE_SIZE + (placement_preview.building_data.height * TILE_SIZE) / 2.0
	)

	# Check if placement is valid
	var is_valid = can_place_building(placement_preview.building_data, grid_pos, tilemap)
	placement_preview.modulate = Color(0, 1, 0, 0.5) if is_valid else Color(1, 0, 0, 0.5)

## Confirm building placement
func confirm_placement(tilemap) -> bool:
	if not is_placing_building or placement_preview == null:
		return false

	var grid_pos = placement_preview.grid_position
	var building_data = placement_preview.building_data

	# Validate placement
	if not can_place_building(building_data, grid_pos, tilemap):
		print("Cannot place building: invalid location")
		return false

	# Check and consume resources
	if not _check_and_consume_resources(building_data):
		print("Cannot place building: insufficient resources")
		return false

	# Create actual building instance
	var building = BuildingScript.new()
	var instance_data = BuildingDefinitionsScript.create_instance(current_placement_id)
	building.initialize(instance_data, grid_pos)
	building_layer.add_child(building)
	buildings.append(building)

	# Connect signals
	building.building_destroyed.connect(_on_building_destroyed.bind(building))

	building_placed.emit(building)
	print("Placed building '%s' at %v" % [instance_data.display_name, grid_pos])

	# Signal that this building needs construction
	construction_needed.emit(building)

	# Clean up placement mode
	cancel_placement_mode()
	return true

## Cancel placement mode
func cancel_placement_mode() -> void:
	if placement_preview:
		placement_preview.queue_free()
		placement_preview = null

	is_placing_building = false
	current_placement_id = ""
	placement_mode_changed.emit(false)

## Check if a building can be placed at position
func can_place_building(building_data: BuildingDataScript, grid_pos: Vector2i, tilemap) -> bool:
	if building_data == null or tilemap == null:
		return false

	# Check all tiles the building would occupy
	for x in range(building_data.width):
		for y in range(building_data.height):
			var check_pos = grid_pos + Vector2i(x, y)

			# Check if tile exists
			var tile_data = tilemap.get_tile(check_pos)
			if tile_data == null:
				return false

			# Check terrain suitability
			if not building_data.is_terrain_suitable(tile_data.terrain_type):
				return false

			# Check for existing buildings
			if is_tile_occupied(check_pos):
				return false

	return true

## Check if a tile is occupied by a building
func is_tile_occupied(grid_pos: Vector2i) -> bool:
	for building in buildings:
		if building == null:
			continue

		var occupied = building.get_occupied_tiles()
		if grid_pos in occupied:
			return true

	return false

## Get building at grid position
func get_building_at(grid_pos: Vector2i) -> Building:
	for building in buildings:
		if building == null:
			continue

		var occupied = building.get_occupied_tiles()
		if grid_pos in occupied:
			return building

	return null

## Handle building destroyed
func _on_building_destroyed(building: Building) -> void:
	buildings.erase(building)
	building_removed.emit(building)

## Get all buildings
func get_all_buildings() -> Array:
	return buildings.duplicate()

## Get buildings by category
func get_buildings_by_category(category: int) -> Array:
	var result: Array = []
	for building in buildings:
		if building != null and building.building_data != null:
			if building.building_data.category == category:
				result.append(building)
	return result

## Check if player has resources and consume them
func _check_and_consume_resources(building_data: BuildingDataScript) -> bool:
	# Check if we have all required resources
	for resource in building_data.required_resources:
		var amount = building_data.required_resources[resource]
		if not ResourceManager.has_resource(resource, amount):
			return false

	# Consume resources
	for resource in building_data.required_resources:
		var amount = building_data.required_resources[resource]
		ResourceManager.remove_resource(resource, amount)

	return true
