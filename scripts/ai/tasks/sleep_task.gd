## Task for colonist to rest and recover energy
class_name SleepTask
extends Task

const MoveToTaskScript = preload("res://scripts/ai/tasks/move_to_task.gd")

## Stages of sleeping
enum Stage {
	MOVING_TO_BED,   # Moving to rest location
	SLEEPING,        # Actually sleeping
	COMPLETE         # Task finished
}

## Current stage
var _stage: Stage = Stage.MOVING_TO_BED

## Target rest position (for now, just a nearby spot)
var _rest_position: Vector2

## Current move task
var _move_task = null

## Time spent sleeping
var _sleep_time: float = 0.0

## Energy threshold to wake up
const ENERGY_THRESHOLD: float = 95.0

## Minimum sleep duration (seconds)
const MIN_SLEEP_DURATION: float = 3.0

## Distance to search for rest spot
const REST_SEARCH_RADIUS: float = 50.0

## Reference to game world
var world = null

## Initialize sleep task
func _init() -> void:
	super._init(Priority.CRITICAL)
	task_name = "Sleep"

## Start the task
func start() -> void:
	super.start()
	_stage = Stage.MOVING_TO_BED

	if colonist == null:
		return

	# Get world reference by searching up the tree
	world = _find_game_world()

	# For now, just find a nearby spot to rest
	# TODO: In future, find actual bed/shelter
	_find_rest_spot()

## Execute the task
func execute(delta: float) -> bool:
	if colonist == null:
		return true

	match _stage:
		Stage.MOVING_TO_BED:
			return _execute_moving(delta)
		Stage.SLEEPING:
			return _execute_sleeping(delta)
		Stage.COMPLETE:
			return true

	return false

## Find a suitable rest spot
func _find_rest_spot() -> void:
	if colonist == null:
		return

	# For now, just pick a random nearby position
	# TODO: In future, find nearest bed or shelter
	var random_offset = Vector2(
		randf_range(-REST_SEARCH_RADIUS, REST_SEARCH_RADIUS),
		randf_range(-REST_SEARCH_RADIUS, REST_SEARCH_RADIUS)
	)

	_rest_position = colonist.global_position + random_offset

	# Create move task to rest spot
	_move_task = MoveToTaskScript.new(_rest_position, Priority.CRITICAL)
	_move_task.colonist = colonist
	_move_task.start()

## Move to rest location
func _execute_moving(delta: float) -> bool:
	if _move_task == null:
		# Skip moving if no move task
		_stage = Stage.SLEEPING
		_sleep_time = 0.0
		return false

	var move_complete = _move_task.execute(delta)

	if move_complete:
		# Reached rest location
		_move_task = null
		_stage = Stage.SLEEPING
		_sleep_time = 0.0

		# Change colonist state to SLEEPING
		if colonist.current_state != colonist.State.SLEEPING:
			colonist.change_state(colonist.State.SLEEPING)

	return false

## Sleep and recover energy
func _execute_sleeping(delta: float) -> bool:
	_sleep_time += delta

	# Recover energy while sleeping
	# Energy recovery rate is set in colonist.gd, but we ensure state is SLEEPING
	# The colonist's _process will handle the actual recovery

	# Check if well-rested or slept minimum duration
	if _sleep_time >= MIN_SLEEP_DURATION and colonist.energy >= ENERGY_THRESHOLD:
		_stage = Stage.COMPLETE
		return true

	return false

## Complete the task
func complete() -> void:
	super.complete()

	# Change state back to IDLE
	if colonist != null and colonist.current_state == colonist.State.SLEEPING:
		colonist.change_state(colonist.State.IDLE)

## Cancel the task
func cancel() -> void:
	super.cancel()

	if _move_task != null:
		_move_task.cancel()
		_move_task = null

	# Wake up colonist if sleeping
	if colonist != null and colonist.current_state == colonist.State.SLEEPING:
		colonist.change_state(colonist.State.IDLE)

## Check if task can be executed
func can_execute() -> bool:
	if not super.can_execute():
		return false

	# Only sleep if colonist is tired
	if colonist.energy > 30.0:
		return false

	# Can't sleep if dead
	if colonist.current_state == colonist.State.DEAD:
		return false

	return true

## Get task description
func get_description() -> String:
	match _stage:
		Stage.MOVING_TO_BED:
			return "Finding rest spot"
		Stage.SLEEPING:
			return "Sleeping"
		Stage.COMPLETE:
			return "Waking up"
	return "Sleep"

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
