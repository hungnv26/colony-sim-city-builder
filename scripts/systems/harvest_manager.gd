## Manages harvest job designations and assignments
class_name HarvestManager
extends Node

const HarvestResourceTaskScript = preload("res://scripts/ai/tasks/harvest_resource_task.gd")
const TileDataScript = preload("res://scripts/systems/tile_data.gd")
const HarvestIndicatorScript = preload("res://scripts/ui/harvest_indicator.gd")

## Designated harvest jobs (tile position -> resource type)
var designated_harvests: Dictionary = {}  # Vector2i -> int (ResourceType)

## Jobs currently being worked on
var active_jobs: Dictionary = {}  # Vector2i -> Colonist

## Visual indicators for designated harvests
var harvest_indicators: Dictionary = {}  # Vector2i -> HarvestIndicator

## Reference to colonist manager
var colonist_manager = null

## Reference to tilemap
var tilemap = null

## Layer for harvest indicators
var indicator_layer: Node2D = null

## Signals
signal harvest_designated(tile_pos: Vector2i, resource_type: int)
signal harvest_completed(tile_pos: Vector2i, resource_type: int)
signal harvest_cancelled(tile_pos: Vector2i)

## Initialize harvest manager
func initialize(c_manager, t_map, i_layer: Node2D = null) -> void:
	colonist_manager = c_manager
	tilemap = t_map
	indicator_layer = i_layer

	# Create indicator layer if not provided
	if indicator_layer == null:
		indicator_layer = Node2D.new()
		indicator_layer.name = "HarvestIndicators"
		add_child(indicator_layer)

	print("Harvest manager initialized")

## Designate a resource for harvesting
func designate_harvest(tile_pos: Vector2i) -> bool:
	if tilemap == null:
		return false

	# Check if tile has a resource
	var tile_data = tilemap.get_tile(tile_pos)
	if tile_data == null or tile_data.resource_type == TileDataScript.ResourceType.NONE:
		print("No resource at tile %v" % tile_pos)
		return false

	# Check if already designated
	if designated_harvests.has(tile_pos):
		print("Resource at %v already designated for harvest" % tile_pos)
		return false

	# Add to designated harvests
	designated_harvests[tile_pos] = tile_data.resource_type
	harvest_designated.emit(tile_pos, tile_data.resource_type)

	# Create visual indicator
	_create_harvest_indicator(tile_pos)

	# Try to assign to a colonist
	_try_assign_harvest_job(tile_pos, tile_data.resource_type)

	var resource_name = tile_data.get_resource_name()
	print("Designated %s at %v for harvest" % [resource_name, tile_pos])

	return true

## Cancel harvest designation
func cancel_harvest(tile_pos: Vector2i) -> void:
	if not designated_harvests.has(tile_pos):
		return

	designated_harvests.erase(tile_pos)
	active_jobs.erase(tile_pos)
	_remove_harvest_indicator(tile_pos)
	harvest_cancelled.emit(tile_pos)

	print("Cancelled harvest designation at %v" % tile_pos)

## Try to assign a harvest job to an available colonist
func _try_assign_harvest_job(tile_pos: Vector2i, resource_type: int) -> bool:
	if colonist_manager == null:
		return false

	# Don't assign if already being worked on
	if active_jobs.has(tile_pos):
		return false

	# Find available colonist
	var colonist = colonist_manager._find_available_colonist()
	if colonist == null:
		print("No available colonists for harvest job")
		return false

	# Create harvest task
	var task = HarvestResourceTaskScript.new(tile_pos, resource_type)

	# Assign to colonist
	colonist.task_queue.add_task(task)
	active_jobs[tile_pos] = colonist

	var resource_name = _get_resource_name(resource_type)
	print("Assigned harvest of %s at %v to %s" % [resource_name, tile_pos, colonist.colonist_name])

	return true

## Process harvest jobs (called periodically)
func _process(_delta: float) -> void:
	# Check for completed jobs
	_check_completed_jobs()

	# Try to assign unassigned jobs
	_assign_pending_jobs()

## Check for jobs that have been completed
func _check_completed_jobs() -> void:
	var completed_jobs: Array = []

	for tile_pos in active_jobs.keys():
		# Check if resource still exists
		if tilemap:
			var tile_data = tilemap.get_tile(tile_pos)
			if tile_data == null or tile_data.resource_type == TileDataScript.ResourceType.NONE:
				# Resource harvested or removed
				completed_jobs.append(tile_pos)

	# Remove completed jobs
	for tile_pos in completed_jobs:
		var resource_type = designated_harvests.get(tile_pos, TileDataScript.ResourceType.NONE)
		designated_harvests.erase(tile_pos)
		active_jobs.erase(tile_pos)
		_remove_harvest_indicator(tile_pos)
		harvest_completed.emit(tile_pos, resource_type)

## Assign pending harvest jobs to available colonists
func _assign_pending_jobs() -> void:
	for tile_pos in designated_harvests.keys():
		if not active_jobs.has(tile_pos):
			var resource_type = designated_harvests[tile_pos]
			_try_assign_harvest_job(tile_pos, resource_type)

## Get all designated harvest locations
func get_designated_harvests() -> Array:
	return designated_harvests.keys()

## Check if a tile is designated for harvest
func is_designated(tile_pos: Vector2i) -> bool:
	return designated_harvests.has(tile_pos)

## Create visual indicator for harvest designation
func _create_harvest_indicator(tile_pos: Vector2i) -> void:
	if indicator_layer == null or tilemap == null:
		return

	# Don't create if already exists
	if harvest_indicators.has(tile_pos):
		return

	# Create indicator
	var indicator = HarvestIndicatorScript.new()
	var world_pos = tilemap.grid_to_world(tile_pos)
	indicator.position = world_pos + Vector2(tilemap.TILE_SIZE / 2.0, tilemap.TILE_SIZE / 2.0)
	indicator_layer.add_child(indicator)
	harvest_indicators[tile_pos] = indicator

## Remove visual indicator
func _remove_harvest_indicator(tile_pos: Vector2i) -> void:
	if not harvest_indicators.has(tile_pos):
		return

	var indicator = harvest_indicators[tile_pos]
	if indicator:
		indicator.queue_free()
	harvest_indicators.erase(tile_pos)

## Get resource display name
func _get_resource_name(res_type: int) -> String:
	match res_type:
		TileDataScript.ResourceType.TREE: return "Tree"
		TileDataScript.ResourceType.ROCK: return "Rock"
		TileDataScript.ResourceType.ORE_IRON: return "Iron Ore"
		TileDataScript.ResourceType.ORE_GOLD: return "Gold Ore"
		_: return "Unknown"
