extends Node

# Input action signals
signal move_camera_requested(direction: Vector2)
signal camera_drag_requested(delta: Vector2)
signal zoom_requested(zoom_delta: float)
signal pause_requested()
signal select_requested(position: Vector2)

# Input state
var mouse_position: Vector2 = Vector2.ZERO
var is_mouse_dragging: bool = false
var drag_start_position: Vector2 = Vector2.ZERO
var is_middle_mouse_dragging: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	print("InputManager initialized")

func _input(event: InputEvent) -> void:
	# Handle mouse position
	if event is InputEventMouse:
		mouse_position = event.position

	# Handle mouse motion for middle mouse drag
	if event is InputEventMouseMotion:
		if is_middle_mouse_dragging:
			var delta = event.relative
			camera_drag_requested.emit(delta)

	# Handle mouse button events
	if event is InputEventMouseButton:
		_handle_mouse_button(event)

	# Handle keyboard shortcuts
	if event.is_action_pressed("ui_cancel"):
		pause_requested.emit()

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	# Left click for selection
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_mouse_dragging = true
			drag_start_position = event.position
		else:
			is_mouse_dragging = false
			if event.position.distance_to(drag_start_position) < 5.0:
				# It was a click, not a drag
				select_requested.emit(event.position)

	# Middle mouse button for camera dragging
	if event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			is_middle_mouse_dragging = true
			last_mouse_position = event.position
		else:
			is_middle_mouse_dragging = false

	# Mouse wheel for zooming
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom_requested.emit(0.1)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom_requested.emit(-0.1)

func _process(_delta: float) -> void:
	# Handle camera movement with WASD/Arrow keys
	var camera_direction = Vector2.ZERO

	if Input.is_action_pressed("camera_up"):
		camera_direction.y -= 1
	if Input.is_action_pressed("camera_down"):
		camera_direction.y += 1
	if Input.is_action_pressed("camera_left"):
		camera_direction.x -= 1
	if Input.is_action_pressed("camera_right"):
		camera_direction.x += 1

	if camera_direction != Vector2.ZERO:
		move_camera_requested.emit(camera_direction.normalized())

func get_mouse_world_position(camera: Camera2D) -> Vector2:
	return camera.get_global_mouse_position()
