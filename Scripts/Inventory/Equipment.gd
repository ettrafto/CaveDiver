# Equipment.gd
extends RefCounted # used for auto memory mgmt
class_name Equipment

var equipment_id: int
var name: String
var description: String
var weight: int
var type: Enums.EquipmentType
var stat_modifiers: Dictionary # {Modifier: int}
var sprite_ref: String

func _init(_equipment_id: int, _name: String, _description: String, _weight: int, 
		   _type: Enums.EquipmentType, _stat_modifiers: Dictionary, _sprite_ref: String):
	equipment_id = _equipment_id
	name = _name
	description = _description
	weight = _weight
	type = _type
	stat_modifiers = _stat_modifiers
	sprite_ref = _sprite_ref

#region Getters
func get_equipment_id() -> int:
	return equipment_id

func get_name() -> String:
	return name

func get_description() -> String:
	return description

func get_weight() -> int:
	return weight

func get_type() -> Enums.EquipmentType:
	return type

func get_stat_modifiers() -> Dictionary:
	return stat_modifiers.duplicate()

func get_sprite_ref() -> String:
	return sprite_ref
#endregion
