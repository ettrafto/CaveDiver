extends RigidBody2D


func _process(delta):
	if self.linear_velocity.length() < 5:
		$ProjectileBubbles.emitting = false

#works the same as the one found in rope_segment.gd except adds a constant force and uses the mouse as the end point
func face_towards(start):
	var distance = get_viewport().get_mouse_position() - start.global_position #makes a vector and then aligns with it 
	self.rotation += Vector2.RIGHT.angle_to(distance)#spear starts pointing right
	self.linear_velocity = distance.normalized() * 1000
	$ProjectileBubbles.emitting = true
