tool
extends "res://scenes/Room.gd"

const CORRECT_CAMERA_RECTS := [
		Rect2(Vector2(), Vector2(300, 300)),
		Rect2(Vector2(300, 0), Vector2(300, 150)),
		Rect2(Vector2(300, 150), Vector2(300, 150))
	]

func _fade_in(): pass

func get_screen_transition_rect():
	return $Actors/Triggers/ScreenTransitionRect
