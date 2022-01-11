extends MarginContainer

func _ready() -> void:
	Game.set_paused(true)
	TransitionRect.fade_in()
	yield(TransitionRect, 'fade_finished')
	Game.set_paused(false)

func _go_to_scene(scene: String) -> void:
	scene = "res://scenes/beta/%s.tscn" % scene
	Game.set_paused(true)
	TransitionRect.fade_out()
	yield(TransitionRect, 'fade_finished')
	Game.set_paused(false)
	Game.go_to_scene(scene)
