## Base class for all colonist tasks
## Tasks are queued and executed by colonists based on priority
class_name Task
extends RefCounted

## Task priority levels (higher = more urgent)
enum Priority {
	IDLE = 0,        # Default idle behavior
	LOW = 1,         # Non-urgent tasks
	NORMAL = 2,      # Regular tasks
	HIGH = 3,        # Important tasks
	CRITICAL = 4     # Life-threatening needs
}

## Current priority of this task
var priority: Priority = Priority.NORMAL

## Whether this task has been started
var is_started: bool = false

## Whether this task has been completed
var is_completed: bool = false

## Whether this task was cancelled
var is_cancelled: bool = false

## The colonist executing this task
var colonist = null  # Will be set to Colonist instance

## Task name for debugging
var task_name: String = "BaseTask"

## Initialize the task
func _init(task_priority: Priority = Priority.NORMAL) -> void:
	priority = task_priority

## Called when the task starts
## Override this in derived classes
func start() -> void:
	is_started = true

## Called every frame while task is active
## Override this in derived classes
## Return true when task is complete
func execute(delta: float) -> bool:
	return true

## Called when the task is interrupted or cancelled
## Override this in derived classes for cleanup
func cancel() -> void:
	is_cancelled = true
	is_completed = false

## Called when a higher-priority task takes over
## The task is cancelled now and restarted from scratch when it is picked again
func interrupt() -> void:
	cancel()
	is_started = false
	is_cancelled = false

## Called when the task completes successfully
## Override this in derived classes for cleanup
func complete() -> void:
	is_completed = true

## Check if this task can be executed by the colonist
## Override this in derived classes to add conditions
func can_execute() -> bool:
	return colonist != null

## Get a description of this task for UI display
func get_description() -> String:
	return task_name
