extends PanelContainer

# UI elements
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var state_label: Label = $VBoxContainer/StateLabel
@onready var health_bar: ProgressBar = $VBoxContainer/HealthBar
@onready var hunger_bar: ProgressBar = $VBoxContainer/HungerBar
@onready var energy_bar: ProgressBar = $VBoxContainer/EnergyBar
@onready var mood_bar: ProgressBar = $VBoxContainer/MoodBar

# Current colonist
var current_colonist: Colonist = null

func _ready() -> void:
	hide()

func show_colonist_info(colonist: Colonist) -> void:
	if not colonist:
		hide()
		return

	current_colonist = colonist

	# Disconnect previous signals
	if current_colonist and current_colonist != colonist:
		_disconnect_signals()

	# Connect to colonist signals
	colonist.stat_changed.connect(_on_stat_changed)
	colonist.state_changed.connect(_on_state_changed)
	colonist.died.connect(_on_colonist_died)

	# Update UI
	_update_ui()
	show()

func hide_colonist_info() -> void:
	_disconnect_signals()
	current_colonist = null
	hide()

func _disconnect_signals() -> void:
	if current_colonist:
		if current_colonist.stat_changed.is_connected(_on_stat_changed):
			current_colonist.stat_changed.disconnect(_on_stat_changed)
		if current_colonist.state_changed.is_connected(_on_state_changed):
			current_colonist.state_changed.disconnect(_on_state_changed)
		if current_colonist.died.is_connected(_on_colonist_died):
			current_colonist.died.disconnect(_on_colonist_died)

func _update_ui() -> void:
	if not current_colonist:
		return

	var stats = current_colonist.get_stats_summary()

	if name_label:
		name_label.text = stats["name"]

	if state_label:
		state_label.text = "State: %s" % stats["state"]

	if health_bar:
		health_bar.value = stats["health"]

	if hunger_bar:
		hunger_bar.value = stats["hunger"]

	if energy_bar:
		energy_bar.value = stats["energy"]

	if mood_bar:
		mood_bar.value = stats["mood"]

func _on_stat_changed(stat_name: String, value: float) -> void:
	# Update specific stat bar
	match stat_name:
		"health":
			if health_bar:
				health_bar.value = value
		"hunger":
			if hunger_bar:
				hunger_bar.value = value
		"energy":
			if energy_bar:
				energy_bar.value = value
		"mood":
			if mood_bar:
				mood_bar.value = value

func _on_state_changed(new_state) -> void:
	if current_colonist and state_label:
		state_label.text = "State: %s" % current_colonist.get_state_name()

func _on_colonist_died() -> void:
	hide_colonist_info()
