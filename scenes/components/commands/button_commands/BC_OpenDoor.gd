tool
extends "res://scenes/components/commands/button_commands/ButtonCommand.gd"

export(NodePath) var powered_door setget set_powered_door

func _ready() -> void:
	if Engine.editor_hint: return

func _get_configuration_warning() -> String:
	var warning : String = ._get_configuration_warning() + "\n\n"
	
	var door = get_node_or_null(powered_door)
	if not door:
		warning += "No path to a PoweredDoor was provided. This command will not work."
	else:
		if not _check_valid_door(door):
			warning += "The node '%s' is not a PoweredDoor; if it was, it would have the '_flip_state' method." % powered_door
	
	return warning.trim_suffix("\n\n")

func do_command() -> void:
	var toggled : bool = get_meta('button_toggled')
	var door = get_node_or_null(powered_door)
	if door:
		assert(_check_valid_door(door), "Must be a PoweredDoorBase")
		door._flip_state()
		emit_command_signal([toggled])

func set_powered_door(path: NodePath) -> void:
	powered_door = path
	update_configuration_warning()

func _check_valid_door(node: Node) -> bool:
	var has_right_method := false
	var methods = (node.get_script() as Script).get_script_method_list()
	for method in methods:
		if method.name == '_flip_state':
			has_right_method = true
	return has_right_method
