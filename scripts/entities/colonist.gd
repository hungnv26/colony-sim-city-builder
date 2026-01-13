extends CharacterBody2D

class_name Colonist

const TaskQueueScript = preload("res://scripts/ai/task_queue.gd")
const IdleTaskScript = preload("res://scripts/ai/tasks/idle_task.gd")
const FindFoodTaskScript = preload("res://scripts/ai/tasks/find_food_task.gd")
const SleepTaskScript = preload("res://scripts/ai/tasks/sleep_task.gd")

# Colonist stats
@export var colonist_name: String = "Colonist"
@export var max_health: float = 100.0
@export var max_hunger: float = 100.0
@export var max_energy: float = 100.0
@export var max_mood: float = 100.0

# Current stats
var health: float = 100.0
var hunger: float = 50.0  # 0 = starving, 100 = full
var energy: float = 100.0  # 0 = exhausted, 100 = rested
var mood: float = 75.0  # 0 = depressed, 100 = happy

# Stat decay rates (per second)
@export var hunger_decay_rate: float = 0.5  # Hunger decreases 0.5/sec
@export var energy_decay_rate: float = 0.3  # Energy decreases 0.3/sec when active
@export var energy_recovery_rate: float = 2.0  # Energy recovers 2.0/sec when sleeping

# Movement
@export var move_speed: float = 100.0
var current_path: PackedVector2Array = []
var path_index: int = 0

# AI Task system
var task_queue = null  # TaskQueue instance
var _idle_task = null  # Default idle task

# Thresholds for autonomous behavior
const HUNGER_THRESHOLD: float = 60.0  # Start looking for food below this
const ENERGY_THRESHOLD: float = 30.0  # Start looking to sleep below this

# State
enum State {
	IDLE,
	WALKING,
	WORKING,
	SLEEPING,
	EATING,
	DEAD
}
var current_state: State = State.IDLE
var is_selected: bool = false

# Visuals
@onready var sprite: Sprite2D = $Sprite2D
@onready var selection_indicator: Sprite2D = $SelectionIndicator

# Signals
signal stat_changed(stat_name: String, value: float)
signal state_changed(new_state: State)
signal died()

func _ready() -> void:
	# Initialize visuals
	if selection_indicator:
		selection_indicator.visible = false

	# Initialize task system
	task_queue = TaskQueueScript.new(self)

	# Create default idle task
	_idle_task = IdleTaskScript.new()
	task_queue.add_task(_idle_task)

	# Start stat decay
	_start_stat_decay()

func _process(delta: float) -> void:
	# Update stats based on state
	_update_stats(delta)

	# Process AI tasks
	if current_state != State.DEAD:
		_process_ai(delta)

	# Handle old path-based movement (deprecated, kept for compatibility)
	if current_state == State.WALKING and current_path.size() > 0:
		_follow_path(delta)

func _process_ai(delta: float) -> void:
	# Check if colonist needs urgent care
	_check_urgent_needs()

	# Process task queue
	if task_queue != null:
		task_queue.process(delta)

func _check_urgent_needs() -> void:
	# Check if colonist is hungry and needs food
	if hunger < HUNGER_THRESHOLD:
		# Check if food task already exists
		if not _has_task_of_type(FindFoodTaskScript):
			var food_task = FindFoodTaskScript.new()
			task_queue.add_task(food_task)

	# Check if colonist is tired and needs sleep
	if energy < ENERGY_THRESHOLD:
		# Check if sleep task already exists
		if not _has_task_of_type(SleepTaskScript):
			var sleep_task = SleepTaskScript.new()
			task_queue.add_task(sleep_task)

func _has_task_of_type(task_type) -> bool:
	if task_queue == null:
		return false

	# Check current task
	var current_task = task_queue.get_current_task()
	if current_task != null and is_instance_of(current_task, task_type):
		return true

	# Check queued tasks (can't easily access private _tasks array, so return false)
	# This is okay - tasks will just get added and priority will determine execution
	return false

