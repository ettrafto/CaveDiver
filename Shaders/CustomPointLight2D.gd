extends Node2D
class_name CustomPointLight2D

# radius of the point light's effectiveness in pixels
@export var radius: float = 100.0
# lighting multiplier of RGB components
@export var intensity: float = 1.0

func get_vec4():
	var screen_position = get_canvas_transform() * global_position
	return Vector4(screen_position.x, screen_position.y, radius, intensity)
