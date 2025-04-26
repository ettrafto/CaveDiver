extends RigidBody2D

# variables defining the basic attributes of the mob
# these can be customized per-type or per-instance to change behavior
@export var health: float = 1
@export var awareness: float = 0.1
@export var aggression = 0
@export var fear = 0
@export var impulse = 200
@export var accel = 7

@export_category("Illumination")
## The illumination mask is used to determine 
## which custom light layers illuminate a mob.
@export_flags("General", "Player Emitted", "Mob Emitted", "Misc") var illumination_mask = 7:
	set(new_mask):
		await self.ready
		illumination_mask = new_mask
		sprite.set_instance_shader_parameter("illumination_mask", new_mask)

## Makes it so a mob is more transparent the less visible it is.
## Eases the transition for when a mob is in the presence of a light that it
## doesn't share a layer with while it's also currently being illuminated 
## by a light it shares a layer with.
@export var soft_illumination_cutoff: bool = false:
	set(new_value):
		await self.ready
		soft_illumination_cutoff = new_value
		sprite.set_instance_shader_parameter("soft_illumination_cutoff", new_value)

# aliases for commonly referenced nodes
@onready var player = $"../Player"
@onready var nav_agent = $NavigationAgent2D
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var hurtbox = $Hurtbox/CollisionShape2D
@onready var hitbox = $Hitbox/CollisionShape2D
@onready var corpse_box = $CorpseCollisionShape2D

# maybe update this to more explicity reference the correct nav region
@onready var nav_region = $"../Map/NavigationRegion2D"

# variables for map and region used for getting random points 
# in a NavigationRegion
var map: RID = NavigationServer2D.map_create()
var region: RID = NavigationServer2D.region_create()

func setup_nav_server():
	NavigationServer2D.map_set_active(map, true)
	NavigationServer2D.region_set_transform(region, Transform2D())
	NavigationServer2D.region_set_map(region, map)
	NavigationServer2D.region_set_navigation_polygon(region, nav_region.navigation_polygon)
	nav_agent.target_desired_distance = 25
	
	
func _ready():
	setup_nav_server()
	# for some reason,the hurtbox is always instantiated disabled
	# this re-enables it
	hurtbox.set_deferred("disabled", false)
	gravity_scale = 0.0

# this is set to false when the mob dies and is checked to enable the death effects
var alive: bool = true

# stores the direction to the next pathfinding location
# setting this as a global so that methods called from AnimationPlayer keys can access it
var movement_direction: Vector2 = Vector2.ZERO

# enum of possible behavoirs
enum Behaviors {CHASE, FLEE, WANDER, PATROL, IDLE}

var current_behavior = Behaviors.IDLE

# keeps track of whether the mob has reached its current navigation target
var reached_nav_target: bool = false

# maximum range at which the mob can detect the player
var max_detection = 500
# current detection range based on the mob's awareness
var detection_range = max_detection * awareness

# variables for managing the sprite fadeout on death
var MAX_FADE = 0.4
var death_fade = 1.0

# shades the sprite by multiplying the RGB values of each pixel by the given factors
# used for both the death shader and camoflauge
func shade(red_factor: float = 1.0, green_factor: float = 1.0,
		   blue_factor: float = 1.0, alpha: float = 1.0):
	# note: made it so the sprite uses its parents material (Mob node)
	sprite.set_instance_shader_parameter("red_factor", red_factor)
	sprite.set_instance_shader_parameter("green_factor", green_factor)
	sprite.set_instance_shader_parameter("blue_factor", blue_factor)
	sprite.set_instance_shader_parameter("alpha", alpha)


func die():
	alive = false
	# disable hurt/hitboxes
	hurtbox.set_deferred("disabled", true)
	hitbox.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitorable", false)
	$Hitbox.set_deferred("monitoring", false)
	$Hitbox.set_deferred("monitorable", false)
	# disable regular collision shape & replace with collision shape that matches corpes
	$CollisionShape2D.set_deferred('disabled', true)
	corpse_box.set_deferred('disabled', false)
	# disable collision with the player and other mobs
	set_collision_mask_value(2, false) # player
	set_collision_mask_value(3, false) # mob
	set_collision_layer_value(3, false) # mob
	# drift to cave floor
	gravity_scale = 0.2
	anim_player.play("Die")
	# here you can define additional behavior after death (i.e. explodes)


