tool
extends Node
class_name CommandHandler

## Emitted to signify that the command handler has started processing.
signal started()

## Emitted to signify that the handler has finished processing commands.
signal finished()

## Indicates whether the command handler is active.
# @type bool
var active := true

var _current_command := 0
var _lock := false

func _ready() -> void:
	if Engine.editor_hint: return
	for node in get_children():
		assert(node is Command, "each child of this node must be a Command")

func _get_property_list() -> Array:
	return [
		{
			name = 'CommandHandler',
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = 'active',
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

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

func get_class() -> String: return 'CommandHandler'

## Executes each command in the tree.
func do_commands() -> void:
	if _lock: return
	_lock = true
	emit_signal('started')
	for i in get_child_count():
		_current_command = i
		var cmd : Command = get_child(_current_command)
		var result = cmd.do_command()
		if result is GDScriptFunctionState:
			yield(result, 'completed')
	emit_signal('finished')
	_lock = false
