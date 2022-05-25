## Base class for implementing commands
# @desc This class is abstract and should not be instanced directly;
#       rather it should be inherited from to define the action.
tool
extends Node
class_name Command

## Whether the command is active or not.
# @type bool
var active := true

## User-defined data.
# @type Dictionary
var user_data := {}

func _ready() -> void:
	if Engine.editor_hint: return
	for node in get_children():
		var is_valid_class : bool = node.get_class() in ['Command', 'Position2D']
		assert(is_valid_class, "child must be a Command")
		
		if node is Position2D:
			user_data[node.name] = node.global_position
			node.queue_free()

## Performs the action.
# @desc Calls the virtual method @function{_do_command} to do the actual command.
func do_command():
	if not active: return
	return _do_command()

func get_class() -> String: return 'Command'

## Override this function in your script to implement your own command.
# @virtual
# @desc    If a yield is encountered, the command handler pauses itself
#          until said yield finishes.
func _do_command(): pass

func _set(property: String, value) -> bool:
	match property:
		'active':
			active = value
		_:
			return false
	return true

func _get(property: String):
	match property:
		'active':
			return active

func _get_property_list() -> Array:
	return [
		{
			name = 'Command',
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = 'active',
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

func _get_configuration_warning() -> String:
	var cls := get_parent().get_class()
	if not cls in ['Command', 'CommandHandler']:
		return "This node should be a child to a Command or CommandHandler, otherwise it will not work correctly."
	return ""
