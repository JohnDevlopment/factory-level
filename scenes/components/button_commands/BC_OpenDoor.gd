extends "res://scenes/components/button_commands/ButtonCommand.gd"

export(NodePath) var path_to_door : NodePath

var _door : Node

func _ready() -> void:
	_door = get_node_or_null(path_to_door)
	assert(_door, "node not found: %s" % path_to_door)
	set_meta('toggle_bit', int(_door.open as bool))

func do_command(flag: bool) -> void:
	var anims := ['down', 'up']
	var idx : int = get_meta('toggle_bit') ^ int(flag)
	_door.call_deferred('do_animation', anims[idx])
