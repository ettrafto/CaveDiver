extends Node

# --- Oxygen and Consumption Settings ---
var current_oxygen: float = GameManager.oxygen  # Link to GameManager oxygen
var baseline_consumption: float = 10.0  # Baseline psi/min 
var p_divisor: float = 33.0  # Use 33ft per atm increase

# --- Player Movement State ---
# Set these values based on actual player input in your project.
# "idle" => 0.8, "normal" => 1.0, "sprint" => 1.5
var movement_state: String = "normal"  

func get_movement_multiplier() -> float:
	if movement_state == "idle":
		return 0.8
	elif movement_state == "sprint":
		return 1.5
	else:
		return 1.0

# --- Dive Phase Enumeration ---
enum DivePhase { BOTTOM, ASCENT, SAFETY_STOP, FINISHED }
var current_phase: int = DivePhase.BOTTOM

# --- Bottom Phase Settings ---
var bottom_duration: float = 20.0  # minutes at bottom
var bottom_elapsed: float = 0.0
var bottom_depth: float = 60.0  # ft
var activity_bottom: float = 5.0  # extra consumption factor during bottom phase

# --- Ascent Phase Settings ---
var ascent_duration: float = 5.0  # minutes for ascent
var ascent_elapsed: float = 0.0
var ascent_start_depth: float = bottom_depth  # start at bottom
var ascent_end_depth: float = 0.0  # surface
var activity_ascent: float = 3.0  # lower activity during ascent

# --- Safety Stop Settings ---
var safety_stop_duration: float = 3.0  # minutes for safety stop (could be adjusted dynamically)
var safety_stop_elapsed: float = 0.0
var safety_stop_depth: float = 15.0  # ft
var activity_safety: float = 2.0  # minimal activity during safety stop

# --- Utility Functions ---
func get_pressure_factor(depth: float) -> float:
	return depth / p_divisor + 1.0

func compute_consumption(baseline: float, activity: float, depth: float, dt: float) -> float:
	var pressure_factor = get_pressure_factor(depth)
	var movement_multiplier = get_movement_multiplier()
	var consumption = (baseline + activity) * pressure_factor * dt * movement_multiplier
	# Debug: print calculation details for consumption
	print("Depth:", depth, "Pressure Factor:", pressure_factor, "Movement Multiplier:", movement_multiplier, "Consumption:", consumption, "dt:", dt)
	return consumption

# --- Dive Phase Processing Methods ---
func process_bottom_phase(dt: float):
	if bottom_elapsed < bottom_duration:
		var consumption = compute_consumption(baseline_consumption, activity_bottom, bottom_depth, dt)
		current_oxygen -= consumption
		bottom_elapsed += dt
		print("BOTTOM PHASE | Elapsed:", bottom_elapsed, "/", bottom_duration, "min | Remaining O₂:", current_oxygen)
	else:
		print("Transitioning from BOTTOM to ASCENT phase.")
		current_phase = DivePhase.ASCENT

func process_ascent_phase(dt: float):
	if ascent_elapsed < ascent_duration:
		var t = ascent_elapsed / ascent_duration
		var current_depth = lerp(ascent_start_depth, ascent_end_depth, t)
		var consumption = compute_consumption(baseline_consumption, activity_ascent, current_depth, dt)
		current_oxygen -= consumption
		ascent_elapsed += dt
		print("ASCENT PHASE | Elapsed:", ascent_elapsed, "/", ascent_duration, "min | Depth:", current_depth, "ft | Remaining O₂:", current_oxygen)
	else:
		print("Transitioning from ASCENT to SAFETY_STOP phase.")
		current_phase = DivePhase.SAFETY_STOP

func process_safety_stop(dt: float):
	if safety_stop_elapsed < safety_stop_duration:
		var consumption = compute_consumption(baseline_consumption, activity_safety, safety_stop_depth, dt)
		current_oxygen -= consumption
		safety_stop_elapsed += dt
		print("SAFETY STOP PHASE | Elapsed:", safety_stop_elapsed, "/", safety_stop_duration, "min | Remaining O₂:", current_oxygen)
	else:
		current_phase = DivePhase.FINISHED
		print("Dive finished. Final remaining O₂:", current_oxygen)
		# Update GameManager oxygen to reflect simulation result
		GameManager.oxygen = current_oxygen

# --- Main Process Loop ---
func _process(delta: float) -> void:
	var dt = delta / 60.0  # Convert delta seconds to minutes
	match current_phase:
		DivePhase.BOTTOM:
			process_bottom_phase(dt)
		DivePhase.ASCENT:
			process_ascent_phase(dt)
		DivePhase.SAFETY_STOP:
			process_safety_stop(dt)
		DivePhase.FINISHED:
			set_process(false)
			print("Dive simulation complete.")
	
	# Update GameManager oxygen continuously
	GameManager.oxygen = current_oxygen
	print("Current Phase:", current_phase, "Overall Remaining O₂:", current_oxygen)
