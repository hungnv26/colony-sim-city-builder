extends Node

class_name ColonistSpriteGenerator

# Generates procedural colonist sprites
# Creates abstract humanoid figures in various colors

enum BodyType {
	STANDARD,
	TALL,
	SHORT,
	STOCKY
}

static func generate_colonist_sprite(
	seed_value: int = -1,
	body_type: BodyType = BodyType.STANDARD,
	clothing_color: Color = Color.BLUE
) -> String:
	if seed_value >= 0:
		seed(seed_value)

	var size = 32
	var svg = SVGGenerator.create_svg_header(size, size)

	# Adjust proportions based on body type
	var head_size = 8.0
	var body_width = 10.0
	var body_height = 14.0
	var leg_height = 8.0

	match body_type:
		BodyType.TALL:
			body_height = 16.0
			leg_height = 10.0
			head_size = 7.0
		BodyType.SHORT:
			body_height = 12.0
			leg_height = 6.0
			head_size = 9.0
		BodyType.STOCKY:
			body_width = 12.0
			body_height = 13.0

	# Calculate positions
	var center_x = size / 2.0
	var head_y = 6.0
	var body_y = head_y + head_size + 1.0
	var leg_y = body_y + body_height

	# Skin tone (randomize slightly)
	var skin_tones = [
		Color("#ffdfc4"),
		Color("#f0d5be"),
		Color("#eeceb3"),
		Color("#e1b899"),
		Color("#c68642"),
		Color("#8d5524")
	]
	var skin_color = skin_tones[randi() % skin_tones.size()]

	# Head (circle)
	svg += SVGGenerator.add_circle(center_x, head_y, head_size / 2.0, SVGGenerator.color_to_hex(skin_color), "#333", 0.5)

	# Body (rectangle with clothing color)
	svg += SVGGenerator.add_rect(
		center_x - body_width / 2.0,
		body_y,
		body_width,
		body_height,
		SVGGenerator.color_to_hex(clothing_color),
		"#333",
		0.5
	)

	# Legs (two rectangles)
	var leg_width = 4.0
	svg += SVGGenerator.add_rect(
		center_x - body_width / 2.0 + 1.0,
		leg_y,
		leg_width,
		leg_height,
		SVGGenerator.color_to_hex(clothing_color.darkened(0.3)),
		"#333",
		0.5
	)
	svg += SVGGenerator.add_rect(
		center_x + body_width / 2.0 - leg_width - 1.0,
		leg_y,
		leg_width,
		leg_height,
		SVGGenerator.color_to_hex(clothing_color.darkened(0.3)),
		"#333",
		0.5
	)

	# Arms (simple lines)
	svg += SVGGenerator.add_line(
		center_x - body_width / 2.0,
		body_y + 3.0,
		center_x - body_width / 2.0 - 4.0,
		body_y + 8.0,
		SVGGenerator.color_to_hex(skin_color),
		2.0
	)
	svg += SVGGenerator.add_line(
		center_x + body_width / 2.0,
		body_y + 3.0,
		center_x + body_width / 2.0 + 4.0,
		body_y + 8.0,
		SVGGenerator.color_to_hex(skin_color),
		2.0
	)

	svg += SVGGenerator.create_svg_footer()
	return svg

static func create_random_colonist(colonist_id: int) -> void:
	var body_types = [BodyType.STANDARD, BodyType.TALL, BodyType.SHORT, BodyType.STOCKY]
	var clothing_colors = [
		Color.BLUE,
		Color.RED,
		Color.GREEN,
		Color.ORANGE,
		Color.PURPLE,
		Color.BROWN
	]

	var body_type = body_types[colonist_id % body_types.size()]
	var clothing_color = clothing_colors[colonist_id % clothing_colors.size()]

	var svg = generate_colonist_sprite(colonist_id, body_type, clothing_color)
	var file_path = "res://assets/sprites/colonists/colonist_%d.svg" % colonist_id

	SVGGenerator.save_svg_to_file(svg, file_path)

static func generate_colonist_set(count: int = 10) -> void:
	print("Generating %d colonist sprites..." % count)
	for i in range(count):
		create_random_colonist(i)
	print("Colonist sprite generation complete!")
