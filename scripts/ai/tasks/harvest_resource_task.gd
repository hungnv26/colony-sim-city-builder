## Task to harvest resources from resource nodes (trees, rocks, ore)
class_name HarvestResourceTask
extends Task

const MoveToTaskScript = preload("res://scripts/ai/tasks/move_to_task.gd")
const TileDataScript = preload("res://scripts/systems/tile_data.gd")

## Stages of harvesting
enum Stage {
	MOVING_TO_RESOURCE,  # Moving to resource location
	HARVESTING,          # Actually harvesting
	COMPLETE             # Task finished
}

## Current stage
var _stage: Stage = Stage.MOVING_TO_RESOURCE

## Target tile position with resource
var target_tile_pos: Vector2i = Vector2i.ZERO

## Resource type being harvested
var resource_type: int = TileDataScript.ResourceType.NONE

## Current move task
var _move_task = null

## Time spent harvesting
var _harvest_time: float = 0.0

## Harvest speed (seconds to harvest one resource)
const HARVEST_SPEED: Dictionary = {
	TileDataScript.ResourceType.TREE: 3.0,      # 3 seconds per tree
	TileDataScript.ResourceType.ROCK: 5.0,      # 5 seconds per rock
	TileDataScript.ResourceType.ORE_IRON: 8.0,  # 8 seconds per iron ore
	TileDataScript.ResourceType.ORE_GOLD: 10.0  # 10 seconds per gold ore
}

## Resource yield amounts
const HARVEST_YIELD: Dictionary = {
	TileDataScript.ResourceType.TREE: {"wood": 20},
	TileDataScript.ResourceType.ROCK: {"stone": 15},
	TileDataScript.ResourceType.ORE_IRON: {"metal": 10},
	TileDataScript.ResourceType.ORE_GOLD: {"gold": 5}
}

## Reference to game world
var world = null

## Initialize harvest task
func _init(tile_pos: Vector2i, res_type: int) -> void:
	super._init(Priority.NORMAL)
	target_tile_pos = tile_pos
	resource_type = res_type
	task_name = "Harvest Resource"

## Start the task
func start() -> void:
	super.start()
	_stage = Stage.MOVING_TO_RESOURCE

	if colonist == null:
		return

	# Get world reference
	world = _find_game_world()

	# Move to resource location
	_start_movement()

## Execute the task
func execute(delta: float) -> bool:
	if colonist == null:
		return true

	match _stage:
		Stage.MOVING_TO_RESOURCE:
			return _execute_moving(delta)
		Stage.HARVESTING:
			return _execute_harvesting(delta)
		Stage.COMPLETE:
			return true

	return false

## Start movement to resource
func _start_movement() -> void:
	if world == null:
		return

	var tilemap = world.get_tilemap()
	if tilemap == null:
		return

	# Move to adjacent tile of resource (resources are not walkable)
	var target_world_pos = tilemap.grid_to_world(target_tile_pos)
	target_world_pos += Vector2(tilemap.TILE_SIZE / 2.0, tilemap.TILE_SIZE / 2.0)

	_move_task = MoveToTaskScript.new(target_world_pos, Priority.NORMAL)
	_move_task.colonist = colonist
	_move_task.start()

## Move to resource
func _execute_moving(delta: float) -> bool:
	if _move_task == null:
		return true

	var move_complete = _move_task.execute(delta)

	if move_complete:
		# Reached resource location
		_move_task = null
		_stage = Stage.HARVESTING
		_harvest_time = 0.0

		# Change colonist state to WORKING
		if colonist.current_state != colonist.State.WORKING:
			colonist.change_state(colonist.State.WORKING)

		var resource_name = _get_resource_name(resource_type)
		print("%s started harvesting %s at %v" % [colonist.colonist_name, resource_name, target_tile_pos])

	return false

## Harvest the resource
func _execute_harvesting(delta: float) -> bool:
	_harvest_time += delta

	# Check if resource still exists
	if world == null:
		return true

	var tilemap = world.get_tilemap()
	if tilemap == null:
		return true

	var tile_data = tilemap.get_tile(target_tile_pos)
	if tile_data == null or tile_data.resource_type == TileDataScript.ResourceType.NONE:
		print("Resource no longer exists at %v" % target_tile_pos)
		return true

	# Check if harvest complete
	var harvest_duration = HARVEST_SPEED.get(resource_type, 5.0)
	if _harvest_time >= harvest_duration:
		# Harvest complete - collect resources
		_collect_resources(tile_data)
		_stage = Stage.COMPLETE
		return true

	return false

## Collect resources from tile
func _collect_resources(tile_data) -> void:
	if tile_data == null:
		return

	# Remove resource from tile
	tile_data.harvest_resource(tile_data.resource_amount)

	# Update tilemap visuals
	if world:
		var tilemap = world.get_tilemap()
		if tilemap:
			tilemap.update_tile(target_tile_pos)

	# Add resources to player inventory
	var yield_data = HARVEST_YIELD.get(resource_type, {})
	for resource_name in yield_data:
		var amount = yield_data[resource_name]
		ResourceManager.add_resource(resource_name, amount)

	var resource_name = _get_resource_name(resource_type)
	print("%s harvested %s" % [colonist.colonist_name, resource_name])

## Complete the task
func complete() -> void:
	super.complete()

	# Change state back to IDLE
	if colonist != null and colonist.current_state == colonist.State.WORKING:
		colonist.change_state(colonist.State.IDLE)

## Cancel the task
func cancel() -> void:
	super.cancel()

	if _move_task != null:
		_move_task.cancel()
		_move_task = null

	# Change state back to IDLE
	if colonist != null and colonist.current_state == colonist.State.WORKING:
		colonist.change_state(colonist.State.IDLE)

## Check if task can be executed
func can_execute() -> bool:
	if not super.can_execute():
		return false

	# Can't harvest if colonist is dead
	if colonist.current_state == colonist.State.DEAD:
		return false

	# Verify resource still exists
	if world:
		var tilemap = world.get_tilemap()
		if tilemap:
			var tile_data = tilemap.get_tile(target_tile_pos)
			if tile_data == null or tile_data.resource_type == TileDataScript.ResourceType.NONE:
				return false

	return true

## Get task description
func get_description() -> String:
	var resource_name = _get_resource_name(resource_type)

	match _stage:
		Stage.MOVING_TO_RESOURCE:
			return "Moving to %s" % resource_name
		Stage.HARVESTING:
			var progress = (_harvest_time / HARVEST_SPEED.get(resource_type, 5.0)) * 100.0
			return "Harvesting %s (%.0f%%)" % [resource_name, progress]
		Stage.COMPLETE:
			return "Harvest complete"

	return "Harvest %s" % resource_name

## Get resource display name
func _get_resource_name(res_type: int) -> String:
	match res_type:
		TileDataScript.ResourceType.TREE: return "Tree"
		TileDataScript.ResourceType.ROCK: return "Rock"
		TileDataScript.ResourceType.ORE_IRON: return "Iron Ore"
		TileDataScript.ResourceType.ORE_GOLD: return "Gold Ore"
		_: return "Unknown"

## Find the game world node by searching up the tree
func _find_game_world():
	if colonist == null:
		return null

	var node = colonist.get_parent()
	while node != null:
		if node.has_method("get_tilemap"):
			return node
		node = node.get_parent()

	return null
