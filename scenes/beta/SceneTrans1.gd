tool
extends "res://scenes/Room.gd"

var gut_tester

onready var debug_overlay = $DebugOverlay

func _ready() -> void:
	if Engine.editor_hint: return
	#NodeMapper.map_nodes(self)
	debug_overlay.queue_free()
#	debug_overlay.propagate_call('show')
#	debug_overlay.add_stat('Player Position', $Actors/Bob, 'global_position', false)
#	debug_overlay.add_stat('Player Camera Position', $Actors/Bob/Camera2D,
#		'get_camera_position', true)
#	debug_overlay.add_stat('Player Camera Center', $Actors/Bob/Camera2D,
#		'get_camera_screen_center', true)
