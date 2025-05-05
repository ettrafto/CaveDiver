# This script provides player position and other data to shader files.
extends Node2D

@onready var player: RigidBody2D = get_node("/root/MainScene/Player")
@onready var map_material: ShaderMaterial = ResourceLoader.load("res://Shaders/Map.tres")
@onready var mob_material: ShaderMaterial = ResourceLoader.load("res://Shaders/Mob.tres")

var point_lights: Array[Node]
var directional_lights: Array[Node]

func get_light_info(lights: Array[Node]):
	var light_info: Array[Vector4] = []
	for light: CustomPointLight2D in lights:
		light_info.append(light.get_vec4())
	return light_info

func get_light_colors(lights: Array[Node]):
	var light_colors: Array[Vector3] = []
	for light: CustomPointLight2D in lights:
		light_colors.append(light.get_RGB())
	return light_colors

func get_light_illumination_masks(lights: Array[Node]):
	var light_masks: Array[int] = []
	for light: CustomPointLight2D in lights:
		light_masks.append(light.get_illumination_mask())
	return light_masks

func get_directional_light_info():
	var directional_light_info: Array[Vector3] = []
	for light: CustomDirectionalLight2D in directional_lights:
		directional_light_info.append(light.get_directional_light_info())
	return directional_light_info

func _ready():
	RenderingServer.global_shader_parameter_set("in_game", true)
	
	var lights: Array[Node] = get_node("/root/MainScene").find_children("*", "CustomPointLight2D", true)
	
	for light: Node2D in lights:
		light.visible = false
		
		if light is CustomDirectionalLight2D:
			directional_lights.append(light)
		else:
			point_lights.append(light)
	
	var num_point_lights = len(point_lights)
	map_material.set_shader_parameter("num_point_lights", num_point_lights)
	mob_material.set_shader_parameter("num_point_lights", num_point_lights)

	var num_directional_lights = len(directional_lights)
	map_material.set_shader_parameter("num_directional_lights", num_directional_lights)
	mob_material.set_shader_parameter("num_directional_lights", num_directional_lights)

func _process(_delta):
	# gets player's position relative to the screen
	var screen_position = get_global_transform_with_canvas() * player.global_position
	RenderingServer.global_shader_parameter_set("player_pos", screen_position)
	
	var point_light_info = get_light_info(point_lights)
	var directional_light_info = get_light_info(directional_lights)
	var general_light_info = point_light_info + directional_light_info
	map_material.set_shader_parameter("general_light_info", general_light_info)
	mob_material.set_shader_parameter("general_light_info", general_light_info)
	
	var point_light_colors = get_light_colors(point_lights)
	var directional_light_colors = get_light_colors(directional_lights)
	var light_colors = point_light_colors + directional_light_colors
	
	map_material.set_shader_parameter("general_light_colors", light_colors)
	mob_material.set_shader_parameter("general_light_colors", light_colors)
	
	var point_light_illu_masks = get_light_illumination_masks(point_lights)
	var directional_light_illu_masks = get_light_illumination_masks(directional_lights)
	var light_illumination_masks = point_light_illu_masks + directional_light_illu_masks
	map_material.set_shader_parameter("light_illumination_masks", light_illumination_masks)
	mob_material.set_shader_parameter("light_illumination_masks", light_illumination_masks)
	
	directional_light_info = get_directional_light_info()
	map_material.set_shader_parameter("directional_light_info", directional_light_info)
	mob_material.set_shader_parameter("directional_light_info", directional_light_info)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position = event.position
		RenderingServer.global_shader_parameter_set("mouse_pos", mouse_position)
