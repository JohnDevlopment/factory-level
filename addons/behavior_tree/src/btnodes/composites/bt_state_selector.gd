extends BTComposite
class_name BTStateSelector

# Chooses one of its children based on an index;
# effectively a state machine.
# The current state is taken from the blackboard under
# the key "current_state". If the key doesn't exist,
# the state will always be zero.

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result
	var current_state : int = blackboard.data.get('current_state', 0)
	
	bt_child = get_child(current_state)
	
	result = bt_child.tick(agent, blackboard)
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	
	return succeed()
