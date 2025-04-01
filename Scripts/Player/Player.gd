extends CharacterBody2D

signal bcd_change

@export var max_speed: float = 200.0  # Max horizontal movement speed
@export var acceleration: float = 1000.0  # How fast the player speeds up
@export var drag: float = 10  # Water resistance (slows movement)
@export var gravity: float = 9.8  # Not used much underwater but can simulate sinking

# Buoyancy-related stats
var weight: float = 12.5
var bcd_capacity: float = 25
var buoyancy: float = 0  
var depth: int = 0

# velocity input & momentum
var move_input: float
var rotate_input: float
var accelerated_vel = Vector2.ZERO
var bouyancy_input: float
var test = Vector2.ZERO

@onready var hud = get_tree().get_first_node_in_group("HUD")

#gets the input values range -1 to 1
func get_movement_input():	
	move_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	rotate_input = Input.get_axis("tilt_down","tilt_up")
	bouyancy_input = int(Input.is_action_pressed("inflate_bcd")) - int(Input.is_action_pressed("deflate_bcd"))
	
#changes the velocity and rotation of the player
func _physics_process(delta):
	get_movement_input()
	
	if bouyancy_input != 0:
		GameManager.bcd_inflation = clamp(GameManager.bcd_inflation + bouyancy_input * 0.01,0,1)
		bcd_change.emit()
	
	buoyancy = GameManager.bcd_inflation * bcd_capacity - weight
	
	if rotate_input != 0:
		rotation = clamp(rotation + 0.02 * rotate_input,-0.75,0.5)
	if move_input != 0:
		velocity += transform.x * move_input * delta * acceleration
	else:
		velocity = velocity.move_toward(Vector2.ZERO, drag)
	
	velocity.y -= buoyancy
	velocity = velocity.limit_length(max_speed)
	
	move_and_slide()
	
	# this code checks for collisions with RigidBody nodes (which will likely all be mobs)
	# and applies a force to them 
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var push_force = 1.5
			collision.get_collider().apply_central_impulse(-collision.get_normal() * push_force * velocity)
			velocity -= velocity/2			
