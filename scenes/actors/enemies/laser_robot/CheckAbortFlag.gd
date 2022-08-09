extends BTLeaf

func _tick(_agent: Node, blackboard: Blackboard) -> bool:
	var should_abort : bool = blackboard.get_data('abort_tree')
	if should_abort:
		blackboard.set_data('aim_time', 0.0)
		emit_signal('abort_tree')
	
	return succeed()
