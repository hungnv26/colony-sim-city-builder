## Building entity - represents a placed building in the world
class_name Building
extends Node2D

const BuildingDataScript = preload("res://scripts/systems/building_data.gd")

## Building data (definition + state)
var building_data: BuildingDataScript = null

## Grid position (in tiles)
var grid_position: Vector2i = Vector2i.ZERO

## Visual components
var sprite: Sprite2D = null
var construction_overlay: ColorRect = null
var health_bar: ProgressBar = null

## Signals
signal construction_complete()
signal building_destroyed()
signal health_changed(current: float, maximum: float)

func _ready() -> void:
	_setup_visuals()

## Initialize building with data and position
func initialize(data: BuildingDataScript, grid_pos: Vector2i) -> void:
	building_data = data
	grid_position = grid_pos

	# Set world position (convert grid to world coordinates)
	const TILE_SIZE = 32
	global_position = Vector2(
		grid_pos.x * TILE_SIZE + (data.width * TILE_SIZE) / 2.0,
		grid_pos.y * TILE_SIZE + (data.height * TILE_SIZE) / 2.0
	)

	_setup_visuals()

	# Start as under construction
	if not building_data.is_constructed:
		_show_construction_overlay()

## Setup visual components
func _setup_visuals() -> void:
	if building_data == null:
		return

	# Create main sprite
	if sprite == null:
		sprite = Sprite2D.new()
		add_child(sprite)

	# Load sprite texture if available
	if ResourceLoader.exists(building_data.sprite_path):
		sprite.texture = load(building_data.sprite_path)
	else:
		# Create placeholder rectangle
		_create_placeholder_sprite()

	sprite.modulate = building_data.color

	# Scale sprite to match building size
	const TILE_SIZE = 32
	var target_size = Vector2(building_data.width * TILE_SIZE, building_data.height * TILE_SIZE)
	if sprite.texture:
		var tex_size = sprite.texture.get_size()
		sprite.scale = target_size / tex_size

## Create placeholder sprite when texture doesn't exist
func _create_placeholder_sprite() -> void:
	# Create a simple colored rectangle as placeholder
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(building_data.color)
	sprite.texture = ImageTexture.create_from_image(image)

## Show construction overlay
func _show_construction_overlay() -> void:
	if construction_overlay == null:
		construction_overlay = ColorRect.new()
		construction_overlay.color = Color(0, 0, 0, 0.5)
		const TILE_SIZE = 32
		construction_overlay.size = Vector2(
			building_data.width * TILE_SIZE,
			building_data.height * TILE_SIZE
		)
		construction_overlay.position = -construction_overlay.size / 2.0
		add_child(construction_overlay)

	construction_overlay.visible = true

## Hide construction overlay
func _hide_construction_overlay() -> void:
	if construction_overlay:
		construction_overlay.visible = false

## Update construction progress
func update_construction_progress(progress: float) -> void:
	if building_data == null:
		return

	building_data.construction_progress = clamp(progress, 0.0, 1.0)

	# Update visual opacity based on progress
	if sprite:
		sprite.modulate.a = 0.3 + (0.7 * building_data.construction_progress)

	# Complete construction when progress reaches 100%
	if building_data.construction_progress >= 1.0 and not building_data.is_constructed:
		complete_construction()

## Complete construction
func complete_construction() -> void:
	if building_data == null:
		return

	building_data.is_constructed = true
	building_data.construction_progress = 1.0

	_hide_construction_overlay()

	if sprite:
		sprite.modulate.a = 1.0

	construction_complete.emit()
	print("Building '%s' construction complete at %v" % [building_data.display_name, grid_position])

## Take damage
func take_damage(amount: float) -> void:
	if building_data == null:
		return

	building_data.current_health -= amount
	building_data.current_health = clamp(building_data.current_health, 0.0, building_data.max_health)

	health_changed.emit(building_data.current_health, building_data.max_health)

	if building_data.current_health <= 0.0:
		destroy_building()

## Destroy building
func destroy_building() -> void:
	if building_data == null:
		return

	print("Building '%s' destroyed at %v" % [building_data.display_name, grid_position])
	building_destroyed.emit()
	queue_free()

## Get occupied tiles
func get_occupied_tiles() -> Array:
	var tiles: Array = []
	for x in range(building_data.width):
		for y in range(building_data.height):
			tiles.append(grid_position + Vector2i(x, y))
	return tiles

## Check if building is constructed
func is_constructed() -> bool:
	return building_data != null and building_data.is_constructed

## Get building info for UI
func get_info_string() -> String:
	if building_data == null:
		return "Unknown Building"

	var info = "%s\n" % building_data.display_name

	if building_data.is_constructed:
		info += "Health: %.0f/%.0f\n" % [building_data.current_health, building_data.max_health]
	else:
		info += "Construction: %.0f%%\n" % (building_data.construction_progress * 100.0)

	return info
