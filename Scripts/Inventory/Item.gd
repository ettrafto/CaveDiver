# Item.gd
extends RefCounted # used for auto memory mgmt
class_name Item

var type: String
var name: String
var weight: int

func _init(_type: String, _name: String, _weight: int):
	type = _type
	name = _name
	weight = _weight
