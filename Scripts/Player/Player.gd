extends CharacterBody2D

@export var max_speed: float = 200.0  # Max horizontal movement speed
@export var acceleration: float = 1000.0  # How fast the player speeds up
@export var drag: float = 100.0  # Water resistance (slows movement)
@export var gravity: float = 9.8  # Not used much underwater but can simulate sinking

# Buoyancy-related stats
var weight: float = 1
var bcd_capacity: float = 1
var bcd_inflation: float = 1
var buoyancy: float = 0  
var depth: int = 0
var kick_cooldown

# velocity input & momentum
var input = Vector2.ZERO

@onready var hud = get_tree().get_first_node_in_group("HUD")

func get_movement_input():
	print($Timer.time_left)
	if $Timer.time_left == 0:
		input.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		$Timer.start()
	input.y = int(Input.is_action_pressed("deflate_bcd")) - int(Input.is_action_pressed("inflate_bcd"))
	return input.normalized()
	

func _physics_process(delta):
	var start_velocity := velocity
	input = get_movement_input()
	var accelerated_velocity = Vector2.ZERO
	
	
	if input == Vector2.ZERO:
		if velocity.length() > (delta * drag):
			if velocity.x > 0:
				accelerated_velocity = start_velocity + Vector2(-drag * delta,0)
			else:
				accelerated_velocity = start_velocity + Vector2(drag * delta,0)
			velocity = (start_velocity + accelerated_velocity)/2
		else:
			velocity = Vector2.ZERO
	else:
		accelerated_velocity = start_velocity + (acceleration * input * delta)
		velocity = (start_velocity + accelerated_velocity)/2
		velocity = velocity.limit_length(max_speed)
	
	
	
	move_and_slide()

func inflate_bcd(amount: float):
	"""Increase BCD inflation"""
	bcd_inflation = clamp(bcd_inflation + amount, 0, 10)
	if hud:
		hud.update_weight_and_bcd()

func deflate_bcd(amount: float):
	"""Decrease BCD inflation"""
	bcd_inflation = clamp(bcd_inflation - amount, 0, 10)
	if hud:
		hud.update_weight_and_bcd()
	


func _on_timer_timeout() -> void:
	$Timer.stop()
	print($Timer.time_left)
	pass # Replace with function body.
