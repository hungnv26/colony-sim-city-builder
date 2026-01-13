## Task for colonist idle behavior - randomly wanders around
class_name IdleTask
extends Task

const MoveToTaskScript = preload("res://scripts/ai/tasks/move_to_task.gd")

## Time to wait between wanders (seconds)
@export var wander_interval: float = 5.0

## Maximum distance to wander from current position
@export var wander_radius: float = 100.0

## Time since last wander
var _time_since_wander: float = 0.0

## Current move task (if wandering)
var _move_task = null

## Reference to game world
var world = null

## Initialize idle task
func _init() -> void:
	super._init(Priority.IDLE)
	task_name = "Idle"

## Start the task
func start() -> void:
	super.start()
	_time_since_wander = 0.0
	_move_task = null

	if colonist == null:
		return

	# Get world reference by searching up the tree
	world = _find_game_world()

## Execute idle behavior
func execute(delta: float) -> bool:
	if colonist == null:
		return true

	# If currently executing a move task, continue it
	if _move_task != null:
		var move_complete = _move_task.execute(delta)
		if move_complete:
			_move_task = null
			_time_since_wander = 0.0
		return false

	# Wait for wander interval
	_time_since_wander += delta
	if _time_since_wander >= wander_interval:
		_start_wander()
		_time_since_wander = 0.0

	# Idle task never completes (it's the default behavior)
	return false

## Start a new wander movement
func _start_wander() -> void:
	if colonist == null or world == null:
		return

	# Generate random position within wander radius
	var random_offset = Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)

	var target_position = colonist.global_position + random_offset

	# Create and start move task
	_move_task = MoveToTaskScript.new(target_position, Priority.IDLE)
	_move_task.colonist = colonist
	_move_task.set_speed(50.0)  # Slower speed for idle wandering
	_move_task.start()

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

	# Can't idle if colonist is dead
	if colonist.current_state == colonist.State.DEAD:
		return false

	return true

## Get task description
func get_description() -> String:
	if _move_task != null:
		return "Wandering"
	return "Idle"

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
