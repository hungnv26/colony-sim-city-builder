extends Control

const BuildMenuScript = preload("res://scripts/ui/build_menu.gd")

@onready var resources_label: Label = $TopBar/MarginContainer/HBoxContainer/ResourcesLabel
@onready var colonist_info_panel = $ColonistInfoPanel

var build_menu = null
var build_menu_button: Button = null

func _ready() -> void:
	_update_ui()
	# Connect to resource changes
	ResourceManager.resource_changed.connect(_on_resource_changed)

	# Hide colonist info panel initially
	if colonist_info_panel:
		colonist_info_panel.hide()

	# Setup build menu
	_setup_build_menu()

func _update_ui() -> void:
	# Show current resources
	var resources = ResourceManager.get_all_resources()
	var text = "Wood: %d  Stone: %d  Food: %d  Metal: %d  Gold: %d" % [
		resources.get("wood", 0),
		resources.get("stone", 0),
		resources.get("food", 0),
		resources.get("metal", 0),
		resources.get("gold", 0)
	]
	resources_label.text = text

func _on_resource_changed(_resource_type: String, _amount: int, _total: int) -> void:
	_update_ui()

func _on_menu_button_pressed() -> void:
	# Pause the game and show menu
	get_tree().paused = true
	# TODO: Show pause menu overlay
	print("Menu button pressed")

func show_colonist_info(colonist) -> void:
	if colonist_info_panel:
		colonist_info_panel.show_colonist_info(colonist)

func hide_colonist_info() -> void:
	if colonist_info_panel:
		colonist_info_panel.hide_colonist_info()

func _setup_build_menu() -> void:
	# Create build menu
	build_menu = BuildMenuScript.new()
	add_child(build_menu)

	# Position it on the left side
	build_menu.position = Vector2(20, 100)

	# Get building manager from game world
	var game_world = get_node("/root/GameWorld")
	if game_world and game_world.has_method("get_building_manager"):
		var building_manager = game_world.get_building_manager()
		if building_manager:
			build_menu.initialize(building_manager)

	# Create build menu toggle button
	var top_bar = get_node_or_null("TopBar/MarginContainer/HBoxContainer")
	if top_bar:
		build_menu_button = Button.new()
		build_menu_button.text = "Build (B)"
		build_menu_button.pressed.connect(_on_build_menu_button_pressed)
		top_bar.add_child(build_menu_button)

func _on_build_menu_button_pressed() -> void:
	if build_menu:
		build_menu.toggle()

func _input(event: InputEvent) -> void:
	# Toggle build menu with 'B' key
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			if build_menu:
				build_menu.toggle()
		elif event.keycode == KEY_ESCAPE:
			# Cancel placement mode if active
			var game_world = get_node("/root/GameWorld")
			if game_world and game_world.has_method("get_building_manager"):
				var building_manager = game_world.get_building_manager()
				if building_manager and building_manager.is_placing_building:
					building_manager.cancel_placement_mode()