func get_random_nav_position(min_distance: float, max_radius: float):
	var angle := randf_range(0, 2*PI)
	var distance := randf_range(min_distance, max_radius)
	var target_position = Vector2(0,0)
	target_position.x = cos(angle) *  distance
	target_position.y = sin(angle) * distance
	# the random position is generated relative to the mob, so add the mob's position
	# to the target position to make it relative to the scene
	target_position += get_position()
	# get the closest point in the nav region to the chosen point (prevents mob trying top path out of map)
	return NavigationServer2D.map_get_closest_point(map, target_position)


# this function rotates the sprite icon to match the actual heading of the mob
func update_sprite_rotation() -> void:
	# flip sprite only on vertical axis bc rotation takes care of the horizontal flip
	if rotation > PI/2 or rotation < -PI/2:
		sprite.flip_v = true
		$Hitbox.position.y = abs($Hitbox.position.y)
		corpse_box.position.y = -abs(corpse_box.position.y)
		
	else:
		sprite.flip_v = false
		$Hitbox.position.y = -abs($Hitbox.position.y)
		corpse_box.position.y = abs(corpse_box.position.y)


func move_towards_nav_target():
	
	# create a vector of length 1 pointing towards the next pathfinding point
	movement_direction = nav_agent.get_next_path_position() - global_position
	movement_direction = movement_direction.normalized()
	anim_player.play("Swim")
	update_sprite_rotation()

# checks if there is a target available to chase
# this will in the future take into account the creature's fear, perception, and aggression
func player_in_range() -> bool:
	# save the previous target to restore later
	var prev_target = nav_agent.target_position
	nav_agent.target_position = player.global_position
	var return_val: bool = false
	if nav_agent.distance_to_target() <= detection_range:
		return_val = true
	nav_agent.target_position = prev_target
	return return_val


func wander() -> void:
	print('wandering towards ', nav_agent.target_position, ", currently at ", position)
	if reached_nav_target:
		nav_agent.target_position = get_random_nav_position(80, 300)
		reached_nav_target = false
	move_towards_nav_target()

func chase():
	# persue if within aggro range
	nav_agent.target_position = player.global_position
	move_towards_nav_target()
		
	# return to idle
	#elif state.linear_velocity.length() != 0:
	#	anim_player.queue("Idle")

func choose_behavior():
	# prevent the mob from transitioning into another animation until the current one has finished
	if anim_player.is_playing() == true and anim_player.current_animation != "Idle":
		return
	
	if current_behavior == Behaviors.CHASE:
		if not player_in_range():
			current_behavior = Behaviors.IDLE
			reached_nav_target = true # this is to force mob to choose new wander target
		else:
			chase()
			
	elif current_behavior == Behaviors.FLEE:
		pass
	elif current_behavior == Behaviors.WANDER:
		if player_in_range():
			current_behavior = Behaviors.CHASE
			nav_agent.target_position = player.global_position
		else:
			wander()
	elif current_behavior == Behaviors.IDLE:
		reached_nav_target = true
		current_behavior = Behaviors.WANDER
			
		
	# if the mob is currently doing an animation, let it finish
	# otherwise:
	#	if the mob is currently chasing the player, continue to do so
	#	else if the mob is fleeing the player, continue to do
	#	else if the mob is wandering towards a point, continue to do so
	#		the mob will interrupt this behavior if it starts chasing or fleeing
	#	else the mob must have finished its current behavior, so start up its idle/wander/patrol loop
	



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


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# kills mob if health is 0
	if health <= 0 and alive:
		die()
		
	if alive:
		choose_behavior()

	# otherwise, fade out corpse and have it sink to cave floor
	else:
		# makes sprite's color slowly fade to MAX_FADE
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


func _on_navigation_agent_2d_target_reached() -> void:
	#reached_nav_target = true
	pass


func _on_navigation_agent_2d_navigation_finished() -> void:
	reached_nav_target = true
	print("nav finished")