func _update_stats(delta: float) -> void:
	if current_state == State.DEAD:
		return

	# Hunger decay (always)
	hunger -= hunger_decay_rate * delta
	hunger = clamp(hunger, 0.0, max_hunger)
	stat_changed.emit("hunger", hunger)

	# Energy decay/recovery
	if current_state == State.SLEEPING:
		energy += energy_recovery_rate * delta
		energy = clamp(energy, 0.0, max_energy)
	elif current_state != State.IDLE:
		energy -= energy_decay_rate * delta
		energy = clamp(energy, 0.0, max_energy)
	stat_changed.emit("energy", energy)

	# Update mood based on needs
	_update_mood()

	# Check death conditions
	_check_death_conditions()

func _update_mood() -> void:
	# Mood is affected by hunger and energy
	var hunger_factor = hunger / max_hunger
	var energy_factor = energy / max_energy

	# Simple mood calculation
	var target_mood = (hunger_factor + energy_factor) * 50.0

	# Smooth mood changes
	mood = lerp(mood, target_mood, 0.1)
	mood = clamp(mood, 0.0, max_mood)
	stat_changed.emit("mood", mood)

func _check_death_conditions() -> void:
	if hunger <= 0.0:
		die("starvation")
	elif energy <= 0.0:
		die("exhaustion")
	elif health <= 0.0:
		die("injuries")

func die(cause: String) -> void:
	if current_state == State.DEAD:
		return

	print("%s died from %s" % [colonist_name, cause])
	change_state(State.DEAD)
	died.emit()

	# Clear all tasks
	if task_queue != null:
		task_queue.clear_all_tasks()

	# Visual feedback
	if sprite:
		sprite.modulate = Color(0.5, 0.5, 0.5, 0.7)

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(new_state)

func set_state(new_state: State) -> void:
	change_state(new_state)

func set_path(path: PackedVector2Array) -> void:
	current_path = path
	path_index = 0
	if path.size() > 0:
		change_state(State.WALKING)

func _follow_path(delta: float) -> void:
	if current_path.size() == 0 or path_index >= current_path.size():
		current_path = []
		path_index = 0
		change_state(State.IDLE)
		return

	var target = current_path[path_index]
	var direction = (target - global_position).normalized()
	var distance = global_position.distance_to(target)

	if distance < 5.0:
		# Reached waypoint
		path_index += 1
		if path_index >= current_path.size():
			current_path = []
			path_index = 0
			change_state(State.IDLE)
	else:
		# Move towards waypoint
		velocity = direction * move_speed
		move_and_slide()

func eat_food(food_value: float) -> void:
	hunger = min(hunger + food_value, max_hunger)
	stat_changed.emit("hunger", hunger)
	print("%s ate food (+%.1f hunger)" % [colonist_name, food_value])

func rest(duration: float) -> void:
	energy = min(energy + energy_recovery_rate * duration, max_energy)
	stat_changed.emit("energy", energy)

func take_damage(damage: float) -> void:
	health -= damage
	health = clamp(health, 0.0, max_health)
	stat_changed.emit("health", health)

	if health <= 0.0:
		die("injuries")

func set_selected(selected: bool) -> void:
	is_selected = selected
	if selection_indicator:
		selection_indicator.visible = selected

func _start_stat_decay() -> void:
	# Stats decay is handled in _process
	pass

func get_state_name() -> String:
	match current_state:
		State.IDLE: return "Idle"
		State.WALKING: return "Walking"
		State.WORKING: return "Working"
		State.SLEEPING: return "Sleeping"
		State.EATING: return "Eating"
		State.DEAD: return "Dead"
		_: return "Unknown"

func get_current_task_description() -> String:
	if task_queue != null:
		return task_queue.get_current_task_description()
	return "No task"

func get_stats_summary() -> Dictionary:
	return {
		"name": colonist_name,
		"health": health,
		"hunger": hunger,
		"energy": energy,
		"mood": mood,
		"state": get_state_name()
	}
