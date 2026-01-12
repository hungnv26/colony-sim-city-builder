extends Node

# Resource tracking
var resources: Dictionary = {
	"wood": 0,
	"stone": 0,
	"food": 0,
	"metal": 0,
	"gold": 0
}

signal resource_changed(resource_type: String, amount: int, total: int)

func _ready() -> void:
	print("ResourceManager initialized")
	# Start with some basic resources for testing
	add_resource("wood", 50)
	add_resource("stone", 50)
	add_resource("food", 20)

func add_resource(resource_type: String, amount: int) -> void:
	if not resources.has(resource_type):
		resources[resource_type] = 0

	resources[resource_type] += amount
	resource_changed.emit(resource_type, amount, resources[resource_type])
	print("Added %d %s (Total: %d)" % [amount, resource_type, resources[resource_type]])

func remove_resource(resource_type: String, amount: int) -> bool:
	if not has_resource(resource_type, amount):
		return false

	resources[resource_type] -= amount
	resource_changed.emit(resource_type, -amount, resources[resource_type])
	print("Removed %d %s (Total: %d)" % [amount, resource_type, resources[resource_type]])
	return true

func has_resource(resource_type: String, amount: int) -> bool:
	if not resources.has(resource_type):
		return false
	return resources[resource_type] >= amount

func get_resource_amount(resource_type: String) -> int:
	if not resources.has(resource_type):
		return 0
	return resources[resource_type]

func get_all_resources() -> Dictionary:
	return resources.duplicate()
