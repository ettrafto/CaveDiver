extends StaticBody2D

var rope_segment_scene = preload("res://Things/rope_segment.tscn")
var rope_segments = []

func start_rope(player):
	for i in range(3):
		rope_segments.append(rope_segment_scene.instantiate())
	rope_segments[0].set_pin($".")
	rope_segments[1].set_pin(rope_segments[0])
	rope_segments[2].set_pin(rope_segments[1])
		
func extend_rope():
	var rope_segment = rope_segment_scene.instantiate()
	rope_segments.append(rope_segment)
	rope_segments[len(rope_segments)-1].set_pin(rope_segments[len(rope_segments)-2].get_rigidBody())
