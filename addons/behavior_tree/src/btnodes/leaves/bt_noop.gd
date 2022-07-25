extends BTLeaf
class_name BTNoop

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	return succeed()
