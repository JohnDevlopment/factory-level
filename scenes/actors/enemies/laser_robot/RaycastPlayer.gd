extends BTLeaf

func _tick(_agent: Node, blackboard: Blackboard) -> bool:
	var rc : RayCast2D = blackboard.get_data('raycast')
	var cast_to = (blackboard.get_data('raycast/cast_to') as Vector2)
	rc.cast_to = cast_to.rotated(blackboard.get_data('head_angle'))
	rc.force_raycast_update()
	return succeed()
