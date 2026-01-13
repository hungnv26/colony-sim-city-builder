## Build menu UI - allows player to select and place buildings
extends Control

const BuildingDefinitionsScript = preload("res://scripts/systems/building_definitions.gd")

## Reference to building manager
var building_manager = null

## UI components
var category_tabs: TabContainer = null
var building_buttons: Dictionary = {}  # category -> Array[Button]

## Signals
signal building_selected(building_id: String)

func _ready() -> void:
	_setup_ui()

## Initialize with building manager reference
func initialize(manager) -> void:
	building_manager = manager

	# Connect to placement mode changes
	if building_manager:
		building_manager.placement_mode_changed.connect(_on_placement_mode_changed)

## Setup UI layout
func _setup_ui() -> void:
	# Create main container
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	margin.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "Build Menu"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	# Category tabs
	category_tabs = TabContainer.new()
	category_tabs.custom_minimum_size = Vector2(250, 400)
	vbox.add_child(category_tabs)

	# Create tabs for each category
	_create_category_tabs()

	# Close button
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(_on_close_pressed)
	vbox.add_child(close_btn)

	# Start hidden
	visible = false

## Create tabs for building categories
func _create_category_tabs() -> void:
	var category_names = {
		BuildingDefinitionsScript.BuildingDataScript.Category.STORAGE: "Storage",
		BuildingDefinitionsScript.BuildingDataScript.Category.HOUSING: "Housing",
		BuildingDefinitionsScript.BuildingDataScript.Category.PRODUCTION: "Production",
		BuildingDefinitionsScript.BuildingDataScript.Category.UTILITY: "Utility",
		BuildingDefinitionsScript.BuildingDataScript.Category.DEFENSE: "Defense",
		BuildingDefinitionsScript.BuildingDataScript.Category.DECORATION: "Decoration"
	}

	for category in category_names.keys():
		var tab = ScrollContainer.new()
		tab.name = category_names[category]
		category_tabs.add_child(tab)

		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.add_child(vbox)

		building_buttons[category] = []

		# Add buttons for each building in this category
		var definitions = BuildingDefinitionsScript.get_by_category(category)
		for definition in definitions:
			var btn = _create_building_button(definition)
			vbox.add_child(btn)
			building_buttons[category].append(btn)

## Create a button for a building
func _create_building_button(definition) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(220, 60)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Build button text
	var text = "%s\n" % definition.display_name
	text += "Size: %dx%d  Time: %.0fs\n" % [definition.width, definition.height, definition.build_time]

	# Add resource requirements
	if definition.required_resources.size() > 0:
		text += "Cost: "
		var first = true
		for resource in definition.required_resources:
			if not first:
				text += ", "
			text += "%d %s" % [definition.required_resources[resource], resource.capitalize()]
			first = false

	btn.text = text
	btn.pressed.connect(_on_building_button_pressed.bind(definition.building_id))

	return btn

## Handle building button press
func _on_building_button_pressed(building_id: String) -> void:
	if building_manager:
		building_manager.start_placement_mode(building_id)
		building_selected.emit(building_id)
		print("Started placing: %s" % building_id)

## Handle close button
func _on_close_pressed() -> void:
	hide()

## Toggle menu visibility
func toggle() -> void:
	visible = not visible

## Show the menu
func show_menu() -> void:
	show()

## Hide the menu
func hide_menu() -> void:
	hide()

## Handle placement mode changes
func _on_placement_mode_changed(is_active: bool) -> void:
	# Optionally auto-hide menu when placement starts
	if is_active:
		# Keep menu open so player can place multiple buildings
		pass
