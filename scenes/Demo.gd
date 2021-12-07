extends Node2D

var Bob : Actor
var DebugOverlay
var EnergyBall

func _ready() -> void:
	NodeMapper.map_nodes(self)
	
	DebugOverlay.add_stat("Bob Velocity", Bob, "velocity", false)
	DebugOverlay.add_stat("Bob Direction", Bob, "direction", false)
	DebugOverlay.add_stat("Bob Input Vector", Bob, "input_vector", false)

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed('reset'):
		$EnergyBall.set_rigid_position(Vector2(248, 350))
