extends CustomPointLight2D
class_name CustomDirectionalLight2D

## the angle that the directional light covers
## around the direction it is pointing.
## 180 degrees results in full 360 coverage.
@export_range(0.1, 180, 0.1) var upper_angle: float = 30

# returns a vector containing the unit vector of 
# the direction the light is facing and directional lights upper angle
func get_directional_light_info():
	return Vector3(cos(rotation), sin(rotation), upper_angle)
