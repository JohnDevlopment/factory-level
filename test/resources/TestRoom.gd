tool
extends "res://scenes/Room.gd"

onready var transition_rect = $Actors/Triggers/ScreenTransitionRect

func _fade_in(): pass

func get_screen_transition_rect() -> Node2D:
	return transition_rect

func start_screen_transition() -> void:
	transition_rect.transition_screen($Camera2D, $Camera2D.get_camera_position())
