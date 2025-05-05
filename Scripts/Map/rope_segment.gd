extends Node2D

var has_two_joints = false

func set_pin_a(node_path):
	$PinJoint2D.set_node_a(node_path)
	
	
func get_rigidBody():
	return $RigidBody2D
	
func get_top_pos():
	return self.global_position
	
func get_bottom_pos():
	return $RigidBody2D/BottomPos.global_position
	
func get_bottom_node():
	return $RigidBody2D/BottomPos
	
func set_pos(new_position):
	self.global_position = new_position

# sets the bottom node position by setting the rotation towards the destiantion node
func face_towards(start, end):
	var distance = end.global_position - start.global_position #makes a vector and then aligns with it 
	self.rotation += Vector2.DOWN.angle_to(distance)#segment starts pointing down
	
func remove_pin_joint():
	remove_child($PinJoint2D)
	
func remove_bottom_pin_joint():
	if has_two_joints:
		remove_child($SecondJoint)
		has_two_joints = false
	
func active(on):
	$RigidBody2D/CollisionShape2D.set_deferred("disabled",not on)
	$RigidBody2D.mass = int(on) * 0.1
	$RigidBody2D.gravity_scale = int(on) * 0.15
	if on:
		self.show()
	else:
		self.hide()
	
func add_pin_joint(player):
	has_two_joints = true
	var new_joint = PinJoint2D.new()
	self.add_child(new_joint)
	new_joint.name = "SecondJoint"
	new_joint.position = $RigidBody2D/BottomPos.position
	new_joint.node_a = $RigidBody2D.get_path()
	new_joint.node_b = player.get_path()
