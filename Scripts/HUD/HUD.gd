extends Control

@onready var oxygen_bar = $Oxygen
@onready var weight_bar = $Weight
@onready var bcd_bar = $BCD

func _ready():
	# Ensure GameManager is loaded before connecting
	if GameManager:
		GameManager.health_changed.connect(_on_health_changed)
		GameManager.oxygen_changed.connect(_on_oxygen_changed)
	
	
	# Manually update bars after first frame
	await get_tree().process_frame
	update_bars()



func update_bars():
	if GameManager:
		#oxygen_bar.value = GameManager.oxygen
		#weight_bar.value = GameManager.weight
		print(GameManager.bcd_inflation)
		bcd_bar.set_value(GameManager.bcd_inflation * 100)
		

# ✅ Add this function so Player.gd can call it
func update_weight_and_bcd():
	if GameManager:
		weight_bar.value = GameManager.weight
		bcd_bar.value = GameManager.bcd_inflation

# Signal listeners
func _on_health_changed(new_health):
	update_bars()

func _on_oxygen_changed(new_oxygen):
	update_bars()

func _on_player_bcd_change() -> void:
	update_bars()
