# This script provides player position to shader files.
extends Node2D

@onready var player: RigidBody2D = get_node("/root/MainScene/Player")
@onready var map_material: ShaderMaterial = ResourceLoader.load("res://Shaders/Map.tres")
@onready var mob_material: ShaderMaterial = ResourceLoader.load("res://Shaders/Mob.tres")

@onready var point_lights: Array[Node] = get_node("/root/MainScene").find_children("*", "CustomPointLight2D", true)

func get_point_light_info():
	var point_light_info: Array[Vector4] = []
	for point_light: CustomPointLight2D in point_lights:
		point_light_info.append(point_light.get_vec4())
	return point_light_info

func _ready():
	RenderingServer.global_shader_parameter_set("in_game", true)
	var num_point_lights = len(point_lights)
	
	map_material.set_shader_parameter("num_point_lights", num_point_lights)
	mob_material.set_shader_parameter("num_point_lights", num_point_lights)
	

func _process(_delta):
	# gets player's position relative to the screen
	var screen_position = get_global_transform_with_canvas() * player.global_position
	RenderingServer.global_shader_parameter_set("player_pos", screen_position)
	
	var point_light_info = get_point_light_info()
	map_material.set_shader_parameter("point_light_info", point_light_info)
	mob_material.set_shader_parameter("point_light_info", point_light_info)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position = event.position
		RenderingServer.global_shader_parameter_set("mouse_pos", mouse_position)
