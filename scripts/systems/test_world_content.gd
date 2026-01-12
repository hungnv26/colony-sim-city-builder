extends Node2D

# Temporary test content to visualize the world
# This will be replaced in Phase 2 with proper terrain

func _ready() -> void:
	_create_test_grid()
	_create_test_objects()

func _create_test_grid() -> void:
	# Draw a reference grid so you can see camera movement
	var grid_size = 50
	var grid_extent = 1000

	for x in range(-grid_extent, grid_extent + 1, grid_size):
		_draw_grid_line(Vector2(x, -grid_extent), Vector2(x, grid_extent), Color.DIM_GRAY)

	for y in range(-grid_extent, grid_extent + 1, grid_size):
		_draw_grid_line(Vector2(-grid_extent, y), Vector2(grid_extent, y), Color.DIM_GRAY)

	# Draw axes
	_draw_grid_line(Vector2(-grid_extent, 0), Vector2(grid_extent, 0), Color.RED)
	_draw_grid_line(Vector2(0, -grid_extent), Vector2(0, grid_extent), Color.GREEN)

func _draw_grid_line(from: Vector2, to: Vector2, color: Color) -> void:
	var line = Line2D.new()
	line.add_point(from)
	line.add_point(to)
	line.default_color = color
	line.width = 1.0
	add_child(line)

func _create_test_objects() -> void:
	# Create some test squares to visualize zoom and movement
	var colors = [Color.BLUE, Color.RED, Color.GREEN, Color.YELLOW, Color.PURPLE, Color.ORANGE]
	var positions = [
		Vector2(100, 100),
		Vector2(-150, 80),
		Vector2(200, -120),
		Vector2(-100, -150),
		Vector2(0, 200),
		Vector2(-200, 0)
	]

	for i in range(colors.size()):
		_create_test_square(positions[i], 40, colors[i])

func _create_test_square(pos: Vector2, size: float, color: Color) -> void:
	var rect = ColorRect.new()
	rect.position = pos - Vector2(size/2, size/2)
	rect.size = Vector2(size, size)
	rect.color = color
	add_child(rect)

	# Add a label
	var label = Label.new()
	label.text = "Test Object"
	label.position = pos + Vector2(-30, size/2 + 5)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)

# Draw instructions on screen
func _draw() -> void:
	# Center info text
	var font = ThemeDB.fallback_font
	var font_size = 16

	draw_string(font, Vector2(-200, -50), "COLONY SIM - PHASE 1 TEST", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	draw_string(font, Vector2(-200, 0), "Use WASD or Arrow Keys to move camera", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.LIGHT_GRAY)
	draw_string(font, Vector2(-200, 30), "Use Mouse Wheel to zoom", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.LIGHT_GRAY)
	draw_string(font, Vector2(-200, 60), "Move mouse to edges for edge scrolling", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.LIGHT_GRAY)
