extends Node2D

var has_two_joints = false
var ending_anchor = null
var t = 0

func _ready() -> void:
	set_physics_process(false)
	
#used to move a segment towards the ending_anchor position 
func _physics_process(delta):
	t += delta
	#turns off _physics_process after 1 seconds
	if t > 0.5:
		set_physics_process(false)
		self.face_towards(self, ending_anchor)
		ending_anchor.get_ending_joint().node_b = $RigidBody2D.get_path()
		self.hide()
	$RigidBody2D.linear_velocity += Vector2(ending_anchor.global_position - self.global_position).normalized() * 10

func set_pin_a(node_path):
	$PinJoint2D.set_node_a(node_path)
	
func set_pos(new_position):
	self.global_position = new_position
	
func get_rigidBody():
	return $RigidBody2D
	
func get_top_pos():
	return self.global_position
	
func get_bottom_pos():
	return $RigidBody2D/BottomPos.global_position
	
func get_bottom_node():
	return $RigidBody2D/BottomPos
	
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
	
#when false the rigidBody has no mass or gravity and does not collide opposite when true
func active(on):
	$RigidBody2D/CollisionShape2D.set_deferred("disabled",not on)
	$RigidBody2D.mass = int(on) * 0.1
	$RigidBody2D.gravity_scale = int(on) * 0.15
	if on:
		self.show()
	else:
		self.hide()
	
#creates a pin joint and connects it to player
func add_pin_joint(connect_to):
	has_two_joints = true
	var new_joint = PinJoint2D.new()
	self.add_child(new_joint)
	new_joint.name = "SecondJoint"
	new_joint.position = $RigidBody2D/BottomPos.position
	new_joint.node_a = $RigidBody2D.get_path()
	new_joint.node_b = connect_to.get_path()

#turns on the physics process if ending_anchor is not null
func gravitate_towards(rope_anchor):
	ending_anchor = rope_anchor
	set_physics_process(true)
	
