# Inventory.gd
extends Node
class_name Inventory

var grid_width: int
var grid_height: int
var grid: Array = []

func _init(width: int, height: int):
	grid_width = width
	grid_height = height
	grid.resize(grid_width)
	for x in range(grid_width):
		grid[x] = []
		grid[x].resize(grid_height)
		for y in range(grid_height):
			grid[x][y] = null  # empty slot

"""
Returns true if add was sucesful
Otherwise, returns false
"""
func add_item(item, pos: Vector2) -> bool:
	var x = int(pos.x)
	var y = int(pos.y)
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height and grid[x][y] == null:
		grid[x][y] = item
		return true
	return false

"""
Returns true if remove was sucesful
Otherwise, returns false
"""
func remove_item(pos: Vector2):
	var x = int(pos.x)
	var y = int(pos.y)
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
		var item = grid[x][y]
		grid[x][y] = null
		return item
	return null

"""
Returns true if move was sucesful
Otherwise, returns false and puts item back
"""
func move_item(from_pos: Vector2, to_pos: Vector2) -> bool:
	var item = remove_item(from_pos)
	if item and add_item(item, to_pos):
		return true
	else:
		# if move fails, put the item back
		if item:
			add_item(item, from_pos)
	return false
