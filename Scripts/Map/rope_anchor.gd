extends StaticBody2D

var rope_segment_scene = preload("res://Things/rope_segment.tscn")
var rope_segments = []
var player_attached_rope
var player = null
var can_start_rope = false
var player_rope_index = 1

func start_rope(player):
	self.player = player
	
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
	rope_segments.append(player_attached_rope)
	rope_segments[0].get_rigidBody().name = "anchor_rope"# has to be done here for some reason will break the code above if not
	
	#creates the ropes that will be rolled out
	for i in range(23):
		rope_segments.append(rope_segment_scene.instantiate())
		rope_segments[-1].disable_collision(true)
		self.add_child(rope_segments[-1])
		rope_segments[-1].set_pos(rope_segments[-2].get_bottom_pos())
		if i:
			rope_segments[-1].face_towards(rope_segments[-1], rope_segments[-2])
		else:
			rope_segments[-1].face_towards(rope_segments[-1],player.get_resparator())#first rope in the bundle has to be away from the player attached rope
		rope_segments[-1].set_pin_a(rope_segments[-2].get_rigidBody().get_path())
		if i % 2:
			rope_segments[-1].add_pin_joint(player)
	
	
func extend():
	player_attached_rope.remove_bottom_pin_joint()
	rope_segments[player_rope_index + 1].disable_collision(false)
	rope_segments[player_rope_index + 2].disable_collision(false)
	player_rope_index += 2
	player_attached_rope = rope_segments[player_rope_index]
	
func set_can_start(boolean):
	can_start_rope = boolean
	
func test():
	for i in range(player_rope_index, len(rope_segments), 2):
		print(rope_segments[i].get_bottom_pos(), rope_segments[i].get_top_pos())

func _on_area_2d_body_entered(body: Node2D):
	if body.name == "Player" and player_attached_rope == null:
		if not body.is_attached_to_rope():
			can_start_rope = true
			self.start_rope(body)

func _on_body_detection_area_body_exited(body: RigidBody2D):
	print("attempting extension")
	if body.name == "anchor_rope":
		extend()
