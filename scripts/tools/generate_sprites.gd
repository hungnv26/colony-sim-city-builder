@tool
extends EditorScript

# Utility script to generate all SVG sprites
# Run this from the Godot editor: File > Run

const TerrainSpriteGeneratorScript = preload("res://scripts/systems/terrain_sprite_generator.gd")
const BuildingSpriteGeneratorScript = preload("res://scripts/systems/building_sprite_generator.gd")
const ColonistSpriteGeneratorScript = preload("res://scripts/systems/colonist_sprite_generator.gd")
const ResourceSpriteGeneratorScript = preload("res://scripts/systems/resource_sprite_generator.gd")

func _run() -> void:
	print("=== Starting Sprite Generation ===")

	# Generate terrain sprites
	TerrainSpriteGeneratorScript.generate_all_terrain_sprites(3)

	# Generate building sprites
	BuildingSpriteGeneratorScript.generate_all_building_sprites()

	# Generate colonist sprites
	ColonistSpriteGeneratorScript.generate_colonist_set(10)

	# Generate resource sprites
	ResourceSpriteGeneratorScript.generate_all_resource_sprites()

	print("=== Sprite Generation Complete ===")
	print("Check the assets/sprites/ folders for generated SVG files")
