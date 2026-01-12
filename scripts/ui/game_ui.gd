extends Control

@onready var resources_label: Label = $TopBar/MarginContainer/HBoxContainer/ResourcesLabel
@onready var colonist_info_panel = $ColonistInfoPanel

func _ready() -> void:
	_update_ui()
	# Connect to resource changes
	ResourceManager.resource_changed.connect(_on_resource_changed)

	# Hide colonist info panel initially
	if colonist_info_panel:
		colonist_info_panel.hide()

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
