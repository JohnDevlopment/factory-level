extends Node2D

var Bob : Actor
var DebugOverlay
var EnergyBall

onready var debug_console = $DebugOverlay/DebugConsole

func _ready() -> void:
	NodeMapper.map_nodes(self)
	
	if OS.has_feature('debug'):
		DebugOverlay.add_stat("Bob Velocity", Bob, "velocity", false)
		DebugOverlay.add_stat("Bob Direction", Bob, "direction", false)
		DebugOverlay.add_stat("Bob Input Vector", Bob, "input_vector", false)
	else:
		(DebugOverlay as Object).queue_free()
		DebugOverlay = null
		
	(debug_console as Object).queue_free()
	debug_console = null

func _unhandled_key_input(event: InputEventKey) -> void:
	if OS.has_feature('debug'):
		# debug commands
		if event.is_action_pressed('console'):
			debug_console.activate()
