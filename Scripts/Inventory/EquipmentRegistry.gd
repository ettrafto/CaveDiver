# Containts templates for all equipment in the game.
# Use new_equipment(equipment_id) to get copies of these templates.
extends Resource
class_name EquipmentRegistry

var _data = {
	[0]: Equipment.new(
		0,                           # equipment_id
		"Super Goggles",             # name
		"High-quality goggles.",     # description
		3,                           # weight
		Enums.EquipmentType.GOGGLES, # type
		{Enums.Modifier.SIGHT: 3},   # stat_modifiers
		""                           # sprite_ref
	)
}

"""
Returns a copy of equipment that matches equipment_id
"""
func new_equipment(equipment_id: int) -> Item:
	if equipment_id in _data:
		var equipment: Equipment = _data[equipment_id]
		return equipment.clone()
	return null
