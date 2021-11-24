extends Node2D

var debug_overlay
var explorer

func _ready() -> void:
	explorer = $Actors/Explorer
	debug_overlay = $DebugOverlay

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed('reset'):
		$EnergyBall.set_rigid_position(Vector2(248, 350))
