extends BTLeaf

func _tick(_agent: Node, blackboard: Blackboard) -> bool:
	var delay : float
	delay = max(
		blackboard.get_data('aim_time') - get_physics_process_delta_time(),
		0.0
	)
	blackboard.set_data('aim_time', delay)
	
	if is_zero_approx(delay):
		if debug:
			print('DEBUG: Aim delay counter depleted')
		return succeed()
	
	return fail()
