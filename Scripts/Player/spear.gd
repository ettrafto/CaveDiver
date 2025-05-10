extends RigidBody2D
var speed = 1000
var is_turning = true

func _ready() -> void:
	var direction = get_global_mouse_position() - self.global_position
	rotation = direction.angle()
	linear_velocity = direction.normalized() * speed
	$ProjectileBubbles.emitting = true
		
func _physics_process(delta):
		# Apply angular velocity to rotate toward the linear velocity vectors angle
		angular_velocity = wrapf(linear_velocity.angle() - rotation, -PI, PI) * 10 * int(is_turning)

func _on_physics_collison_area_body_entered(body: Node2D) -> void:
	is_turning = false
	linear_velocity = Vector2.ZERO
	set_deferred("freeze",true)
	$ProjectileBubbles.emitting = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	print("Spear hitbox collision with, ", area.name)
	if area.name == "Hurtbox":
		print("selected new parent")
		# get the spear's position relative to the parent of the hurtbox
		var new_parent := area.get_parent()
		$Sprite2D.reparent(new_parent, true)
		print("new parent: ", get_parent().name)
		
		$PhysicsCollisionArea.monitorable = false
		$PhysicsCollisionArea.monitoring = false
		$Hitbox.monitoring = false
		$Hitbox.monitorable = false
		queue_free()
