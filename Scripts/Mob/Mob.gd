extends CharacterBody2D

# variables defining the basic attributes of the mob
# these can be customized per-type or per-instance to change behavior
@export var health: float = 3
@export var awareness: float = 0.6
@export var aggression = 0
@export var fear = 0
@export var speed = 40
@export var accel = 7

# aliases for commonly referenced nodes
@onready var player = $"../Player/PlayerBody"
@onready var nav = $NavigationAgent2D
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var hurtbox = $Hurtbox/CollisionShape2D
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

func _ready():
	setup_nav_server()
	# for some reason,the hurtbox is always instantiated disabled
	# this re-enables it
	hurtbox.set_deferred("disabled", false)

# this is set to false when the mob dies and is checked to enable the death effects
var alive: bool = true

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
	anim_player.play("Die")
	# here you can define additional behavior after death (i.e. explodes)

func approach_player(delta):
	var direction = Vector3()
	
	# get player's position
	nav.target_position = player.global_position
	
	# prevent the mob from transitioning into another animation until the current one has finished
	if (
		anim_player.current_animation == "Hurt"
		or anim_player.current_animation == "Attack"
	):
		return
	
	# persue if within aggro range
	if nav.distance_to_target() <= detection_range:
		# create a vector of length 1 pointing towards the next pathfinding point
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		
		# linear interpolation to apply acceleration
		velocity = velocity.lerp(direction * speed, accel * delta)
		# rotate sprite to match movement direction
		rotation = velocity.angle()
			
	# return to idle
	elif velocity.length() != 0:
		# decelerate towards 0
		velocity = velocity.lerp(Vector2.ZERO, accel/2.0 * delta)
		# rotate towards 0; will be replaced with an "idle" animation & movement pattern
		rotation = clampf(rotation - rotation * accel/2.0 * delta, min(0, rotation), max(0, rotation))
	
	if velocity.length() != 0:
		anim_player.play("Swim")
	else:
		anim_player.play("Idle")
	
	# flip sprite only on vertical axis bc rotation takes care of the horizontal flip
	if rotation > PI/2 or rotation < -PI/2:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
	
# Function to run every time the mob is injured
# Takes the amount of damage as an argument
func hurt(damage: float):
	velocity = velocity/4.0
	print("Hurt")
	anim_player.play("Hurt")
	# this is required to immediately start the new animation
	# otherwise, it doesn't start soon enough to disable the hurtbox
	anim_player.advance(0)
	health -= damage

func _physics_process(delta: float) -> void:
	var new_position = NavigationServer2D.region_get_random_point(region, 1, false)
	print(position, global_position)
	position = new_position
	return
	
	# kills mob if health is 0
	if health <= 0 and alive:
		die()
	
	if alive:
		approach_player(delta)
	# otherwise, fade out corpse and have it sink to cave floor
	else:
		# makes sprite's color slowly fade to 50% of its normal color
		if death_fade > MAX_FADE:
			death_fade = lerp(death_fade, MAX_FADE, delta/5)
			shade(death_fade, death_fade, death_fade)
			
		if abs(rotation) > 0.001:
			rotation = clampf(rotation - rotation * accel/2 * delta, min(0, rotation), max(0, rotation))
		else:
			rotation = 0
		
		# drift to cave floor
		velocity = velocity.lerp(Vector2.DOWN * 25, 10 * delta)
	
	# move mob based on velocity
	move_and_slide()
	

func _on_hurtbox_area_entered(_area: Area2D) -> void:
	print("mob hurtbox entered")
	#if alive:
	hurt(1)
