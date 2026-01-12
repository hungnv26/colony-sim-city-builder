extends Node

class_name BuildingSpriteGenerator

# Generates procedural building sprites
# Creates simple geometric representations of various structures

enum BuildingType {
	STORAGE,
	SLEEPING_QUARTERS,
	WORKBENCH,
	WALL,
	HOUSE
}

static func generate_building_sprite(building_type: BuildingType, width: int = 64, height: int = 64) -> String:
	var svg = SVGGenerator.create_svg_header(width, height)

	match building_type:
		BuildingType.STORAGE:
			svg += _generate_storage(width, height)
		BuildingType.SLEEPING_QUARTERS:
			svg += _generate_sleeping_quarters(width, height)
		BuildingType.WORKBENCH:
			svg += _generate_workbench(width, height)
		BuildingType.WALL:
			svg += _generate_wall(width, height)
		BuildingType.HOUSE:
			svg += _generate_house(width, height)

	svg += SVGGenerator.create_svg_footer()
	return svg

static func _generate_storage(width: int, height: int) -> String:
	var result = ""
	# Simple box/crate design
	var box_color = Color.SADDLE_BROWN
	var margin = 8

	result += SVGGenerator.add_rect(
		margin,
		margin,
		width - margin * 2,
		height - margin * 2,
		SVGGenerator.color_to_hex(box_color),
		"#333",
		2
	)

	# Add wooden planks detail
	for i in range(3):
		var y = margin + (height - margin * 2) * (i + 1) / 4.0
		result += SVGGenerator.add_line(
			margin,
			y,
			width - margin,
			y,
			"#654321",
			1.5
		)

	return result

static func _generate_sleeping_quarters(width: int, height: int) -> String:
	var result = ""
	# Building with bed symbol
	var wall_color = Color("#8b7355")
	var margin = 6

	# Walls
	result += SVGGenerator.add_rect(
		margin,
		margin,
		width - margin * 2,
		height - margin * 2,
		SVGGenerator.color_to_hex(wall_color),
		"#333",
		2
	)

	# Bed representation (simple rectangle)
	var bed_margin = width / 4
	result += SVGGenerator.add_rect(
		bed_margin,
		height / 2,
		width - bed_margin * 2,
		height / 4,
		"#e0e0e0",
		"#666",
		1
	)

	# Pillow
	result += SVGGenerator.add_circle(
		width / 2,
		height / 2 + 3,
		5,
		"#cccccc",
		"#666",
		1
	)

	return result

static func _generate_workbench(width: int, height: int) -> String:
	var result = ""
	# Workbench with tools
	var bench_color = Color("#a0826d")

	# Table top
	result += SVGGenerator.add_rect(
		8,
		height / 2 - 5,
		width - 16,
		10,
		SVGGenerator.color_to_hex(bench_color),
		"#333",
		2
	)

	# Legs
	result += SVGGenerator.add_rect(10, height / 2 + 5, 4, height / 2 - 10, "#654321", "#333", 1)
	result += SVGGenerator.add_rect(width - 14, height / 2 + 5, 4, height / 2 - 10, "#654321", "#333", 1)

	# Tools on top (simple shapes)
	result += SVGGenerator.add_rect(width / 2 - 8, height / 2 - 12, 16, 4, "#888888", "#333", 1)
	result += SVGGenerator.add_circle(width / 2 + 12, height / 2 - 3, 3, "#444444", "#333", 1)

	return result

static func _generate_wall(width: int, height: int) -> String:
	var result = ""
	# Stone wall section
	var stone_color = Color.GRAY

	result += SVGGenerator.add_rect(
		width / 4,
		4,
		width / 2,
		height - 8,
		SVGGenerator.color_to_hex(stone_color),
		"#333",
		2
	)

	# Stone blocks detail
	for i in range(4):
		var y = 4 + (height - 12) * i / 4.0 + 5
		result += SVGGenerator.add_line(
			width / 4,
			y,
			width * 3 / 4,
			y,
			"#555",
			1
		)

	return result

static func _generate_house(width: int, height: int) -> String:
	var result = ""
	# Simple house with roof
	var wall_color = Color("#d2b48c")
	var roof_color = Color("#8b4513")

	# Roof (triangle)
	var roof_points = PackedVector2Array([
		Vector2(width / 2, 8),
		Vector2(8, height / 2),
		Vector2(width - 8, height / 2)
	])
	result += SVGGenerator.add_polygon(roof_points, SVGGenerator.color_to_hex(roof_color), "#333", 2)

	# Walls
	result += SVGGenerator.add_rect(
		12,
		height / 2,
		width - 24,
		height / 2 - 8,
		SVGGenerator.color_to_hex(wall_color),
		"#333",
		2
	)

	# Door
	result += SVGGenerator.add_rect(
		width / 2 - 6,
		height - 20,
		12,
		15,
		"#654321",
		"#333",
		1
	)

	# Window
	result += SVGGenerator.add_rect(
		width / 2 + 10,
		height / 2 + 8,
		8,
		8,
		"#87ceeb",
		"#333",
		1
	)

	return result

static func generate_all_building_sprites() -> void:
	print("Generating building sprites...")

	var buildings = {
		"storage": BuildingType.STORAGE,
		"sleeping_quarters": BuildingType.SLEEPING_QUARTERS,
		"workbench": BuildingType.WORKBENCH,
		"wall": BuildingType.WALL,
		"house": BuildingType.HOUSE
	}

	for building_name in buildings:
		var svg = generate_building_sprite(buildings[building_name])
		var file_path = "res://assets/sprites/buildings/%s.svg" % building_name
		SVGGenerator.save_svg_to_file(svg, file_path)

	print("Building sprite generation complete!")
