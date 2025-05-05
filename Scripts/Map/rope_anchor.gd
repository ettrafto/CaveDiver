extends StaticBody2D

var rope_segment_scene = preload("res://Things/rope_segment.tscn")
var rope_segments = []
var player_attached_rope
var player = null
var can_start_rope = true
var player_rope_index = 1

func start_rope(player):
	self.player = player
	can_start_rope = false
	player.set_attached_to(self)
	
	rope_segments.append(rope_segment_scene.instantiate())
	player_attached_rope = rope_segment_scene.instantiate()
	rope_segments[0].remove_pin_joint()
	#set up the first rope segment
	self.add_child(rope_segments[0])
	$StartingJoint.node_b = rope_segments[0].get_rigidBody().get_path()
	rope_segments[0].face_towards(self, player)
	
	
	#set up the rope that will stay attached to the player
	self.add_child(player_attached_rope)
	player_attached_rope.set_pos(rope_segments[0].get_bottom_pos())
	player_attached_rope.set_pin_a(rope_segments[0].get_rigidBody().get_path())
	player_attached_rope.face_towards(rope_segments[0].get_bottom_node(), player)
	player_attached_rope.add_pin_joint(player)
	rope_segments.append(player_attached_rope)
	rope_segments[0].get_rigidBody().name = "anchor_rope"# has to be done here for some reason will break the code above if not
	
	#creates the ropes that will be rolled out
	for i in range(22):
		rope_segments.append(rope_segment_scene.instantiate())
		rope_segments[-1].active(false)
		self.add_child(rope_segments[-1])
		rope_segments[-1].set_pos(rope_segments[-2].get_bottom_pos())
		if i:
			rope_segments[-1].face_towards(rope_segments[-1], rope_segments[-2])
		else:
			rope_segments[-1].face_towards(rope_segments[-1],player.get_resparator())#first rope in the bundle has to be away from the player attached rope
		rope_segments[-1].set_pin_a(rope_segments[-2].get_rigidBody().get_path())
		if i % 2: # if I thought of this instead of trying to add and remove pin joints. SO MUCH TIME WOULDVE BEEN SAVED
			rope_segments[-1].add_pin_joint(player)
	
#extends the rope by two segments by removing the pinjoint from the current player_attached_rope
func extend():
	if player_rope_index + 2 < len(rope_segments):# checks to see if there is rope to extend
		player_attached_rope.remove_bottom_pin_joint()
		rope_segments[player_rope_index + 1].active(true)
		rope_segments[player_rope_index + 2].active(true)
		player_rope_index += 2
		player_attached_rope = rope_segments[player_rope_index]
	
#sets this anchor as inactive then connects a rope between the two and then attaches the player to next_anchor
func switch_anchors(next_anchor):
	if Vector2(player.global_position - next_anchor.global_position).length() > 80:
		extend()
	extend()
	player_attached_rope.remove_bottom_pin_joint()
	next_anchor.get_ending_joint().node_b = player_attached_rope.get_rigidBody().get_path()
	for i in range(player_rope_index + 1, len(rope_segments)):
		rope_segments[i].queue_free()
	player = null

#used to swap anchors
func get_ending_joint():
	return $EndingJoint

func detach():
	player_attached_rope.remove_bottom_pin_joint()
	for i in range(player_rope_index + 1, len(rope_segments)):
		rope_segments[i].queue_free()
	player = null
	

func _on_area_2d_body_entered(body: Node2D):
	if body.name == "Player" and player == null:
		if not body.is_attached_to() and can_start_rope:
			self.start_rope(body)
		elif body.get_attached_to() != self and can_start_rope:
			body.get_attached_to().switch_anchors(self)
			self.start_rope(body)

#controls extension activates when rope_segments[0] exits the area becuase the player is pulling on the rope
func _on_body_detection_area_body_exited(body: RigidBody2D):
	if body.name == "anchor_rope" and player != null:
		extend()
