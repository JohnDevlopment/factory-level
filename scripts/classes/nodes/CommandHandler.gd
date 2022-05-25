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

## The root node.
# @type NodePath
var root_node : NodePath

var _current_command := 0
var _lock := false

func _ready() -> void:
	if Engine.editor_hint:
		if root_node.is_empty():
			root_node = @".."
		return
	# Recursively set the root node for all commands in the tree
	if true:
		var temp = get_node(root_node)
		assert(temp, "invalid path '%s'" % root_node)
		propagate_call('set_command_root_node', [temp])
	# Assert that each child is a command
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
		},
		{
			name = 'root_node',
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

func _set(property: String, value) -> bool:
	match property:
		'active':
			active = value
		'root_node':
			root_node = value
		_:
			return false
	return true

func _get(property: String):
	match property:
		'active':
			return active
		'root_node':
			return root_node

#func _clean_node_path(path: NodePath) -> NodePath:
#	var clean_path = PoolStringArray([''])
#
#	for i in path.get_name_count():
#		var _name := path.get_name(i)
#		if _name.find('@') < 0:
#			clean_path.push_back(_name)
#
#	return NodePath( clean_path.join('/') )

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
