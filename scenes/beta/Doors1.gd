extends "res://scenes/Room.gd"

func _ready() -> void:
	if OS.has_feature('debug'):
		var overlay = $DebugOverlay
		overlay.add_stat('Bob Velocity', $Actors/Explorer, 'velocity', false)
		overlay.add_stat('Button Dot Product', $BaseButton, '_dot', false)
		overlay.add_stat('Button Toggled', $BaseButton, 'toggled', false)
