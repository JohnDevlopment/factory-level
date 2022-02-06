extends "res://scenes/Room.gd"

func _on_GuardRobot_defeated() -> void:
	$Actors/PoweredDoor1x3.do_animation('up')
