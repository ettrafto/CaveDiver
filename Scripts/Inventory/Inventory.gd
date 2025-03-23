# Inventory.gd
extends Node
class_name Inventory

var num_columns: int
var num_rows: int
var grid: Array = []

func _init(rows: int, columns: int):
	num_rows = rows
	num_columns = columns
	grid.resize(num_rows)
	
	var grid_row = []
	grid_row.resize(num_columns)
	grid_row.fill(null)
	
	for row in range(num_rows):
		grid[row] = grid_row.duplicate(true)

"""
Returns true if pos in grid bounds
Otherwise, prints message and returns false 
"""
func _valid_pos(pos: Vector2) -> bool:
	var row = int(pos.y)
	var col = int(pos.x)
	
	if col >= 0 and col < num_columns and row >= 0 and row < num_rows:
		return true
	
	print("Position out of bounds: [%d, %d]" % [col, row])
	return false

"""
Sets value at pos to item
Returns true if set was sucessful
Otherwise, returns false
"""
func set_item(item, pos: Vector2) -> bool:
	if not _valid_pos(pos):
		return false
	
	var row = int(pos.y)
	var col = int(pos.x)
	
	grid[row][col] = item
	return true

"""
Sets value at pos to item if pos isn't occupied
Returns true if add was sucessful
Otherwise, returns false
"""
func add_item(item, pos: Vector2 = Vector2(-1, -1)) -> bool:
	# Vector2(-1, -1) is a sentinel value
	# Item will be put in first available spot
	if pos == Vector2(-1, -1):
		for row in range(num_rows):
			for col in range(num_columns):
				if grid[row][col] == null:
					grid[row][col] = item
					return true
		
		# No available spots
		return false
	
	if not _valid_pos(pos):
		return false
	
	var row = int(pos.y)
	var col = int(pos.x)
	
	if grid[row][col] == null:
		grid[row][col] = item
		return true
		
	return false

"""
Returns item if remove was sucessful
Otherwise, returns null
"""
func remove_item(pos: Vector2) -> Item:
	if not _valid_pos(pos):
		return null
	
	var row = int(pos.y)
	var col = int(pos.x)
	
	var item = grid[row][col]
	grid[row][col] = null
	
	if item == null:
		print("No item at: [%d, %d]" % [col, row])
	
	return item

"""
Returns item ref at passed position
Otherwise, returns null
"""
func get_item(pos: Vector2) -> Item:
	if not _valid_pos(pos):
		return null

	var row = int(pos.y)
	var col = int(pos.x)
	
	var item = grid[row][col]
	return item

"""
Returns true if move was sucsessful
Otherwise, returns false and puts item back
"""
func move_item(from_pos: Vector2, to_pos: Vector2) -> bool:
	var item = get_item(from_pos)
	
	# not null
	if item:
		# added successfully
		if add_item(item, to_pos):
			return set_item(null, from_pos)
	
	return false

"""
Swaps items at pos1 and pos2
Returns true if swap was sucsessful
Otherwise, returns false
"""
func swap_item(pos1: Vector2, pos2: Vector2) -> bool:
	if not (_valid_pos(pos1) and _valid_pos(pos2)):
		return false
	
	var item1 = get_item(pos1)
	var item2 = get_item(pos2)

	set_item(item1, pos2)
	set_item(item2, pos1)
	
	return true

"""
Returns total weight of inventory
"""
func get_total_weight() -> int:
	var total_weight = 0
	
	for row in range(num_rows):
		for col in range(num_columns):
			var item = grid[row][col]
			if item:
				total_weight += item.weight
	
	return total_weight
