## Task to construct a building
class_name ConstructBuildingTask
extends Task

const MoveToTaskScript = preload("res://scripts/ai/tasks/move_to_task.gd")

## Stages of construction
enum Stage {
	MOVING_TO_SITE,  # Moving to construction site
	CONSTRUCTING,    # Actually building
	COMPLETE         # Task finished
}

## Current stage
var _stage: Stage = Stage.MOVING_TO_SITE

## Target building to construct
var target_building = null  # Building instance

## Current move task
var _move_task = null

## Time spent constructing
var _construction_time: float = 0.0

## Construction speed (progress per second)
const CONSTRUCTION_SPEED: float = 0.1  # 10% per second = 10 seconds for simple building

## Reference to game world
var world = null

## Initialize construction task
func _init(building) -> void:
	super._init(Priority.NORMAL)
	target_building = building
	task_name = "Construct Building"

## Start the task
func start() -> void:
	super.start()
	_stage = Stage.MOVING_TO_SITE

	if colonist == null or target_building == null:
		return

	# Get world reference
	world = _find_game_world()

	# Move to building site
	_start_movement()

## Execute the task
func execute(delta: float) -> bool:
	if colonist == null or target_building == null:
		return true

	# Check if building was destroyed
	if not is_instance_valid(target_building):
		return true

	match _stage:
		Stage.MOVING_TO_SITE:
			return _execute_moving(delta)
		Stage.CONSTRUCTING:
			return _execute_constructing(delta)
		Stage.COMPLETE:
			return true

	return false

## Start movement to construction site
func _start_movement() -> void:
	if target_building == null:
		return

	# Move to building position
	var target_pos = target_building.global_position

	_move_task = MoveToTaskScript.new(target_pos, Priority.NORMAL)
	_move_task.colonist = colonist
	_move_task.start()

## Move to construction site
func _execute_moving(delta: float) -> bool:
	if _move_task == null:
		return true

	var move_complete = _move_task.execute(delta)

	if move_complete:
		# Reached construction site
		_move_task = null
		_stage = Stage.CONSTRUCTING
		_construction_time = 0.0

		# Change colonist state to WORKING
		if colonist.current_state != colonist.State.WORKING:
			colonist.change_state(colonist.State.WORKING)

		print("%s started construction on %s" % [colonist.colonist_name, target_building.building_data.display_name])

	return false

## Construct the building
func _execute_constructing(delta: float) -> bool:
	_construction_time += delta

	if target_building == null or not is_instance_valid(target_building):
		return true

	# Calculate construction progress based on building's build time
	var progress_delta = delta / target_building.building_data.build_time
	var new_progress = target_building.building_data.construction_progress + progress_delta

	# Update building construction progress
	target_building.update_construction_progress(new_progress)

	# Check if construction complete
	if target_building.building_data.construction_progress >= 1.0:
		_stage = Stage.COMPLETE
		print("%s completed construction of %s" % [colonist.colonist_name, target_building.building_data.display_name])
		return true

	return false

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

	# Can't construct if colonist is dead
	if colonist.current_state == colonist.State.DEAD:
		return false

	# Can't construct if building doesn't exist
	if target_building == null or not is_instance_valid(target_building):
		return false

	# Can't construct if building is already constructed
	if target_building.building_data.is_constructed:
		return false

	return true

## Get task description
func get_description() -> String:
	match _stage:
		Stage.MOVING_TO_SITE:
			return "Moving to construction site"
		Stage.CONSTRUCTING:
			if target_building != null:
				var percent = target_building.building_data.construction_progress * 100.0
				return "Building %s (%.0f%%)" % [target_building.building_data.display_name, percent]
			return "Constructing"
		Stage.COMPLETE:
			return "Construction complete"
	return "Construct Building"

## Find the game world node by searching up the tree
func _find_game_world():
	if colonist == null:
		return null

	var node = colonist.get_parent()
	while node != null:
		if node.has_method("get_building_manager"):
			return node
		node = node.get_parent()

	return null
