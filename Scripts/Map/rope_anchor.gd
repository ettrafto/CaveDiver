extends StaticBody2D

var rope_segment_scene = preload("res://Things/rope_segment.tscn")
var rope_segments = []
var player_attached_rope
var attached_player = null
var can_start_rope = false

func start_rope(player):
	attached_player = player
	
	rope_segments.append(rope_segment_scene.instantiate())
	player_attached_rope = rope_segment_scene.instantiate()
	rope_segments[0].remove_pin_joint()
	#set up the first rope segment
	self.add_child(rope_segments[0])
	$DampedSpringJoint2D.node_b = rope_segments[0].get_rigidBody().get_path()
	rope_segments[0].face_towards(self, player)
	
	#set up the rope that will stay attached to the player
	self.add_child(player_attached_rope)
	player_attached_rope.set_pos(rope_segments[0].get_bottom_pos())
	player_attached_rope.set_pin_a(rope_segments[0].get_rigidBody().get_path())
	player_attached_rope.face_towards(rope_segments[0].get_bottom_node(), player)
	player_attached_rope.add_pin_joint(player)
	
	
func extend_rope():
	rope_segments.append(rope_segment_scene.instantiate())
	add_child(rope_segments[-1])
	rope_segments[-1].global_position = rope_segments[-2].get_bottom_node().global_position
	rope_segments[-1].set_pin_a(rope_segments[-2].get_rigidBody().get_path())
	player_attached_rope.set_pin_a(rope_segments[-1].get_rigidBody().get_path())
	
func set_can_start(boolean):
	can_start_rope = boolean

func _on_area_2d_body_entered(body: Node2D):
	if body.name == "Player" and player_attached_rope == null:
		if not body.is_attached_to_rope():
			can_start_rope = true
			self.start_rope(body)

func _on_body_detection_area_body_exited(body: RigidBody2D):
	if len(rope_segments) > 2:
		extend_rope()
		
