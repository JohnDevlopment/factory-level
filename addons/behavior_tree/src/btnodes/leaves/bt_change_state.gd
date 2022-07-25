extends BTLeaf
class_name BTChangeState

export var next_state : int

func _tick(_agent: Node, blackboard: Blackboard) -> bool:
	blackboard.set_data('current_state', next_state)
	if debug:
		print("DEBUG: change state to ", next_state)
#		if abort_tree:
#			print("DEBUG: Will abort tree")
	return succeed()
