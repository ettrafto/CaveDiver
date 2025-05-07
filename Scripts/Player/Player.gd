extends RigidBody2D

signal bcd_change

@export var sprint_multiplier: float = 1.5
@export var acceleration: float = 500.0  # How fast the player speeds up
@export var bcd_capacity: float = 50
var bubble_scene = preload("res://Things/player_bubble.tscn")
var spear_scene = preload("res://Things/spear.tscn")

# Buoyancy-related stats
# velocity input & momentum
var move_input: float
var buoyancy_input: float
var attached_to_rope: bool = false
var has_speargun: bool = true #set to false by default
var bubble_count: int = 0
var attached_to = null


@onready var hud = get_tree().get_first_node_in_group("HUD")
	
func get_resparator():
	return $resparator
	
#changes the velocity and rotation of the player
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_move(state)
	_rotate()
	_buoyancy()
	_speargun()
	
func _get_move_dir():
	move_input =  Input.get_action_strength("right") - Input.get_action_strength("left")

#handles the buoyancy calculation using constant force
func _buoyancy():
	buoyancy_input = 0.0
	buoyancy_input = Input.get_action_strength("inflate_bcd") - Input.get_action_strength("deflate_bcd")
	if buoyancy_input:
		bcd_change.emit()
		GameManager.bcd_inflation = clamp(GameManager.bcd_inflation + buoyancy_input * 0.01,0,1)
		set_constant_force(Vector2(0,-1 * (GameManager.bcd_inflation * 100) - 50) * 2)
		
func _move(state):
	_get_move_dir()
	if !move_input:
		state.apply_force(Vector2())
	else:
		var direction: Vector2
		direction.x = move_input * acceleration * (int(Input.is_action_pressed("sprint")) *  sprint_multiplier + 1)
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
			
func _speargun():
	if Input.is_action_pressed("fire_spear") and has_speargun and $spearTimer.is_stopped():
		print("firing")
		$spearTimer.start(3)
		var spear = spear_scene.instantiate()
		spear.global_position = $speargun.global_position
		add_sibling(spear)
		
		
func get_speargun_pos():
	return $speargun.global_position
	
func is_attached_to():
	if attached_to != null:
		return true
	return false
	
func set_attached_to(rope_anchor):
	attached_to = rope_anchor
	
func get_attached_to():
	return attached_to
	
func emit_bubble():
	var bubble = bubble_scene.instantiate()
	add_sibling(bubble)
	bubble.global_position = $resparator.global_position
	if bubble_count == 0:
		$bubbleParticles.emitting = true
	if bubble_count < 5:
		bubble_count += 1
		$bubbleTimer.start(.25)
	elif bubble_count >= 5:
		bubble_count = 0
		$bubbleTimer.start(10)
		

func _on_bubble_timer_timeout() -> void:
	emit_bubble()
