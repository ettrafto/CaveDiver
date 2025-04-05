# Item.gd
extends RefCounted # used for auto memory mgmt
class_name Item

var item_id: int
var name: String
var description: String
var weight: int
var curr_stack: int
var max_stack: int
var sprite_ref: String

func _init(_item_id: int, _name: String, _description: String, _weight: int, 
		   _curr_stack: int, _max_stack: int, _sprite_ref: String):
	item_id = _item_id
	name = _name
	description = _description
	weight = _weight
	curr_stack = _curr_stack
	max_stack = _max_stack
	assert(curr_stack <= max_stack)
	sprite_ref = _sprite_ref

#region Getters
func get_item_id() -> int:
	return item_id

func get_name() -> String:
	return name

func get_description() -> String:
	return description

func get_weight() -> int:
	return weight * curr_stack

func get_curr_stack() -> int:
	return curr_stack

func get_sprite_ref() -> String:
	return sprite_ref
#endregion

"""
Adds count to curr_stack
Returns unadded count
"""
func add(count: int) -> int:
	assert(count >= 0)
	
	curr_stack += count
	
	if curr_stack > max_stack:
		var leftover = curr_stack - max_stack
		curr_stack = max_stack
		return leftover
		
	return 0

"""
Removes count from curr_stack
Returns unsubtracted count
"""
func remove(count: int) -> int:
	assert(count >= 0)
	
	if count > curr_stack:
		var remainder = count - curr_stack
		curr_stack = 0
		return count
	
	curr_stack -= count
	return 0

func is_empty() -> bool:
	return curr_stack == 0

func clone() -> Item:
	return Item.new(item_id, name, description, weight, 
					curr_stack, max_stack, sprite_ref)
