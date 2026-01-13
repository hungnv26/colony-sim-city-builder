## Task to find and consume food resources
class_name FindFoodTask
extends Task

const MoveToTaskScript = preload("res://scripts/ai/tasks/move_to_task.gd")
const TileDataScript = preload("res://scripts/systems/tile_data.gd")

## Stages of the food gathering process
enum Stage {
	SEARCHING,   # Looking for food
	MOVING,      # Moving to food location
	GATHERING,   # Gathering/eating the food
	COMPLETE     # Task finished
}

## Current stage
var _stage: Stage = Stage.SEARCHING

## Target food position
var _target_position: Vector2

## Target tile coordinate
var _target_tile: Vector2i

## Current move task
var _move_task = null

## Time spent gathering
var _gather_time: float = 0.0

## Time required to gather food (seconds)
const GATHER_DURATION: float = 2.0

## Amount of hunger restored
const HUNGER_RESTORED: float = 40.0

## Search radius for food (in tiles)
const SEARCH_RADIUS: int = 20

## Reference to game world
var world = null

## Initialize find food task
func _init() -> void:
	super._init(Priority.HIGH)
	task_name = "Find Food"

## Start the task
func start() -> void:
	super.start()
	_stage = Stage.SEARCHING

	if colonist == null:
		return

	# Get world reference by searching up the tree
	world = _find_game_world()

## Execute the task
func execute(delta: float) -> bool:
	if colonist == null:
		return true

	match _stage:
		Stage.SEARCHING:
			return _execute_searching()
		Stage.MOVING:
			return _execute_moving(delta)
		Stage.GATHERING:
			return _execute_gathering(delta)
		Stage.COMPLETE:
			return true

	return false

## Search for nearby food
func _execute_searching() -> bool:
	if world == null:
		return true

	var tilemap = world.get_tilemap()
	if tilemap == null:
		return true

	# Get colonist's current tile
	var colonist_tile = tilemap.local_to_map(colonist.global_position)

	# Search for food in radius
	var food_found = false
	var closest_distance = INF
	var closest_tile: Vector2i

	for x in range(-SEARCH_RADIUS, SEARCH_RADIUS + 1):
		for y in range(-SEARCH_RADIUS, SEARCH_RADIUS + 1):
			var check_tile = colonist_tile + Vector2i(x, y)
			var tile_data = tilemap.get_tile(check_tile)

			if tile_data != null and tile_data.resource_type == TileDataScript.ResourceType.TREE:
				# Found food source
				var distance = Vector2(x, y).length()
				if distance < closest_distance:
					closest_distance = distance
					closest_tile = check_tile
					food_found = true

	if not food_found:
		# No food found nearby
		return true

	# Found food, move to it
	_target_tile = closest_tile
	_target_position = tilemap.map_to_local(closest_tile)
	_stage = Stage.MOVING

	# Create move task
	_move_task = MoveToTaskScript.new(_target_position, Priority.HIGH)
	_move_task.colonist = colonist
	_move_task.start()

	return false

## Move to food location
func _execute_moving(delta: float) -> bool:
	if _move_task == null:
		return true

	var move_complete = _move_task.execute(delta)

	if move_complete:
		# Reached food location
		_move_task = null
		_stage = Stage.GATHERING
		_gather_time = 0.0

		# Change colonist state to WORKING
		if colonist.current_state != colonist.State.WORKING:
			colonist.change_state(colonist.State.WORKING)

	return false

## Gather and consume the food
func _execute_gathering(delta: float) -> bool:
	_gather_time += delta

	if _gather_time >= GATHER_DURATION:
		# Gathering complete - restore hunger
		colonist.hunger = min(colonist.hunger + HUNGER_RESTORED, 100.0)

		# Remove resource from tile
		if world != null:
			var tilemap = world.get_tilemap()
			if tilemap != null:
				var tile_data = tilemap.get_tile(_target_tile)
				if tile_data != null:
					tile_data.resource_type = TileDataScript.ResourceType.NONE
					tile_data.resource_amount = 0
					tilemap.update_tile(_target_tile)

		_stage = Stage.COMPLETE
		return true

	return false

## Cancel the task
func cancel() -> void:
	super.cancel()
	if _move_task != null:
		_move_task.cancel()
		_move_task = null

## Check if task can be executed
func can_execute() -> bool:
	if not super.can_execute():
		return false

	# Only execute if colonist is hungry
	if colonist.hunger > 70.0:
		return false

	# Can't eat if dead
	if colonist.current_state == colonist.State.DEAD:
		return false

	return true

## Get task description
func get_description() -> String:
	match _stage:
		Stage.SEARCHING:
			return "Searching for food"
		Stage.MOVING:
			return "Moving to food"
		Stage.GATHERING:
			return "Gathering food"
		Stage.COMPLETE:
			return "Eating"
	return "Find Food"

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
