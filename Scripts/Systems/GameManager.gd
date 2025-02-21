# ex. LISTENING FOR HEALTH CHANGES IN HUD.gd
#func _ready():
 #   GameManager.connect("health_changed", self, "_on_health_changed")
#
#func _on_health_changed(new_health):
#   $HealthBar.value = new_health
#
#
# ex. REDUCING HEALTH IN PLAYER.gd
# GameManager.decrease_health(10)
#


extends Node

# Player stats
var player_health: int = 100
var max_health: int = 100
var bcd_inflation: float = 0.5
var oxygen: int = 100
var max_oxygen: int = 100 
var oxygen_consumption_rate: float = 0.5

# Game state
var game_paused: bool = false
var game_over: bool = false

# Signals
signal health_changed(new_health)
signal oxygen_changed(new_oxygen)
signal game_over_triggered

# Called when the game starts
func _ready():
	print("GameManager initialized")
	
# Decrease player's health
func decrease_health(amount: int):
	player_health -= amount
	if player_health < 0:
		player_health = 0
		trigger_game_over()
	emit_signal("health_changed", player_health)

# Increase player's health
func increase_health(amount: int):
	player_health = min(player_health + amount, max_health)
	emit_signal("health_changed", player_health)

# Decrease oxygen level
func decrease_oxygen(amount: int):
	oxygen -= amount
	if oxygen <= 0:
		oxygen = 0
		decrease_health(10)  # Losing oxygen damages health
	emit_signal("oxygen_changed", oxygen)

# Refill oxygen (e.g., when resurfacing)
func refill_oxygen():
	oxygen = max_oxygen
	emit_signal("oxygen_changed", oxygen)

# Trigger game over
func trigger_game_over():
	game_over = true
	emit_signal("game_over_triggered")
	print("Game Over!")

# Toggle pause state
func toggle_pause():
	game_paused = !game_paused
	get_tree().paused = game_paused
