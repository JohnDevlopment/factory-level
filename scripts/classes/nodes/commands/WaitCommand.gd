tool
extends Command
class_name WaitCommand

var wait_time := 1.0

func _do_command():
	yield(get_tree().create_timer(wait_time), 'timeout')

func _get(property: String):
	match property:
		'wait_time':
			return wait_time

func _set(property: String, value) -> bool:
	match property:
		'wait_time':
			wait_time = value
		_:
			return false
	
	return true

func _get_property_list() -> Array:
	return [
		{
			name = 'WaitCommand',
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = 'wait_time',
			type = TYPE_REAL,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = '0.1,100.0,0.1,or_greater'
		}
	]
