## Visual indicator for designated harvest locations
extends Node2D

## Indicator sprite
var indicator: Sprite2D = null

## Pulsing animation
var pulse_time: float = 0.0
const PULSE_SPEED: float = 2.0
const MIN_SCALE: float = 0.8
const MAX_SCALE: float = 1.2

func _ready() -> void:
	_create_indicator()

func _create_indicator() -> void:
	# Create a simple colored circle as indicator
	indicator = Sprite2D.new()

	# Create placeholder texture
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 0.0, 0.7))  # Yellow with transparency

	indicator.texture = ImageTexture.create_from_image(image)
	indicator.modulate = Color(1.0, 1.0, 0.0, 0.8)
	add_child(indicator)

func _process(delta: float) -> void:
	# Pulse animation
	pulse_time += delta * PULSE_SPEED
	var scale_factor = MIN_SCALE + (MAX_SCALE - MIN_SCALE) * (sin(pulse_time) * 0.5 + 0.5)

	if indicator:
		indicator.scale = Vector2(scale_factor, scale_factor)
