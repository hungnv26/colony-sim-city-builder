extends Node

class_name ResourceSpriteGenerator

# Generates SVG sprites for resource nodes (trees, rocks, ore)

static func generate_tree_sprite() -> String:
	var size = 32
	var svg = SVGGenerator.create_svg_header(size, size)

	# Tree trunk
	svg += SVGGenerator.add_rect(13, 16, 6, 14, "#8b4513", "#654321", 1)

	# Tree foliage (circle)
	svg += SVGGenerator.add_circle(16, 12, 10, "#228b22", "#1a6b1a", 1)
	svg += SVGGenerator.add_circle(12, 10, 7, "#2a9d2a", "#1a6b1a", 1)
	svg += SVGGenerator.add_circle(20, 10, 7, "#2a9d2a", "#1a6b1a", 1)

	svg += SVGGenerator.create_svg_footer()
	return svg

static func generate_rock_sprite() -> String:
	var size = 32
	var svg = SVGGenerator.create_svg_header(size, size)

	# Rock shape (irregular polygon)
	var points = PackedVector2Array([
		Vector2(16, 8),
		Vector2(24, 14),
		Vector2(22, 24),
		Vector2(10, 24),
		Vector2(8, 14)
	])

	svg += SVGGenerator.add_polygon(points, "#808080", "#606060", 1.5)

	# Highlight
	var highlight_points = PackedVector2Array([
		Vector2(14, 12),
		Vector2(18, 10),
		Vector2(20, 14)
	])
	svg += SVGGenerator.add_polygon(highlight_points, "#a0a0a0")

	svg += SVGGenerator.create_svg_footer()
	return svg

static func generate_iron_ore_sprite() -> String:
	var size = 32
	var svg = SVGGenerator.create_svg_header(size, size)

	# Base rock
	var points = PackedVector2Array([
		Vector2(16, 8),
		Vector2(24, 14),
		Vector2(22, 24),
		Vector2(10, 24),
		Vector2(8, 14)
	])
	svg += SVGGenerator.add_polygon(points, "#696969", "#505050", 1.5)

	# Iron veins (darker patches)
	svg += SVGGenerator.add_circle(14, 16, 3, "#4a4a4a")
	svg += SVGGenerator.add_circle(18, 18, 2, "#4a4a4a")
	svg += SVGGenerator.add_circle(16, 12, 2, "#5a5a5a")

	svg += SVGGenerator.create_svg_footer()
	return svg

static func generate_gold_ore_sprite() -> String:
	var size = 32
	var svg = SVGGenerator.create_svg_header(size, size)

	# Base rock
	var points = PackedVector2Array([
		Vector2(16, 8),
		Vector2(24, 14),
		Vector2(22, 24),
		Vector2(10, 24),
		Vector2(8, 14)
	])
	svg += SVGGenerator.add_polygon(points, "#808080", "#606060", 1.5)

	# Gold veins
	svg += SVGGenerator.add_circle(14, 16, 3, "#ffd700")
	svg += SVGGenerator.add_circle(18, 18, 2, "#ffed4e")
	svg += SVGGenerator.add_circle(16, 12, 2, "#daa520")

	svg += SVGGenerator.create_svg_footer()
	return svg

static func generate_all_resource_sprites() -> void:
	print("Generating resource sprites...")

	var resources = {
		"tree": generate_tree_sprite(),
		"rock": generate_rock_sprite(),
		"iron_ore": generate_iron_ore_sprite(),
		"gold_ore": generate_gold_ore_sprite()
	}

	for resource_name in resources:
		var svg_content = resources[resource_name]
		var file_path = "res://assets/sprites/resources/%s.svg" % resource_name
		SVGGenerator.save_svg_to_file(svg_content, file_path)

	print("Resource sprite generation complete!")
