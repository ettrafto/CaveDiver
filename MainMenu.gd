# MainMenu.gd
extends Control

func _ready():
	# Show the StartMenu by default
	show_screen("StartMenu")

func show_screen(name: String) -> void:
	for panel in get_children():
		if panel is Control:
			# Make sure only one screen is visible at a time
			var was_visible = panel.visible
			panel.visible = (panel.name == name)
			
			
# StartMenu
func _on_Start_pressed() -> void:
	show_screen("SaveMenu")

func _on_Options_pressed() -> void:
	show_screen("OptionsMenu")

func _on_Quit_pressed() -> void:
	get_tree().quit()

# SaveMenu
func _on_Save1_pressed() -> void:
	show_screen("Menu3")
	
func _on_Save2_pressed() -> void:
	show_screen("Menu3")
	
func _on_Save3_pressed() -> void:
	show_screen("Menu3")
	
func _on_Back_pressed() -> void:
	show_screen("StartMenu")

# Menu3
func _on_Play_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_scene.tscn")
	
func _on_Shop_pressed() -> void:
	show_screen("ShopMenu")
		
func _on_Storage_pressed() -> void:
	show_screen("StorageMenu")

func _on_Back2_pressed() -> void:
	show_screen("SaveMenu")
	
# ShopMenu
func _on_Back3_pressed() -> void:
	show_screen("Menu3")
	
# StorageMenu
func _on_Back4_pressed() -> void:
	show_screen("Menu3")
	
# OptionsMenu
func _on_Back5_pressed() -> void:
	show_screen("StartMenu")
