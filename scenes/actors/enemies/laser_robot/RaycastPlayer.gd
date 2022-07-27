extends BTLeaf

func _tick(_agent: Node, blackboard: Blackboard) -> bool:
	var rc : RayCast2D = blackboard.get_data('raycast')
	rc.cast_to = (blackboard.get_data('raycast/cast_to') as Vector2).rotated(
		blackboard.get_data('aim_angle')
	)
	if debug:
		print("DEBUG: to cast_to: ", rc.cast_to)
	
	rc.force_raycast_update()
	
	# Set the key indiciating whether the raycast is colliding
	blackboard.set_data('raycast/colliding', rc.is_colliding())
	if debug:
		print("DEBUG: colliding = ", rc.is_colliding())
	
	return succeed()
