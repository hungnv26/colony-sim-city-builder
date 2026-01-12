extends Node

class_name TerrainSpriteGenerator

# Generates procedural terrain tile sprites
# Creates various ground types and natural features

enum TerrainType {
	GRASS,
	DIRT,
	STONE,
	WATER,
	SAND,
	SNOW
}

static func generate_terrain_tile(terrain_type: TerrainType, tile_size: int = 32, variation: int = 0) -> String:
	var svg = SVGGenerator.create_svg_header(tile_size, tile_size)

	match terrain_type:
		TerrainType.GRASS:
			svg += _generate_grass(tile_size, variation)
		TerrainType.DIRT:
			svg += _generate_dirt(tile_size, variation)
		TerrainType.STONE:
			svg += _generate_stone(tile_size, variation)
		TerrainType.WATER:
			svg += _generate_water(tile_size, variation)
		TerrainType.SAND:
			svg += _generate_sand(tile_size, variation)
		TerrainType.SNOW:
			svg += _generate_snow(tile_size, variation)

	svg += SVGGenerator.create_svg_footer()
	return svg

static func _generate_grass(tile_size: int, variation: int) -> String:
	seed(variation)
	var result = ""

	# Base grass color
	var grass_colors = [
		Color("#5a8f3a"),
		Color("#4d7c2f"),
		Color("#6b9d47")
	]
	var base_color = grass_colors[variation % grass_colors.size()]

	# Background
	result += SVGGenerator.add_rect(0, 0, tile_size, tile_size, SVGGenerator.color_to_hex(base_color))

	# Add grass details (small lines)
	for i in range(8):
		var x = randf() * tile_size
		var y = randf() * tile_size
		var length = 2 + randf() * 3
		var dark_grass = base_color.darkened(0.2)
		result += SVGGenerator.add_line(x, y, x, y - length, SVGGenerator.color_to_hex(dark_grass), 0.5)

	return result

static func _generate_dirt(tile_size: int, variation: int) -> String:
	seed(variation)
	var result = ""

	# Base dirt color
	var dirt_colors = [
		Color("#8b7355"),
		Color("#9b8365"),
		Color("#7b6345")
	]
	var base_color = dirt_colors[variation % dirt_colors.size()]

	# Background
	result += SVGGenerator.add_rect(0, 0, tile_size, tile_size, SVGGenerator.color_to_hex(base_color))

	# Add texture (small dots)
	for i in range(12):
		var x = randf() * tile_size
		var y = randf() * tile_size
		var dark_dirt = base_color.darkened(0.15)
		result += SVGGenerator.add_circle(x, y, 0.5 + randf(), SVGGenerator.color_to_hex(dark_dirt))

	return result

static func _generate_stone(tile_size: int, variation: int) -> String:
	seed(variation)
	var result = ""

	# Base stone color
	var stone_colors = [
		Color.GRAY,
		Color.DIM_GRAY,
		Color.DARK_GRAY
	]
	var base_color = stone_colors[variation % stone_colors.size()]

	# Background
	result += SVGGenerator.add_rect(0, 0, tile_size, tile_size, SVGGenerator.color_to_hex(base_color))

	# Add stone texture (irregular shapes)
	for i in range(6):
		var x = randf() * tile_size
		var y = randf() * tile_size
		var size = 2 + randf() * 4
		var lighter = base_color.lightened(0.1)
		result += SVGGenerator.add_rect(x, y, size, size, SVGGenerator.color_to_hex(lighter))

	return result

static func _generate_water(tile_size: int, variation: int) -> String:
	seed(variation)
	var result = ""

	# Base water color
	var water_colors = [
		Color("#4a90e2"),
		Color("#5a9aef"),
		Color("#3a80d2")
	]
	var base_color = water_colors[variation % water_colors.size()]

	# Background
	result += SVGGenerator.add_rect(0, 0, tile_size, tile_size, SVGGenerator.color_to_hex(base_color))

	# Add wave lines
	for i in range(3):
		var y = (i + 1) * tile_size / 4.0 + randf() * 4 - 2
		var lighter = base_color.lightened(0.2)
		result += SVGGenerator.add_line(0, y, tile_size, y, SVGGenerator.color_to_hex(lighter), 1)

	return result

static func _generate_sand(tile_size: int, variation: int) -> String:
	seed(variation)
	var result = ""

	# Base sand color
	var sand_colors = [
		Color("#f4a460"),
		Color("#edc9af"),
		Color("#e4b98a")
	]
	var base_color = sand_colors[variation % sand_colors.size()]

	# Background
	result += SVGGenerator.add_rect(0, 0, tile_size, tile_size, SVGGenerator.color_to_hex(base_color))

	# Add sand texture (tiny dots)
	for i in range(15):
		var x = randf() * tile_size
		var y = randf() * tile_size
		var darker = base_color.darkened(0.1)
		result += SVGGenerator.add_circle(x, y, 0.3 + randf() * 0.5, SVGGenerator.color_to_hex(darker))

	return result

static func _generate_snow(tile_size: int, variation: int) -> String:
	seed(variation)
	var result = ""

	# Base snow color
	var snow_colors = [
		Color.WHITE,
		Color("#f0f0f0"),
		Color("#e8e8e8")
	]
	var base_color = snow_colors[variation % snow_colors.size()]

	# Background
	result += SVGGenerator.add_rect(0, 0, tile_size, tile_size, SVGGenerator.color_to_hex(base_color))

	# Add sparkle effect (small circles)
	for i in range(10):
		var x = randf() * tile_size
		var y = randf() * tile_size
		var lighter = base_color.lightened(0.1)
		result += SVGGenerator.add_circle(x, y, 0.5 + randf(), SVGGenerator.color_to_hex(lighter))

	return result

static func generate_all_terrain_sprites(variations_per_type: int = 3) -> void:
	print("Generating terrain sprites...")

	var terrains = {
		"grass": TerrainType.GRASS,
		"dirt": TerrainType.DIRT,
		"stone": TerrainType.STONE,
		"water": TerrainType.WATER,
		"sand": TerrainType.SAND,
		"snow": TerrainType.SNOW
	}

	for terrain_name in terrains:
		for i in range(variations_per_type):
			var svg = generate_terrain_tile(terrains[terrain_name], 32, i)
			var file_path = "res://assets/sprites/terrain/%s_%d.svg" % [terrain_name, i]
			SVGGenerator.save_svg_to_file(svg, file_path)

	print("Terrain sprite generation complete!")
