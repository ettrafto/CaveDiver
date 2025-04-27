# MainMenu.gd
extends Control

func _ready():
	# let clicks fall through all menus to their Buttons
	mouse_filter = MOUSE_FILTER_IGNORE
	for panel in get_children():
		if panel is Control:
			panel.mouse_filter = MOUSE_FILTER_IGNORE

	show_screen("StartMenu")

func show_screen(screen_name: String) -> void:
	for panel in get_children():
		if panel is Control:
			panel.visible = (panel.name == screen_name)

#
# StartMenu
#
func _on_Start_pressed() -> void:
	print("🎉 Start pressed!")
	show_screen("SaveMenu")

func _on_Options_pressed() -> void:
	print("Options not hooked up yet")

func _on_Quit_pressed() -> void:
	get_tree().quit()

#
# SaveMenu
#
func _on_Save1_pressed() -> void:
	show_screen("ShopStorageMenu")
func _on_Save2_pressed() -> void:
	show_screen("ShopStorageMenu")
func _on_Save3_pressed() -> void:
	show_screen("ShopStorageMenu")
func _on_Back_pressed() -> void:
	show_screen("StartMenu")

#
# ShopStorageMenu
#
func _on_DemoLevel_pressed() -> void:
	show_screen("PrediveMenu")
func _on_Shop_pressed() -> void:
	# TODO: your shop logic
	pass
func _on_Storage_pressed() -> void:
	# TODO: your storage logic
	pass
func _on_Back2_pressed() -> void:
	show_screen("SaveMenu")

#
# PrediveMenu
#
func _on_Dive_pressed() -> void:
	get_tree().change_scene("res://main_scene.tscn")
func _on_Back3_pressed() -> void:
	show_screen("ShopStorageMenu")
