tool
extends Node2D
class_name DebugShape2D

var enabled := true

var _drawing_commands := []

func _draw() -> void:
	if not enabled: return
	for drawing_command in _drawing_commands:
		callv(drawing_command[0], drawing_command[1])

func _get(property: String):
	match property:
		'enabled':
			return enabled

func _set(property: String, value) -> bool:
	match property:
		'enabled':
			enabled = value
			pass
		_:
			return false
	return true

func _get_property_list() -> Array:
	return [
		{
			name = 'DebugShape2D',
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = 'enabled',
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

func add_rect(rect: Rect2, color: Color, filled: bool = false,
width: float = 1.0, antialiased: bool = false) -> void:
	var element := [
		'draw_rect',
		[rect, color, filled, width, antialiased]
	]
	if element in _drawing_commands: return
	_drawing_commands.push_back(element)
