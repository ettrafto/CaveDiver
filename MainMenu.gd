# MainMenu.gd
extends Control

func _ready():
	# Make sure the MainMenu scene is visible
	print("MainMenu ready!")
	
	# Debug the scene tree structure
	print_scene_tree(self, 0)
	
	# Try connecting signals with direct references
	var start_button = find_child("Start", true)
	if start_button:
		print("Found Start button: ", start_button.get_path())
		start_button.connect("pressed", Callable(self, "_on_Start_pressed"))
	else:
		print("Start button not found in scene tree!")
	
	# Connect StartMenu buttons
	connect_menu_button("StartMenu", "Start", "_on_Start_pressed")
	connect_menu_button("StartMenu", "Options", "_on_Options_pressed")
	connect_menu_button("StartMenu", "Quit", "_on_Quit_pressed")
	
	# Connect SaveMenu buttons
	connect_menu_button("SaveMenu", "Save1", "_on_Save1_pressed")
	connect_menu_button("SaveMenu", "Save2", "_on_Save2_pressed")
	connect_menu_button("SaveMenu", "Save3", "_on_Save3_pressed")
	connect_menu_button("SaveMenu", "Back", "_on_Back_pressed")
	
	# Connect ShopStorageMenu buttons
	connect_menu_button("ShopStorageMenu", "Save1", "_on_Save1_pressed")
	connect_menu_button("ShopStorageMenu", "Save2", "_on_Save2_pressed")
	connect_menu_button("ShopStorageMenu", "Save3", "_on_Save3_pressed")
	connect_menu_button("ShopStorageMenu", "Back", "_on_Back2_pressed")
	
	# Show the StartMenu by default
	show_screen("StartMenu")
	
	# Add this at the end of your _ready function
	print_debug_connections()
	
	# Try a direct button hook
	for node in get_tree().get_nodes_in_group("buttons"):
		if node is Button:
			print("Adding button to input detection: " + node.name)
			node.connect("pressed", Callable(self, "_on_any_button_pressed").bind(node.name))
	
	# Show the StartMenu by default
	show_screen("StartMenu")

func connect_menu_button(menu_name: String, button_name: String, method_name: String) -> void:
	var menu = find_child(menu_name, true)
	if menu:
		var button = menu.find_child(button_name, true)
		if button:
			print("Found button: " + button.name + " in " + menu.name)
			if button.is_connected("pressed", Callable(self, method_name)):
				button.disconnect("pressed", Callable(self, method_name))
			button.connect("pressed", Callable(self, method_name))
			button.add_to_group("buttons")
		else:
			print("Button not found: " + button_name + " in " + menu_name)
	else:
		print("Menu not found: " + menu_name)

# Debug function to print scene tree
func print_scene_tree(node: Node, level: int) -> void:
	var prefix = ""
	for i in range(level):
		prefix += "  "
	print(prefix + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, level + 1)

# Catch any button press for debugging
func _on_any_button_pressed(button_name: String) -> void:
	print("Button pressed: " + button_name)

# Try a direct input handler
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Mouse clicked at: " + str(event.position))

# In MainMenu.gd, modify the show_screen function:

func show_screen(name: String) -> void:
	print("Showing screen: " + name)
	for panel in get_children():
		if panel is Control:
			# Make sure only one screen is visible at a time
			var was_visible = panel.visible
			panel.visible = (panel.name == name)
			
			# Debug state change
			if panel.visible != was_visible:
				print("Changed " + panel.name + " visibility to " + str(panel.visible))

#
# StartMenu
#
func _on_Start_pressed() -> void:
	print("Start pressed!")
	show_screen("SaveMenu")

func _on_Options_pressed() -> void:
	print("Options pressed!")

func _on_Quit_pressed() -> void:
	print("Quit pressed!")
	get_tree().quit()

#
# SaveMenu
#
func _on_Save1_pressed() -> void:
	print("Save1 pressed!")
	show_screen("ShopStorageMenu")
	
func _on_Save2_pressed() -> void:
	print("Save2 pressed!")
	show_screen("ShopStorageMenu")
	
func _on_Save3_pressed() -> void:
	print("Save3 pressed!")
	show_screen("ShopStorageMenu")
	
func _on_Back_pressed() -> void:
	print("Back pressed!")
	show_screen("StartMenu")

#
# ShopStorageMenu
#
func _on_Back2_pressed() -> void:
	print("Back2 pressed!")
	show_screen("SaveMenu")
	
	
func print_debug_connections() -> void:
	print("--- Checking signal connections ---")
	var buttons = ["Start", "Options", "Quit", "Save1", "Save2", "Save3", "Back"]
	for button_name in buttons:
		var button = find_child(button_name, true)
		if button:
			var connections = button.get_signal_connection_list("pressed")
			print(button_name + " has " + str(connections.size()) + " connections")
			for connection in connections:
				print("  Connected to: " + str(connection.callable))
		else:
			print(button_name + " not found for connection check")
	print("-------------------------------")
