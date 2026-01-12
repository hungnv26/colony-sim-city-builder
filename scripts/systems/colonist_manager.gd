extends Node

class_name ColonistManager

# Colonist management
var colonists: Array[Colonist] = []
var selected_colonist: Colonist = null

# Colonist scene
const ColonistScene = preload("res://scenes/entities/colonist.tscn")

# Spawn settings
@export var starting_colonist_count: int = 3
@export var spawn_radius: float = 200.0

# Parent node for colonists
var colonist_container: Node2D

# Signals
signal colonist_spawned(colonist: Colonist)
signal colonist_died(colonist: Colonist)
signal colonist_selected(colonist: Colonist)
signal colonist_deselected()

func _ready() -> void:
	# Find or create colonist container
	if not colonist_container:
		colonist_container = get_parent()

func initialize(container: Node2D, spawn_position: Vector2) -> void:
	colonist_container = container

	# Spawn starting colonists
	for i in range(starting_colonist_count):
		var offset = Vector2(
			randf_range(-spawn_radius, spawn_radius),
			randf_range(-spawn_radius, spawn_radius)
		)
		spawn_colonist(spawn_position + offset, "Colonist %d" % (i + 1))

func spawn_colonist(position: Vector2, col_name: String = "Colonist") -> Colonist:
	var colonist = ColonistScene.instantiate() as Colonist
	colonist.global_position = position
	colonist.colonist_name = col_name

	# Connect signals
	colonist.died.connect(_on_colonist_died.bind(colonist))

	# Add to scene
	colonist_container.add_child(colonist)
	colonists.append(colonist)

	# Load colonist sprite
	_load_colonist_sprite(colonist)

	colonist_spawned.emit(colonist)
	print("Spawned colonist: %s at %v" % [col_name, position])

	return colonist

func _load_colonist_sprite(colonist: Colonist) -> void:
	# Load a random colonist sprite variation
	var variation = randi() % 10
	var sprite_path = "res://assets/sprites/colonists/colonist_%d.svg" % variation

	if ResourceLoader.exists(sprite_path):
		colonist.sprite.texture = load(sprite_path)
	else:
		# Fallback: create a simple colored circle
		print("Warning: Colonist sprite not found: %s" % sprite_path)

func _on_colonist_died(colonist: Colonist) -> void:
	colonists.erase(colonist)
	if selected_colonist == colonist:
		deselect_colonist()

	colonist_died.emit(colonist)
	print("Colonist died: %s (Remaining: %d)" % [colonist.colonist_name, colonists.size()])

func select_colonist(colonist: Colonist) -> void:
	if selected_colonist:
		selected_colonist.set_selected(false)

	selected_colonist = colonist
	colonist.set_selected(true)
	colonist_selected.emit(colonist)

func deselect_colonist() -> void:
	if selected_colonist:
		selected_colonist.set_selected(false)
		selected_colonist = null
	colonist_deselected.emit()

func get_colonist_at_position(world_pos: Vector2, radius: float = 20.0) -> Colonist:
	for colonist in colonists:
		if colonist.global_position.distance_to(world_pos) < radius:
			return colonist
	return null

func get_all_colonists() -> Array[Colonist]:
	return colonists

func get_living_colonists() -> Array[Colonist]:
	var living: Array[Colonist] = []
	for colonist in colonists:
		if colonist.current_state != Colonist.State.DEAD:
			living.append(colonist)
	return living

func get_colonist_count() -> int:
	return colonists.size()

func get_living_count() -> int:
	return get_living_colonists().size()
