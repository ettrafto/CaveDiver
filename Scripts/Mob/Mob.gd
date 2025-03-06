extends RigidBody2D

# variables defining the basic attributes of the mob
# these can be customized per-type or per-instance to change behavior
@export var health: float = 50
@export var awareness: float = 0.6
@export var aggression = 0
@export var fear = 0
@export var impulse = 200
@export var accel = 7

# aliases for commonly referenced nodes
@onready var player = $"../Player/PlayerBody"
@onready var nav = $NavigationAgent2D
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var hurtbox = $Hurtbox/CollisionShape2D

func _ready():
	# for some reason,the hurtbox is always instantiated disabled
	# this re-enables it
	hurtbox.set_deferred("disabled", false)
	gravity_scale = 0.0
	

# this is set to false when the mob dies and is checked to enable the death effects
var alive: bool = true

# stores the direction to the next pathfinding location
# setting this as a global so that methods called from AnimationPlayer keys can access it
var movement_direction: Vector2 = Vector2.ZERO

# maximum range at which the mob can detect the player
var max_detection = 500
# current detection range based on the mob's awareness
var detection_range = max_detection * awareness

# variables for managing the sprite fadeout on death
var MAX_FADE = 0.5
var death_fade = 1.0

# shades the sprite by multiplying the RGB values of each pixel by the given factors
# used for both the death shader and camoflauge
func shade(red_factor=1, green_factor=1, blue_factor=1, alpha=1):
	sprite.material.set_shader_parameter("red_factor", red_factor)
	sprite.material.set_shader_parameter("green_factor", green_factor)
	sprite.material.set_shader_parameter("blue_factor", blue_factor)
	sprite.material.set_shader_parameter("alpha", alpha)

func die():
	alive = false
	# drift to cave floor
	gravity_scale = 0.2
	anim_player.play("Die")
	# here you can define additional behavior after death (i.e. explodes)

func approach_player(state):	
	# get player's position
	nav.target_position = player.global_position
	
	# flip sprite only on vertical axis bc rotation takes care of the horizontal flip
	if rotation > PI/2 or rotation < -PI/2:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
	
	# prevent the mob from transitioning into another animation until the current one has finished
	if anim_player.is_playing() == true and anim_player.current_animation != "Idle":
		return
	
	# persue if within aggro range
	if nav.distance_to_target() <= detection_range:
		# create a vector of length 1 pointing towards the next pathfinding point
		movement_direction = nav.get_next_path_position() - global_position
		movement_direction = movement_direction.normalized()
		anim_player.play("Swim")		
			
	# return to idle
	elif state.linear_velocity.length() != 0:
		# rotate towards 0; will be replaced with an "idle" animation & movement pattern
		rotation = clampf(rotation - rotation * accel/2.0 * state.step, min(0, rotation), max(0, rotation))
		anim_player.queue("Idle")
	
	
# Function to run every time the mob is injured
# Takes the amount of damage as an argument
func hurt(damage: float):
	#velocity = velocity/4.0
	print("Hurt")
	anim_player.play("Hurt")
	# this is required to immediately start the new animation
	# otherwise, it doesn't start soon enough to disable the hurtbox
	anim_player.advance(0)
	health -= damage

# This function is called from and Animation Key to move the mob as part of its animation	
func apply_swim_impulse() -> void:
	apply_central_impulse(movement_direction * impulse)
	var angle = rotation - movement_direction.angle()
	# -5000 seems to be about right for getting the rotation to track the player
	apply_torque_impulse(angle * -5000)

func _integrate_forces(state) -> void:
	# kills mob if health is 0
	if health <= 0 and alive:
		die()
	
	if alive:
		approach_player(state)
	# otherwise, fade out corpse and have it sink to cave floor
	else:
		# makes sprite's color slowly fade to 50% of its normal color
		if death_fade > MAX_FADE:
			death_fade = lerp(death_fade, MAX_FADE, state.step/5)
			shade(death_fade, death_fade, death_fade)
			
		if abs(rotation) > 0.001:
			rotation = clampf(rotation - rotation * accel/2 * state.step, min(0, rotation), max(0, rotation))
		else:
			rotation = 0	
	

func _on_hurtbox_area_entered(_area: Area2D) -> void:
	print("mob hurtbox entered")
	#if alive:
	hurt(1)
