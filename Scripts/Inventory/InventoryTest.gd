# InventoryTest.gd
extends Node2D

func _ready():
	print("Testing Inventory System...")
	
	var boat_storage = Inventory.new(40, 20)
	var person_inventory = Inventory.new(6, 4)
	
	var wrench = Item.new("tool", "wrench", Vector2(0, 0), 3)
	var hawk_tuah = Item.new("tool", "hawk tuah", Vector2(0, 0), 100)
	
	var add_1 = (person_inventory.add_item(wrench, Vector2(2, 1)))
	var add_2 = (person_inventory.add_item(hawk_tuah, Vector2(3, 3)))
	var add_success = add_1 and add_2
	
	if add_success:
		print("Test passed:")
		print("Wrench added to person inventory at (2,1)")
		print("Wrench added to person inventory at (3,3)")
	else:
		print("Test failed: could not add items to person inventory")
	
	var move_success = person_inventory.move_item(Vector2(2, 1), Vector2(3, 2))
	if move_success:
		print("Test passed: wrench moved to (3,2)")
	else:
		print("Test failed: could not move wrench")
		
