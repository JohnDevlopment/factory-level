extends "res://scenes/Room.gd"

func _on_guard_robot_defeated() -> void:
	$Actors/FirstDoor.do_animation('up')
