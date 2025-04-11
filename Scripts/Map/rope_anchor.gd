extends StaticBody2D

var rope_segment_scene = preload("res://Things/rope_segment.tscn")
var rope_segments = []
var player_attached_rope

var can_start_rope = false

func start_rope(player):
	if not player.is_attached_to_rope():
		player.set_rope_attachment(true)
		rope_segments.append(rope_segment_scene.instantiate())
		add_child(rope_segments[0])
		rope_segments[0].set_pin_a(self.get_path())
		
		for i in range(3):
			rope_segments.append(rope_segment_scene.instantiate())
			add_child(rope_segments[-1])
			rope_segments[-1].global_position = rope_segments[-2].get_bottom_node().global_position
			rope_segments[-1].set_pin_a(rope_segments[-2].get_rigidBody().get_path())
			
		player_attached_rope = rope_segment_scene.instantiate()
		add_child(player_attached_rope)
		player_attached_rope.global_position = rope_segments[-1].get_bottom_node().global_position
		player_attached_rope.set_pin_a(rope_segments[-1].get_rigidBody().get_path())
		player_attached_rope.add_pinJoint(player)
	
	
func extend_rope():
	rope_segments.append(rope_segment_scene.instantiate())
	add_child(rope_segments[-1])
	rope_segments[-1].global_position = rope_segments[-2].get_bottom_node().global_position
	rope_segments[-1].set_pin_a(rope_segments[-2].get_rigidBody().get_path())
	player_attached_rope.set_pin_a(rope_segments[-1].get_rigidBody().get_path())
	
func set_can_start(boolean):
	can_start_rope = boolean

func _on_area_2d_body_entered(body: RigidBody2D):
	if body.name == "Player":
		can_start_rope = true
		self.start_rope(body)

func _on_area_2d_body_exited(body):
	can_start_rope = false
