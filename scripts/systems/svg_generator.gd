extends Node

class_name SVGGenerator

# SVG sprite generation utility
# Generates procedural SVG graphics for units, buildings, and terrain

static func create_svg_header(width: int, height: int) -> String:
	return '<?xml version="1.0" encoding="UTF-8"?>\n<svg width="%d" height="%d" viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg">\n' % [width, height, width, height]

static func create_svg_footer() -> String:
	return '</svg>\n'

static func add_rect(x: float, y: float, width: float, height: float, fill: String, stroke: String = "", stroke_width: float = 0) -> String:
	var svg = '<rect x="%f" y="%f" width="%f" height="%f" fill="%s"' % [x, y, width, height, fill]
	if stroke != "":
		svg += ' stroke="%s" stroke-width="%f"' % [stroke, stroke_width]
	svg += '/>\n'
	return svg

static func add_circle(cx: float, cy: float, r: float, fill: String, stroke: String = "", stroke_width: float = 0) -> String:
	var svg = '<circle cx="%f" cy="%f" r="%f" fill="%s"' % [cx, cy, r, fill]
	if stroke != "":
		svg += ' stroke="%s" stroke-width="%f"' % [stroke, stroke_width]
	svg += '/>\n'
	return svg

static func add_polygon(points: PackedVector2Array, fill: String, stroke: String = "", stroke_width: float = 0) -> String:
	var points_str = ""
	for point in points:
		points_str += "%f,%f " % [point.x, point.y]
	points_str = points_str.strip_edges()

	var svg = '<polygon points="%s" fill="%s"' % [points_str, fill]
	if stroke != "":
		svg += ' stroke="%s" stroke-width="%f"' % [stroke, stroke_width]
	svg += '/>\n'
	return svg

static func add_line(x1: float, y1: float, x2: float, y2: float, stroke: String, stroke_width: float = 2) -> String:
	return '<line x1="%f" y1="%f" x2="%f" y2="%f" stroke="%s" stroke-width="%f"/>\n' % [x1, y1, x2, y2, stroke, stroke_width]

static func save_svg_to_file(svg_content: String, file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(svg_content)
		file.close()
		print("SVG saved to: %s" % file_path)
	else:
		push_error("Failed to save SVG to: %s" % file_path)

static func color_to_hex(color: Color) -> String:
	return "#%02x%02x%02x" % [int(color.r * 255), int(color.g * 255), int(color.b * 255)]
