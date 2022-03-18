extends Node

class Person:
	extends Node
	
	var age := 0
	var personal_name := ''
	
	var _verficiation := {}
	
	func _ready() -> void:
		_validate_fields()
	
	func _validate_fields() -> void:
		_verficiation['age'] = age > 0
		_verficiation['personal_name'] = not personal_name.empty()

func _ready() -> void:
	pass
