extends RigidBody2D

# variables defining the basic attributes of the mob
# these can be customized per-type or per-instance to change behavior
@export var health: float = 1
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
@onready var hitbox = $Hitbox/CollisionShape2D

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
	# disable hurt/hitboxes
	hurtbox.set("disabled", true)
	hitbox.set("disabled", true)
	$Hurtbox.set("monitoring", false)
	$Hurtbox.set("monitorable", false)
	$Hitbox.set("monitoring", false)
	$Hitbox.set("monitorable", false)
	# disable collision with the player and other mobs
	set_collision_mask_value(2, false) # player
	set_collision_mask_value(3, false) # mob
	set_collision_layer_value(3, false) # mob
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
		print("y: ", $Hitbox.position.x)
		$Hitbox.position.y = abs($Hitbox.position.y)
	else:
		sprite.flip_v = false
		$Hitbox.position.y = -abs($Hitbox.position.y)
	
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


func calc_impulse_for_rotation(angle) -> float:
	# to calculate the correct instantaneous torque to rotate r radians:
	# angular velocity = r/(1 - angular_damping/phys_tps)^t * phys_tps
	# because the torque is instantaneous, we can substitue angular velocity for angular acceleration
	# and calculate torque as angular velocity * moment of inertia
	var moment_of_inertia = 1.0/PhysicsServer2D.body_get_direct_state(get_rid()).inverse_inertia
	var omega = angle/4.48 * 60
	var torque = moment_of_inertia * omega
	return torque


func calc_shortest_rotation(target, current) -> float:
	var angle = target - current;
	# if angle to rotate is more than 180deg, get the shorter distance around the circle
	if abs(angle) > PI:
		# to calculate the correct direction of rotation, flip the original rotation direction
		angle = (2 * PI - abs(angle)) * -1 * sign(angle)
	return angle


# This function is called from and Animation Key to move the mob as part of its animation	
func apply_swim_impulse() -> void:
	apply_central_impulse(movement_direction * impulse)
	var angle = calc_shortest_rotation(movement_direction.angle(), rotation)
	apply_torque_impulse(calc_impulse_for_rotation(angle))
	

func apply_idle_impulse() -> void:
	print("0: ", Vector2(1, 0).angle(), ", pi: ", Vector2(-1, 0).angle(), ", rot: ", rotation)
	var rot_to_zero = calc_shortest_rotation(Vector2(1, 0).angle(), rotation)
	var rot_to_pi = calc_shortest_rotation(Vector2(-1, 0).angle(), rotation)
	print("0: ", rot_to_zero, ", pi: ", rot_to_pi)
	var angle = rot_to_zero if abs(rot_to_zero) < abs(rot_to_pi) else rot_to_pi
	print("angle: ", angle)
	apply_torque_impulse(calc_impulse_for_rotation(angle))


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
	hurt(1)
