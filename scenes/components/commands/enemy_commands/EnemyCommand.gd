tool
extends "res://scenes/components/commands/Command.gd"

enum EnemyCondition {NULL, DEFEATED}

export(EnemyCondition) var enemy_condition : int

func _ready() -> void:
	if Engine.editor_hint: return
	var signal_name := VarRef.new()
	if _connect_right_signal(signal_name) != OK:
		push_error("Failed to connect '%s' signal in parent" % signal_name.object)

func _get_configuration_warning() -> String:
	var parent = get_parent()
	if not parent is Enemy:
		return "This node must be the direct child of an Enemy"
	return ""

func _connect_right_signal(signalref: VarRef) -> int:
	var code := OK
	match enemy_condition:
		EnemyCondition.DEFEATED:
			signalref.object = 'defeated'
			code = get_parent().connect('defeated', self, '_on_enemy_defeated')
	return code

func _on_enemy_defeated() -> void:
	do_command()
