# This script provides player position to shader files.
extends Node2D

@onready var player: CharacterBody2D = get_node("/root/MainScene/Player/PlayerBody")
@onready var map_material: ShaderMaterial = ResourceLoader.load("res://Shaders/Map.tres")
@onready var mob_material: ShaderMaterial = ResourceLoader.load("res://Shaders/Mob.tres")

func _ready():
	RenderingServer.global_shader_parameter_set("in_game", true);

func _process(_delta):
	# gets player's position relative to the screen
	var screen_position = get_global_transform_with_canvas() * player.global_position
	RenderingServer.global_shader_parameter_set("player_pos", screen_position);

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position = event.position
		RenderingServer.global_shader_parameter_set("mouse_pos", mouse_position)
