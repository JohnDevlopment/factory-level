## A basic variable reference.
extends Reference
class_name VarRef

## The reference type.
# @getter get_type()
# @type int
# @desc The value is a constant of type @class{Variant.Type}.
var type: int = TYPE_NIL setget ,get_type

## The referenced object.
# @type Variant
# @setter set_object(o)
# @getter get_object()
# @desc Can be any type.
var object setget set_object,get_object

func get_object(): return object

func get_type() -> int: return type

func set_object(o):
	object = o
	type = typeof(o)

func _init(o = null): set_object(o)

func _to_string() -> String: return str(object)
