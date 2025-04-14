# MainMenu.gd
extends Control

func _ready():
	show_screen("MainMenu")

func show_screen(screen_name: String) -> void:
	# Loops over all direct children and sets only the panel with name
	# "screen_name" to visible.
	for child in get_children():
		if child is Control:
			child.visible = (child.name == screen_name)

# Main Menu callbacks
func _on_Start_pressed() -> void:
	show_screen("SaveMenu")

func _on_Options_pressed() -> void:
	# Options not implemented yet.
	print("Options pressed")

func _on_Quit_pressed() -> void:
	get_tree().quit()

# Save Menu callbacks
func _on_NewGame1_pressed() -> void:
	show_screen("DemoMenu")

func _on_NewGame2_pressed() -> void:
	show_screen("DemoMenu")

func _on_NewGame3_pressed() -> void:
	show_screen("DemoMenu")

# Demo Menu callbacks
func _on_DemoLevel_pressed() -> void:
	show_screen("PreDiveMenu")

func _on_Shop_pressed() -> void:
	# Not implemented yet.
	print("Shop pressed")

func _on_Storage_pressed() -> void:
	# Not implemented yet.
	print("Storage pressed")

# Pre Dive Menu callbacks
func _on_Back_pressed() -> void:
	show_screen("DemoMenu")

func _on_Dive_pressed() -> void:
	# Replace "res://main_scene.tscn" with the path to your game scene.
	get_tree().change_scene("res://main_scene.tscn")
