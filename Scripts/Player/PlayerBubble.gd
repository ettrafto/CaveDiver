extends RigidBody2D

var t = 0
var stop_time = 0
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _physics_process(delta):
	if linear_velocity.y < 1:
		if t - stop_time > 2 and t > 2:
			self.queue_free()
		stop_time = t
	elif t > 10:
		self.queue_free()
	t += delta
	
	var noise_x = 150 * sin(t * 3) + (sin(t) * rng.randf_range(-150,150))
	var noise_vector = Vector2(noise_x, 0)
	self.constant_force = noise_vector
