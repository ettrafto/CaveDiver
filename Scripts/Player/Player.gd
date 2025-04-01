extends CharacterBody2D

signal bcd_change

@export var max_speed: float = 200.0  # Base max horizontal speed
@export var acceleration: float = 1000.0  # Base acceleration
@export var drag: float = 10  # Water resistance (slows movement)
@export var gravity: float = 9.8  # Not used much underwater but can simulate sinking

# Buoyancy-related stats
var weight: float = 12.5
var bcd_capacity: float = 25
var buoyancy: float = 0  
var depth: int = 0

# Velocity input & momentum
var move_input: float
var rotate_input: float
var accelerated_vel = Vector2.ZERO
var bouyancy_input: float
var test = Vector2.ZERO

# New: Player movement state ("idle", "normal", or "sprint")
var movement_state: String = "idle"

@onready var hud = get_tree().get_first_node_in_group("HUD")

# Gets the input values (range -1 to 1)
func get_movement_input():	
	move_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	rotate_input = Input.get_axis("tilt_down", "tilt_up")
	bouyancy_input = int(Input.is_action_pressed("inflate_bcd")) - int(Input.is_action_pressed("deflate_bcd"))

# Updates the movement_state based on input, velocity, and sprint key
func update_movement_state():
	var sprint_pressed = Input.is_action_pressed("sprint")
	# If sprint is pressed and there's horizontal movement, set state to "sprint"
	if move_input != 0 and sprint_pressed:
		movement_state = "sprint"
	# If the player is barely moving, set state to "idle"
	elif velocity.length() < 10.0:
		movement_state = "idle"
	else:
		movement_state = "normal"
		
	# Debug: print current movement state and velocity
	print("Player movement_state:", movement_state, " | Velocity:", velocity)
	# Update GameManager for global access (ensure GameManager has a 'movement_state' property)
	GameManager.movement_state = movement_state

func _physics_process(delta: float) -> void:
	get_movement_input()
	
	if bouyancy_input != 0:
		GameManager.bcd_inflation = clamp(GameManager.bcd_inflation + bouyancy_input * 0.01, 0, 1)
		bcd_change.emit()
	
	buoyancy = GameManager.bcd_inflation * bcd_capacity - weight
	
	if rotate_input != 0:
		rotation = clamp(rotation + 0.02 * rotate_input, -0.75, 0.5)
	
	# Determine sprint multiplier: 2x if sprint is pressed while moving
	var sprint_multiplier: float = 1.0
	if move_input != 0 and Input.is_action_pressed("sprint"):
		sprint_multiplier = 2.0
	
	# Apply horizontal movement with sprint multiplier applied to acceleration
	if move_input != 0:
		velocity += transform.x * move_input * delta * acceleration * sprint_multiplier
	else:
		velocity = velocity.move_toward(Vector2.ZERO, drag)
	
	velocity.y -= buoyancy
	
	# Update max speed based on movement state; double it if sprinting.
	var current_max_speed = max_speed
	if movement_state == "sprint":
		current_max_speed = max_speed * 2
	
	velocity = velocity.limit_length(current_max_speed)
	
	move_and_slide()
	
	# Apply push forces on collided RigidBody nodes
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var push_force = 1.5
			collision.get_collider().apply_central_impulse(-collision.get_normal() * push_force * velocity)
			velocity -= velocity / 2
	
	# Update movement state (for oxygen consumption and debugging)
	update_movement_state()
