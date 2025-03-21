extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("here fucker")
	var child = get_node("sprite/GPUParticles2D")
	child.emitting = true
