# Used to define and contain global enums.
# Define the enum and then export it as the type of an unused property.
# The enum will then be available through the Enums class.
# Autocompletion for enums is quite buggy when doing static typing and
# you may need to manually type out the enum values.
extends Resource
class_name Enums

enum Modifier {STEALTH, MOBILITY, BUOYANCY, INSULATION, SIGHT} 
enum EquipmentType {GOGGLES, BCD, FINS, RESPIRATOR} 

@export var _modifier: Modifier
@export var _equipment_type: EquipmentType
