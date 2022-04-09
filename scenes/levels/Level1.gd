tool
extends "res://scenes/Room.gd"

onready var overlay = $DebugOverlay

func _ready() -> void:
	if Engine.editor_hint: return

func _on_guard_robot_defeated() -> void:
	$Actors/FirstDoor.do_animation('up')
