extends Node

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.MENU

signal state_changed(new_state: GameState)

func _ready() -> void:
	print("GameStateManager initialized")

func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return

	var old_state = current_state
	current_state = new_state

	print("Game state changed from %s to %s" % [GameState.keys()[old_state], GameState.keys()[new_state]])

	state_changed.emit(new_state)

	# Handle state transitions
	match new_state:
		GameState.PLAYING:
			get_tree().paused = false
		GameState.PAUSED:
			get_tree().paused = true
		GameState.MENU:
			get_tree().paused = false

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func is_paused() -> bool:
	return current_state == GameState.PAUSED
