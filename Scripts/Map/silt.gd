extends Node2D

@onready var particle_fx = $Sprite2D/GPUParticles2D

func _ready() -> void:
	particle_fx.lifetime = 0
	
func _on_area_2d_body_entered(body: RigidBody2D) -> void:
	particle_fx.emitting = true
