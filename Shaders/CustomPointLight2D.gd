extends Node2D
class_name CustomPointLight2D

## point light's effective distance (radially)
@export_range(1, 1000, 1) var distance: float = 100.0
## increases brightness of light
@export_range(0, 10, 0.01) var intensity: float = 1.0

@export_flags("General", "Player Emitted", "Mob Emitted", "Misc") var illumination_mask = 1

@export_category("Color")
## red offset
@export_range(0, 1, 0.01) var red: float = 0
## green offset
@export_range(0, 1, 0.01) var green: float = 0
## blue offset
@export_range(0, 1, 0.01) var blue: float = 0

@export_category("Oscillation")
## toggles whether the light's intensity will oscillate
@export var oscillates: bool = false
## frequency of oscillation in degrees
@export_range(1, 360, 1) var frequency: int = 1
## phase offset of oscillation in degrees
@export var offset: int = 0
var time: float = 0

func _process(delta):
	time += delta

func get_vec4():
	var screen_position = get_canvas_transform() * global_position
	if (oscillates):
		var oscillation = (cos(time * deg_to_rad(frequency) + deg_to_rad(offset)) + 1) / 2
		var new_intensity = intensity * oscillation
		return Vector4(screen_position.x, screen_position.y, distance, new_intensity)
	else:
		return Vector4(screen_position.x, screen_position.y, distance, intensity)

func get_RGB():
	return Vector3(red, green, blue)

func get_illumination_mask():
	return illumination_mask
