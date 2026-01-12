@tool
extends EditorScript

# Utility script to generate all SVG sprites
# Run this from the Godot editor: File > Run

func _run() -> void:
	print("=== Starting Sprite Generation ===")

	# Generate terrain sprites
	TerrainSpriteGenerator.generate_all_terrain_sprites(3)

	# Generate building sprites
	BuildingSpriteGenerator.generate_all_building_sprites()

	# Generate colonist sprites
	ColonistSpriteGenerator.generate_colonist_set(10)

	print("=== Sprite Generation Complete ===")
	print("Check the assets/sprites/ folders for generated SVG files")
