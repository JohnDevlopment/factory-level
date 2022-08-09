extends BTLeaf

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var angle : float = agent.call('_target_player')
	blackboard.set_data('aim_angle', angle)
	return succeed()
