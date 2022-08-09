extends BTLeaf

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var head : Sprite = agent.get_node(@'Head')
	var bb_angle : float = blackboard.get_data('aim_angle')
	var new_rotation := move_toward(
		head.rotation,
		bb_angle,
		agent.ANGLE_SPEED * get_physics_process_delta_time()
	)
	head.rotation = new_rotation
	blackboard.set_data('head_angle', new_rotation)
	
	return succeed()
