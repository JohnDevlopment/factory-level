extends BTLeaf

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var angle : float = agent.call('_target_player')
	blackboard.set_data('aim_angle', angle)
	
	if debug:
		var msg := "DEBUG: angle = %f radians (%f degrees)"
		print(msg % [angle, rad2deg(angle)])
	
	return succeed()
