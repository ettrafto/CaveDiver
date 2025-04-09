extends Node2D

func _ready() -> void:
	$sprite/GPUParticles2D.lifetime = 0
	
func _on_area_2d_body_entered(body: RigidBody2D) -> void:
	$sprite/GPUParticles2D.emitting = true
