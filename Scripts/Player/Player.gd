extends RigidBody2D

signal bcd_change
signal place_rope

@export var max_speed: float = 200.0  # Max horizontal movement speed
@export var acceleration: float = 500.0  # How fast the player speeds up
@export var drag: float = 10  # Water resistance (slows movement)
@export var bcd_capacity: float = 50
@onready var move_force = Vector2(200,0)

# Buoyancy-related stats
# velocity input & momentum
var move_input: float
var rotate_input: float
var buoyancy_input: float
var attached_to_rope: bool = false


@onready var hud = get_tree().get_first_node_in_group("HUD")

func _ready() -> void:
	set_inertia(1)
	set_constant_force(Vector2(0,25))
#changes the velocity and rotation of the player
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_move(state)
	_rotate()
	_buoyancy()
	
func _get_move_dir():
	return Input.get_action_strength("right") - Input.get_action_strength("left")

#handles the buoyancy calculation using constant force
func _buoyancy():
	buoyancy_input = 0.0
	buoyancy_input = Input.get_action_strength("inflate_bcd") - Input.get_action_strength("deflate_bcd")
	if buoyancy_input:
		bcd_change.emit()
		GameManager.bcd_inflation = clamp(GameManager.bcd_inflation + buoyancy_input * 0.01,0,100)
		set_constant_force(Vector2(0,-1 * GameManager.bcd_inflation * 100))
		

func _move(state):
	var input = _get_move_dir()
	if !input:
		state.apply_force(Vector2())
	else:
		var direction: Vector2
		direction.x = input * acceleration   
		state.apply_force(direction.rotated(rotation))
		
	
func _get_rotation_dir():
	return Input.get_action_strength("tilt_up") - Input.get_action_strength("tilt_down")

func _rotate():
	if rotation > -1 and rotation < 0.33:
		rotation += _get_rotation_dir() * 0.05
	else:
		var input: float = _get_rotation_dir() * 0.05
		if rotation >= 0.33 and input < 0:
			rotation += input
		elif rotation <= -1 and input > 0:
			rotation += input
		
func _misc_input():
	return Input.get_action_strength("rope")
	
func set_rope_attachment(boolean):
	attached_to_rope = boolean
	
func is_attached_to_rope():
	return attached_to_rope
	
	
	
	
