tool
extends Area2D

signal go_to_scene(scene, entrance)

export(PackedScene) var next_scene setget set_next_scene
export(int, -1, 255) var to_entrance := -1

var _player_detected := false

func _ready() -> void:
	if Engine.editor_hint: return
	_setup_door()

func _setup_door() -> void:
	if next_scene:
		connect('body_entered', self, '_on_player_detected', [true])
		connect('body_exited', self, '_on_player_detected', [false])

func _on_player_detected(_player, flag: bool) -> void:
	_player_detected = flag

func _get_configuration_warning() -> String:
	if not next_scene:
		return "There is no packed scene loaded. This node will not do anything."
	return ""

func _unhandled_key_input(event: InputEventKey) -> void:
	if _player_detected:
		if event.is_action_pressed('ui_up'):
			get_tree().set_input_as_handled()
			emit_signal('go_to_scene', next_scene, to_entrance)

func connect_exit(node: Node, function: String) -> void:
	connect('go_to_scene', node, function, [], CONNECT_ONESHOT)

func set_next_scene(scene: PackedScene) -> void:
	if not is_instance_valid(scene):
		next_scene = null
	else:
		next_scene = scene
	update_configuration_warning()
