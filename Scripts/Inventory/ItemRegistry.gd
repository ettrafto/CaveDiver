# Containts templates for all items in the game.
# Use new_item(item_id) to get copies of these templates.
extends Resource
class_name ItemRegistry

var _data = {
	[0]: Item.new(
		0,                      # item_id
		"Flashlight",           # name
		"A trusty flashlight.", # description
		2,                      # weight
		1,                      # curr_stack
		1,                      # max_stack
		""                      # sprite_ref
	)
}

"""
Returns a copy of item that matches item_id
"""
func new_item(item_id: int) -> Item:
	if item_id in _data:
		var item: Item = _data[item_id]
		return item.clone()
	return null
