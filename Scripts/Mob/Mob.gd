extends CharacterBody2D

@export var health: float = 1
@export var awareness: float = 0.6
@export var aggression = 0
@export var fear = 0

@onready var player = $"../Player/PlayerBody"
@onready var nav = $NavigationAgent2D
@onready var sprite = $AnimatedSprite2D

@export var speed = 40
@export var accel = 7

# prevents multiple hits in quick succession
var invincible: bool = false

var alive: bool = true
var max_detection = 500
var detection_range = max_detection * awareness

var MAX_FADE = 0.5
var death_fade = 1.0

func shade(red_factor=1, green_factor=1, blue_factor=1, alpha=1):
	$AnimatedSprite2D.material.set_shader_parameter("red_factor", red_factor)
	$AnimatedSprite2D.material.set_shader_parameter("green_factor", green_factor)
	$AnimatedSprite2D.material.set_shader_parameter("blue_factor", blue_factor)
	$AnimatedSprite2D.material.set_shader_parameter("alpha", alpha)

func die():
	alive = false
	$AnimatedSprite2D.play("death")
	# here you can define additional behavior after death (i.e. explodes)

func approach_player(delta):
	var direction = Vector3()
	
	# get player's position
	nav.target_position = player.global_position
	#print("Distance to player: ", nav.distance_to_target())
	
	#print(rotation/PI)
	
	if $HitCooldown.time_left > 0:
		sprite.play("hurt")
	else:
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
			#decelerate towards 0
			velocity = velocity.lerp(Vector2.ZERO, accel/2 * delta)
			#rotate towards 0; will be replaced with an "idle" animation & movement pattern
			rotation = clampf(rotation - rotation * accel/2 * delta, min(0, rotation), max(0, rotation))
		
		if velocity.length() != 0:
			sprite.play("swim")
		else:
			sprite.play("idle")
	
	# flip sprite only on vertical axis bc rotation takes care of the horizontal flip
	if rotation > PI/2 or rotation < -PI/2:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
	
# Function to run every time the mob is injured
# Takes the amount of damage as an argument
func hurt(damage: float):
	if not invincible:
		invincible = true
		velocity = velocity/4.0
		print("Hurt")
		sprite.play("hurt")
		health -= damage
		$HitCooldown.start()

func _physics_process(delta: float) -> void:
	# kills mob if health is 0
	if health <= 0 and alive:
		die()
		
	
	if alive:
		approach_player(delta)
	else:
		# makes sprite's color slowly fade to 50% of its normal color
		if death_fade > MAX_FADE:
			death_fade = lerp(death_fade, 0.5, delta/5)
			shade(death_fade, death_fade, death_fade)
			
		if abs(rotation) > 0.001:
			rotation = clampf(rotation - rotation * accel/2 * delta, min(0, rotation), max(0, rotation))
		else:
			rotation = 0
		
		# if dead, drift to cave floor
		velocity = velocity.lerp(Vector2.DOWN * 25, 10 * delta)
	
	move_and_slide()
	
	#check for player collisions
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var body := collision.get_collider()
		#print("Collided with: ", body.name)
		if body.name == "PlayerBody":
			#print("	Collided with a player")
			hurt(1)

func _on_hit_cooldown_timeout() -> void:
	invincible = false
	$HitCooldown.stop()
	print("timer timeout")
