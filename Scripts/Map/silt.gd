extends Node2D

@onready var particle_fx = $GPUParticles2D
	
func _on_area_2d_body_entered(body: RigidBody2D) -> void:
	particle_fx.emitting = true
