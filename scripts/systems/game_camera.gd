extends Camera2D

# Camera movement settings
@export var camera_speed: float = 400.0
@export var edge_scroll_margin: int = 20
@export var edge_scroll_speed: float = 300.0

# Zoom settings
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var zoom_speed: float = 0.1
@export var smooth_zoom: bool = true

# Camera bounds (world limits)
@export var enable_bounds: bool = true
@export var bounds_min: Vector2 = Vector2(-2000, -2000)
@export var bounds_max: Vector2 = Vector2(2000, 2000)

# Smooth movement
@export var smooth_camera: bool = true
@export var smooth_factor: float = 10.0

# Internal state
var target_zoom: Vector2 = Vector2.ONE
var target_position: Vector2 = Vector2.ZERO
var viewport_size: Vector2

func _ready() -> void:
	# Set initial zoom
	target_zoom = zoom
	target_position = position

	# Connect to input manager signals
	InputManager.move_camera_requested.connect(_on_move_camera_requested)
	InputManager.camera_drag_requested.connect(_on_camera_drag_requested)
	InputManager.zoom_requested.connect(_on_zoom_requested)

	# Get viewport size
	viewport_size = get_viewport_rect().size

func _process(delta: float) -> void:
	# Handle edge scrolling
	if GameStateManager.is_playing():
		_handle_edge_scrolling(delta)

	# Smooth camera movement
	if smooth_camera:
		position = position.lerp(target_position, smooth_factor * delta)
	else:
		position = target_position

	# Smooth zoom
	if smooth_zoom:
		zoom = zoom.lerp(target_zoom, smooth_factor * delta)
	else:
		zoom = target_zoom

	# Apply bounds
	if enable_bounds:
		_apply_bounds()

func _on_move_camera_requested(direction: Vector2) -> void:
	# Move camera based on keyboard input
	var move_delta = direction * camera_speed * (1.0 / zoom.x) * get_process_delta_time()
	target_position += move_delta

func _on_camera_drag_requested(delta: Vector2) -> void:
	# Move camera based on middle mouse drag
	# Negate delta because we want to move the camera opposite to mouse movement
	var move_delta = -delta * (1.0 / zoom.x)
	target_position += move_delta
	# Apply immediately for responsive dragging (no lerp delay)
	position = target_position

func _on_zoom_requested(zoom_delta: float) -> void:
	# Adjust zoom level
	var new_zoom = target_zoom.x + zoom_delta
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	target_zoom = Vector2(new_zoom, new_zoom)

func _handle_edge_scrolling(delta: float) -> void:
	if not GameStateManager.is_playing():
		return

	# Don't edge scroll if middle mouse button is being used to drag
	if InputManager.is_middle_mouse_dragging:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var scroll_direction = Vector2.ZERO

	# Check edges
	if mouse_pos.x < edge_scroll_margin:
		scroll_direction.x -= 1
	elif mouse_pos.x > viewport_size.x - edge_scroll_margin:
		scroll_direction.x += 1

	if mouse_pos.y < edge_scroll_margin:
		scroll_direction.y -= 1
	elif mouse_pos.y > viewport_size.y - edge_scroll_margin:
		scroll_direction.y += 1

	# Apply edge scrolling
	if scroll_direction != Vector2.ZERO:
		var move_delta = scroll_direction.normalized() * edge_scroll_speed * (1.0 / zoom.x) * delta
		target_position += move_delta

func _apply_bounds() -> void:
	# Clamp camera position to world bounds
	target_position.x = clamp(target_position.x, bounds_min.x, bounds_max.x)
	target_position.y = clamp(target_position.y, bounds_min.y, bounds_max.y)

func move_to_position(new_position: Vector2, instant: bool = false) -> void:
	# Move camera to specific position
	if instant:
		position = new_position
		target_position = new_position
	else:
		target_position = new_position

func set_zoom_level(new_zoom: float, instant: bool = false) -> void:
	# Set specific zoom level
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	if instant:
		zoom = Vector2(new_zoom, new_zoom)
		target_zoom = Vector2(new_zoom, new_zoom)
	else:
		target_zoom = Vector2(new_zoom, new_zoom)

func focus_on_point(point: Vector2, zoom_level: float = -1) -> void:
	# Focus camera on a specific world point
	move_to_position(point, false)
	if zoom_level > 0:
		set_zoom_level(zoom_level, false)

func reset_camera() -> void:
	# Reset to default position and zoom
	move_to_position(Vector2.ZERO, false)
	set_zoom_level(1.0, false)
