extends Node2D

var has_two_joints = false

func _ready():
	$PinJoint2D.disable_collision = true

func set_pin_a(node_path):
	$PinJoint2D.set_node_a(node_path)
	
func set_pin_b(node_path):
	$PinJoint2D.set_node_b(node_path)

func get_rigidBody():
	return $RigidBody2D
	
func get_top_pos():
	return self.position
	
func get_bottom_node():
	return $RigidBody2D/bottom_pos
	
func set_pos(new_position):
	self.position = new_position
	
func set_second_joint_pin(node_path):
		$SecondJoint.set_node_b(node_path)

# this function is meant to be used once both pins are set
func set_bottom_pos(node):
	pass
	
	
func remove_pin():
	remove_child($PinJoint2D)
	
	
func add_pinJoint(player):
	has_two_joints = true
	var new_joint = PinJoint2D.new()
	new_joint.disable_collision = true
	self.add_child(new_joint)
	new_joint.name = "SecondJoint"
	new_joint.position = get_bottom_node().position
	new_joint.node_a = self.get_rigidBody().get_path()
	player.global_position = $RigidBody2D/bottom_pos.global_position
	new_joint.node_b = player.get_path()
