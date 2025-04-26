extends Node2D

var has_two_joints = false

func set_pin_a(node_path):
	$PinJoint2D.set_node_a(node_path)
	
func set_pin_b(node_path):
	$PinJoint2D.set_node_b(node_path)

func get_rigidBody():
	return $RigidBody2D
	
func get_top_pos():
	return self.global_position
	
func get_bottom_pos():
	return $RigidBody2D/bottom_pos.global_position
	
func get_bottom_node():
	return $RigidBody2D/bottom_pos
	
func set_pos(new_position):
	self.global_position = new_position
	
func set_second_joint_pin(node_path):
		$SecondJoint.set_node_b(node_path)

# sets the bottom node position by setting the rotation towards the destiantion node
func face_towards(start, end):
	var distance = end.global_position - start.global_position #makes a vector and then aligns with it 
	self.rotation += Vector2.DOWN.angle_to(distance)#segment starts pointing down
	
func remove_pin_joint():
	remove_child($PinJoint2D)
	
func remove_bottom_pin_joint():
	if has_two_joints:
		remove_child($SeecondJoint)
		has_two_joints = false
	
func add_pin_joint(player):
	has_two_joints = true
	var new_joint = PinJoint2D.new()
	new_joint.disable_collision = true
	self.add_child(new_joint)
	new_joint.name = "SecondJoint"
	new_joint.position = get_bottom_node().position
	new_joint.node_a = self.get_rigidBody().get_path()
	new_joint.node_b = player.get_path()
