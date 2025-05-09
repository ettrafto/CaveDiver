# This script provides player position and other data to shader files.
extends Node2D

@onready var player: RigidBody2D = get_node("/root/MainScene/Player")
@onready var flashlight: CustomDirectionalLight2D = get_node("/root/MainScene/Player/Flashlight")

var shader_materials = []

func load_shader_materials():
	for file_name in DirAccess.get_files_at("res://Shaders/"):
		file_name = file_name.replace('.remap', '')
		if (file_name.get_extension() == "tres"):
			shader_materials.append(ResourceLoader.load("res://Shaders/" + file_name))

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

func initialize_shader_uniforms():
	
	RenderingServer.global_shader_parameter_set("in_game", true)
	
	var lights: Array[Node] = get_node("/root/MainScene").find_children("*", "CustomPointLight2D", true)
	
	for light: Node2D in lights:
		light.visible = false
		
		if light is CustomDirectionalLight2D:
			directional_lights.append(light)
		else:
			point_lights.append(light)
	
	var num_point_lights = len(point_lights)
	var num_directional_lights = len(directional_lights)
	
	for shader_material in shader_materials:
		shader_material.set_shader_parameter("num_point_lights", num_point_lights)
		shader_material.set_shader_parameter("num_directional_lights", num_directional_lights)

func update_shader_uniforms():
	# gets player's position relative to the screen
	var screen_position = get_global_transform_with_canvas() * player.global_position
	RenderingServer.global_shader_parameter_set("player_pos", screen_position)
	
	# Rotates player's flashlight to point towards the mouse
	var player_to_mouse = get_global_mouse_position() - player.global_position
	var unit_vector = player_to_mouse.normalized()
	var angle = atan2(unit_vector.y, unit_vector.x)
	flashlight.rotation = angle
	
	var point_light_info = get_light_info(point_lights)
	var directional_light_info = get_light_info(directional_lights)
	var general_light_info = point_light_info + directional_light_info
	
	var point_light_colors = get_light_colors(point_lights)
	var directional_light_colors = get_light_colors(directional_lights)
	var light_colors = point_light_colors + directional_light_colors
		
	var point_light_illu_masks = get_light_illumination_masks(point_lights)
	var directional_light_illu_masks = get_light_illumination_masks(directional_lights)
	var light_illumination_masks = point_light_illu_masks + directional_light_illu_masks
	
	directional_light_info = get_directional_light_info()
	
	for shader_material in shader_materials:
		shader_material.set_shader_parameter("general_light_info", general_light_info)
		shader_material.set_shader_parameter("general_light_colors", light_colors)
		shader_material.set_shader_parameter("light_illumination_masks", light_illumination_masks)
		shader_material.set_shader_parameter("directional_light_info", directional_light_info)

func _ready():
	load_shader_materials()
	initialize_shader_uniforms()

func _process(_delta):
	update_shader_uniforms()

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position = event.position
		RenderingServer.global_shader_parameter_set("mouse_pos", mouse_position)
