extends Node2D

func _ready() -> void:
	Game.set_paused(true)
	TransitionRect.fade_in()
	yield(TransitionRect, 'fade_finished')
	Game.set_paused(false)
