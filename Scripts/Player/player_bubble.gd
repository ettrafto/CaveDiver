extends RigidBody2D

var t = 0
var stop_time = 0
var rng = RandomNumberGenerator.new()
var noise_magnitude
var noise_frequency

func _ready():
	rng.randomize()
	noise_magnitude = 150
	noise_frequency = 3

func _physics_process(delta):
	if linear_velocity.y < 1:
		if t - stop_time > 2 and t > 2:
			self.queue_free()
		stop_time = t
	elif t > 10:
		self.queue_free()
	t += delta
	
	var noise_x = noise_magnitude * sin(t * noise_frequency) + (sin(t) * rng.randf_range(-noise_magnitude,noise_magnitude))
	var noise_vector = Vector2(noise_x, 0)
	self.constant_force = noise_vector
