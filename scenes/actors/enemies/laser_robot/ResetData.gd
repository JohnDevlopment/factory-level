extends BTLeaf

func _tick(_agent: Node, blackboard: Blackboard) -> bool:
	for key in ['aim_time', 'aim_angle', 'aim_delta']:
		blackboard.set_data(key, 0.0)
	blackboard.set_data('aim_chances', 0)
	
	return succeed()
