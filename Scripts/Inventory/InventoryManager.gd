# InventoryManager.gd
extends Node

var possible_items: Array = []  # All possible item definitions
var owned_equipment: Array = [] # Items that are equipped
var boat_storage: Inventory
var person_inventory: Inventory

func _ready():
	# Instantiate storage systems with given dimensions.
	boat_storage = Inventory.new(40, 20)
	person_inventory = Inventory.new(6, 4)
	
	# Example: Create a new item and add it to the person's inventory
	var new_item = Item.new("tool", "wrench", Vector2(0, 0), 3)
	if person_inventory.add_item(new_item, Vector2(0, 0)):
		print("Item added to inventory!")
		
