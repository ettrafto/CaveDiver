extends RigidBody2D
var speed = 1000 


func _process(delta):
	if self.linear_velocity.length() < 5:
		$ProjectileBubbles.emitting = false

#works the same as the one found in rope_segment.gd except adds a constant force and uses the mouse as the end point
func face_towards_mouse():
	var distance = get_viewport().get_mouse_position() - self.global_position #makes a vector and then aligns with it 
	self.rotation += Vector2.RIGHT.angle_to(distance)#spear starts pointing right
	self.linear_velocity = distance.normalized() * speed
	$ProjectileBubbles.emitting = true

func set_speed(n):
	speed = n
