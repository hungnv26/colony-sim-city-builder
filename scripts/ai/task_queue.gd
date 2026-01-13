## Manages a prioritized queue of tasks for a colonist
class_name TaskQueue
extends RefCounted

## The colonist that owns this queue
var colonist = null  # Will be set to Colonist instance

## Array of queued tasks, sorted by priority
var _tasks: Array = []

## Currently executing task
var _current_task = null  # Task instance

## Initialize the task queue
func _init(owner_colonist) -> void:
	colonist = owner_colonist

## Add a task to the queue
func add_task(task) -> void:
	if task == null:
		return

	task.colonist = colonist
	_tasks.append(task)
	_sort_tasks()

## Remove a specific task from the queue
func remove_task(task) -> void:
	var index = _tasks.find(task)
	if index != -1:
		_tasks.remove_at(index)

## Clear all tasks from the queue
func clear_all_tasks() -> void:
	if _current_task != null:
		_current_task.cancel()
		_current_task = null
	_tasks.clear()

## Get the current task being executed
func get_current_task():
	return _current_task

## Check if the queue has any tasks
func has_tasks() -> bool:
	return _tasks.size() > 0 or _current_task != null

## Process the task queue (call this every frame)
func process(delta: float) -> void:
	# If no current task, get the next one
	if _current_task == null:
		_get_next_task()

	# Execute current task
	if _current_task != null:
		# Check if task can still be executed
		if not _current_task.can_execute():
			_current_task.cancel()
			_current_task = null
			return

		# Start task if not started
		if not _current_task.is_started:
			_current_task.start()

		# Execute task
		var task_complete = _current_task.execute(delta)

		# Handle task completion
		if task_complete:
			_current_task.complete()
			_current_task = null

## Get the next task from the queue
func _get_next_task() -> void:
	if _tasks.is_empty():
		_current_task = null
		return

	# Get highest priority task that can be executed
	for i in range(_tasks.size()):
		var task = _tasks[i]
		if task.can_execute():
			_current_task = task
			_tasks.remove_at(i)
			return

	# No executable tasks found
	_current_task = null

## Sort tasks by priority (highest first)
func _sort_tasks() -> void:
	_tasks.sort_custom(_compare_priority)

## Custom comparison function for sorting by priority
func _compare_priority(a, b) -> bool:
	return a.priority > b.priority

## Get a count of tasks in the queue
func get_task_count() -> int:
	var count = _tasks.size()
	if _current_task != null:
		count += 1
	return count

## Get description of current task for UI
func get_current_task_description() -> String:
	if _current_task != null:
		return _current_task.get_description()
	return "No task"
