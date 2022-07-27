extends BTLeaf

onready var _radspeed := deg2rad(15.0)

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var head : Sprite = agent.get_node(@'Head')
	var bb_angle : float = blackboard.get_data('aim_angle')
	var new_rotation : float = move_toward(
		head.rotation,
		bb_angle,
		blackboard.get_data('aim_speed') * get_physics_process_delta_time()
	)
	head.rotation = new_rotation
	
#	if is_equal_approx(head.rotation, bb_angle):
#		return succeed()
	
	return succeed()
