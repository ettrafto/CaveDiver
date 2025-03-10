# InventoryTest.gd
extends Node2D

func _ready():
	print("Testing Inventory System...")
	
	# Create inventories for boat and person
	var boat_storage = Inventory.new(40, 20)
	var person_inventory = Inventory.new(6, 4)
	
	# Create a sample item and try adding it to the person's inventory
	var wrench = Item.new("tool", "wrench", Vector2(0, 0), 3)
	var add_success = person_inventory.add_item(wrench, Vector2(2, 1))
	
	if add_success:
		print("Test passed: wrench added to person inventory at (2,1)")
	else:
		print("Test failed: could not add wrench to person inventory")
	
	# Optionally, test moving or removing items
	var move_success = person_inventory.move_item(Vector2(2, 1), Vector2(3, 2))
	if move_success:
		print("Test passed: wrench moved to (3,2)")
	else:
		print("Test failed: could not move wrench")
		
