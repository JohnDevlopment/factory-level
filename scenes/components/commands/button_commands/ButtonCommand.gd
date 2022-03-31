tool
extends "res://scenes/components/commands/Command.gd"

func _ready() -> void:
	if Engine.editor_hint: return
	get_parent().connect('toggle_status_changed', self, '_on_button_toggled')

func _get_configuration_warning() -> String:
	var warning := ""
	
	if not _check_root_node(get_parent()):
		warning += "The parent of this node is not a BaseButton; if it was, it would have the 'toggle_status_changed' signal. Please reparent this node to a BaseButton."
	
	return warning

func _on_button_toggled(flag: bool) -> void:
	set_meta('button_toggled', flag)
	do_command()

func _check_root_node(node: Node) -> bool:
	var is_valid_root := false
	var script = node.get_script()
	if script:
		is_valid_root = script.has_script_signal('toggle_status_changed')
	return is_valid_root


