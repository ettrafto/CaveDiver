extends RigidBody2D

var t = 0
var rng = RandomNumberGenerator.new()
var noise_magnitude
var noise_frequency

func _ready():
	rng.randomize()
	noise_magnitude = 150
	noise_frequency = 3

func _physics_process(delta):
	t += delta
	
	var noise_x = noise_magnitude * sin(t * noise_frequency) + (sin(t) * rng.randf_range(-noise_magnitude,noise_magnitude))
	var noise_vector = Vector2(noise_x, 0)
	self.constant_force = noise_vector
