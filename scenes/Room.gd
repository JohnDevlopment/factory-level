extends Node2D

var hud : Control

func _ready() -> void:
	hud = UI.get_hud()
	if is_instance_valid(hud):
		hud.show()
		hud.connect_room(self)
		for enemy in get_tree().get_nodes_in_group('enemies'):
			(enemy as Enemy).connect('defeated', self, '_on_enemy_defeated')
	
	Game.set_paused(true)
	TransitionRect.set_alpha(1)
	TransitionRect.fade_in()
	yield(TransitionRect, 'fade_finished')
	Game.set_paused(false)

func _on_enemy_defeated() -> void:
	var robots_destroyed = hud.robots_destroyed
	hud.set_robots_destroyed(robots_destroyed + 1)
