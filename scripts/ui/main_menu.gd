extends Control

func _ready() -> void:
	pass

func _on_new_game_pressed() -> void:
	GameStateManager.change_state(GameStateManager.GameState.PLAYING)
	get_tree().change_scene_to_file("res://scenes/gameplay/game_world.tscn")

func _on_load_game_pressed() -> void:
	# TODO: Implement load game functionality
	print("Load game not yet implemented")

func _on_settings_pressed() -> void:
	# TODO: Implement settings menu
	print("Settings not yet implemented")

func _on_quit_pressed() -> void:
	get_tree().quit()
