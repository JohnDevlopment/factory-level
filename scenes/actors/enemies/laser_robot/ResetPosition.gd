extends BTLeaf

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tween := create_tween()
	tween.tween_property(
		agent.get_node(@'Head'),
		@'rotation',
		0.0,
		2.0
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Rotate raycast using angle
	tween.parallel().tween_property(
		blackboard.get_data('raycast'),
		'cast_to',
		blackboard.get_data('raycast/cast_to'),
		2.0
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	return succeed()
