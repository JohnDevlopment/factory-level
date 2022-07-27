extends BTLeaf

const LASER = preload('res://scenes/actors/projectiles/Laser.tscn')

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var laser = LASER.instance()
	var spawn_point : Vector2 = blackboard.get_data('spawn_point').global_position
	var angle : float = blackboard.get_data('aim_angle')
	agent.get_parent().add_child(laser)
	laser.launch(
		spawn_point,
		blackboard.get_data('direction'),
		angle
	)
	
	return succeed()
