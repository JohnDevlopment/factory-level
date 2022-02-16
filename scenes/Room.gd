extends Node2D

var hud : Control

func _ready() -> void:
	hud = UI.get_hud()
	if is_instance_valid(hud):
		hud.show()
	
	Game.set_paused(true)
	TransitionRect.set_alpha(1)
	TransitionRect.fade_in()
	yield(TransitionRect, 'fade_finished')
	Game.set_paused(false)

func _exit_tree() -> void:
	hud.hide()
