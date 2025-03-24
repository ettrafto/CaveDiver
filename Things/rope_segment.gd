extends Node2D

func _ready():
	pass

func set_pin(node_path):
	$PinJoint2D.set_node_a(node_path)

func get_rigidBody():
	return $RigidBody2D
