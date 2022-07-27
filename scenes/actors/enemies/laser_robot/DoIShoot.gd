extends BTConditional

func _pre_tick(_agent: Node, blackboard: Blackboard) -> void:
	var key := "raycast/colliding"
	assert(blackboard.get_data(key) is bool, "missing/invalid key '%s'" % key)
	
	# True if raycast is not colliding
	verified = not blackboard.get_data(key)
