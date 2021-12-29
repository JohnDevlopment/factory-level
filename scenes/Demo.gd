extends Node2D

var Bob : Actor
var DebugOverlay
var EnergyBall

func _ready() -> void:
	NodeMapper.map_nodes(self)
	
	if OS.has_feature('debug'):
		DebugOverlay.add_stat("Bob Velocity", Bob, "velocity", false)
		DebugOverlay.add_stat("Bob Direction", Bob, "direction", false)
		DebugOverlay.add_stat("Bob Input Vector", Bob, "input_vector", false)
	else:
		(DebugOverlay as Object).queue_free()
		DebugOverlay = null
