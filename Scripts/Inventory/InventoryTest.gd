# InventoryTest.gd
extends Node2D


"""
Tests default add_item (no passed pos; put item in first available spot)
"""
func test_one():
	var passed = false
	
	var inventory = Inventory.new(4, 6)
	
	var wrench = Item.new("tool", "wrench", 3)
	var axe = Item.new("tool", "axe", 5)
	
	inventory.add_item(wrench)
	inventory.add_item(axe)
	
	var item1 = inventory.get_item(Vector2(0, 0))
	var item2 = inventory.get_item(Vector2(1, 0))
		
	passed = (wrench == item1 and axe == item2)
	
	if passed:
		print("PASSED test case one")
	else:
		print("FAILED test case one")

"""
Tests usage of default add_item param along with calls using passed positions
"""
func test_two():
	var passed = false
	
	var inventory = Inventory.new(4, 6)
	
	var wrench = Item.new("tool", "wrench", 3)
	var flashlight = Item.new("tool", "flashlight", 2)
	var axe = Item.new("tool", "axe", 5)
	
	inventory.add_item(wrench)
	# add it to position (3, 0) in inventory
	inventory.add_item(flashlight, Vector2(3, 0))
	inventory.add_item(axe)
	
	var item1 = inventory.get_item(Vector2(0, 0))
	var item2 = inventory.get_item(Vector2(1, 0))
	var item3 = inventory.get_item(Vector2(3, 0))
	
	passed = (wrench == item1 and axe == item2 and flashlight == item3)
	
	if passed:
		print("PASSED test case two")
	else:
		print("FAILED test case two")

"""Tests functions for passed out of bounds positions"""
func test_three():
	var passed = false
	
	var inventory = Inventory.new(4, 6)
	
	var wrench = Item.new("tool", "wrench", 3)
	
	var res1 = inventory.add_item(wrench, Vector2(100, 100))
	var res2 = inventory.set_item(wrench, Vector2(100, 100))
	var res3 = inventory.move_item(Vector2(100, 100), Vector2(0, 1))
	passed = not (res1 or res2 or res3)
	
	if passed:
		print("PASSED test case three")
	else:
		print("FAILED test case three")

"""Tests get_total_weight method"""
func test_four():
	var passed = true
	
	var inventory = Inventory.new(4, 6)
	
	var wrench = Item.new("tool", "wrench", 3)
	
	if inventory.get_total_weight() != 0:
		passed = false
	
	inventory.add_item(wrench)
	
	if inventory.get_total_weight() != 3:
		passed = false
	
	if passed:
		print("PASSED test case four")
	else:
		print("FAILED test case four")

"""Tests set_item overwriting existing items"""
func test_five():
	var passed = true
	
	var inventory = Inventory.new(4, 6)
	
	var wrench = Item.new("tool", "wrench", 3)
	var axe = Item.new("tool", "axe", 5)
	
	inventory.set_item(wrench, Vector2(0, 0))
	
	var item = inventory.get_item(Vector2(0, 0))
	
	if wrench != item:
		passed = false
	
	inventory.set_item(axe, Vector2(0, 0))
	
	item = inventory.get_item(Vector2(0, 0))
	
	if axe != item:
		passed = false
	
	if passed:
		print("PASSED test case five")
	else:
		print("FAILED test case five")

"""Tests remove_item"""
func test_six():
	var passed = true
	
	var inventory = Inventory.new(4, 6)
	
	var axe = Item.new("tool", "axe", 5)
	
	inventory.set_item(axe, Vector2(0, 0))
	
	var item = inventory.remove_item(Vector2(0, 0))
		
	if axe != item or inventory.get_total_weight() != 0:
		passed = false
	
	if passed:
		print("PASSED test case six")
	else:
		print("FAILED test case six")

"""Tests move_item"""
func test_seven():
	var passed = true
	
	var inventory = Inventory.new(4, 6)
	
	var axe = Item.new("tool", "axe", 5)
	
	inventory.set_item(axe, Vector2(0, 0))
	inventory.move_item(Vector2(0, 0), Vector2(2, 3))
	
	var item1 = inventory.get_item(Vector2(0, 0))
	
	if item1 != null:
		passed = false
	
	var item2 = inventory.get_item(Vector2(2, 3))
	
	if axe != item2:
		passed = false
	
	if passed:
		print("PASSED test case seven")
	else:
		print("FAILED test case seven")

"""Tests swap_item"""
func test_eight():
	var passed = true
	
	var inventory = Inventory.new(4, 6)
	
	var wrench = Item.new("tool", "wrench", 3)
	var axe = Item.new("tool", "axe", 5)
	
	var pos1 = Vector2(2, 3)
	var pos2 = Vector2(5, 2)

	inventory.set_item(wrench, pos1)
	inventory.set_item(axe, pos2)
	
	inventory.swap_item(pos1, pos2)
	
	var item1 = inventory.get_item(pos1)
	var item2 = inventory.get_item(pos2)
	
	if item1 != axe or item2 != wrench:
		passed = false
	
	if passed:
		print("PASSED test case eight")
	else:
		print("FAILED test case eight")

func _ready():
	print("Testing Inventory System...")
	test_one()
	test_two()
	test_three()
	test_four()
	test_five()
	test_six()
	test_seven()
	test_eight()
