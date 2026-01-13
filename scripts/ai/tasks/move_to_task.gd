## Task to move a colonist to a target position using pathfinding
class_name MoveToTask
extends Task

const PathfindingScript = preload("res://scripts/ai/pathfinding.gd")

## Target position to move to
var target_position: Vector2

## Path to follow (array of Vector2)
var path: Array = []

## Current path index
var _path_index: int = 0

## Movement speed
var _movement_speed: float = 100.0

## Distance threshold to consider waypoint reached
var _waypoint_threshold: float = 5.0

## Distance threshold to consider destination reached
var _destination_threshold: float = 10.0

## Reference to game world for pathfinding
var world = null

## Initialize the move task
func _init(target: Vector2, task_priority: Priority = Priority.NORMAL) -> void:
	super._init(task_priority)
	target_position = target
	task_name = "Move"

## Start the task by calculating path
func start() -> void:
	super.start()

	if colonist == null:
		return

	# Get world reference by searching up the tree
	world = _find_game_world()
	if world == null:
		is_completed = true
		return

	# Calculate path using A*
	path = PathfindingScript.find_path(colonist.global_position, target_position, world)

	# Simplify path to reduce waypoints
	if path.size() > 0:
		path = PathfindingScript.simplify_path(path)

	_path_index = 0

	# If no path found, complete immediately
	if path.size() == 0:
		is_completed = true

## Execute the movement along the path
func execute(delta: float) -> bool:
	if colonist == null or path.size() == 0:
		return true

	# Get current waypoint
	if _path_index >= path.size():
		return true

	var current_waypoint = path[_path_index]

	# Move towards waypoint
	var direction = (current_waypoint - colonist.global_position).normalized()
	colonist.velocity = direction * _movement_speed
	colonist.move_and_slide()

	# Check if waypoint reached
	var distance_to_waypoint = colonist.global_position.distance_to(current_waypoint)

	# Use tighter threshold for intermediate waypoints, looser for final destination
	var threshold = _waypoint_threshold if _path_index < path.size() - 1 else _destination_threshold

	if distance_to_waypoint < threshold:
		_path_index += 1

		# Check if reached final destination
		if _path_index >= path.size():
			colonist.velocity = Vector2.ZERO
			return true

	return false

## Check if task can be executed
func can_execute() -> bool:
	if not super.can_execute():
		return false

	# Can't move if colonist is dead
	if colonist.current_state == colonist.State.DEAD:
		return false

	return true

## Get task description
func get_description() -> String:
	return "Moving to destination"

## Set movement speed
func set_speed(speed: float) -> void:
	_movement_speed = speed

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
