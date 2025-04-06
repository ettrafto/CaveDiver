# This script provides player position to shader files.
extends Node2D

@onready var player: CharacterBody2D = get_node("/root/MainScene/Player/PlayerBody")
@onready var map_material: ShaderMaterial = ResourceLoader.load("res://Shaders/Map.tres")
@onready var mob_material: ShaderMaterial = ResourceLoader.load("res://Shaders/Mob.tres")

func _ready():
	map_material.set_shader_parameter("IN_GAME", true)
	mob_material.set_shader_parameter("IN_GAME", true)

func _process(_delta):
	var screen_position = get_global_transform_with_canvas() * player.global_position
	map_material.set_shader_parameter("player_pos", screen_position)
	mob_material.set_shader_parameter("player_pos", screen_position)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position = event.position
		map_material.set_shader_parameter("mouse_pos", mouse_position)
		mob_material.set_shader_parameter("mouse_pos", mouse_position)
