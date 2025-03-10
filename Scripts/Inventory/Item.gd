# Item.gd
extends RefCounted
class_name Item

var type: String
var name: String
var loc: Vector2 = Vector2.ZERO
var weight: int

func _init(_type: String, _name: String, _loc: Vector2, _weight: int):
	type = _type
	name = _name
	loc = _loc
	weight = _weight
