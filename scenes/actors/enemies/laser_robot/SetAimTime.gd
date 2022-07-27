extends BTLeaf

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	# Set the amount of time it takes to rotate
	var tm := rand_range(0.75, 0.9)
	blackboard.set_data('aim_time', tm)
	
	var bb_angle : float = blackboard.get_data('aim_angle')
	
	# Difference between angles
	var diff := _angle_diff(
		(agent.get_node('Head') as Node2D).rotation,
		bb_angle
	)
	
	# Angular speed in radians
	var speed := diff / tm
	blackboard.set_data('aim_speed', speed)
	
	if debug:
		print("DEBUG: reach %f radians (%f degrees) in %f seconds" % [
			bb_angle,
			rad2deg(bb_angle),
			tm
		])
		print(
			"DEBUG: speed calculated is %f radians/second (%f degrees/second)" \
			% [
				speed,
				rad2deg(diff) / tm
			]
		)
	
	# Set the number of times the robot may correct its aim
#	randomize()
#	var chances : int = 1 if (randi() % 100) < 50 else 2
#	blackboard.set_data('aim_chances', chances)
#
#	if debug:
#		print("DEBUG: aim_time set to %f and aim_chances to %d" \
#				% [tm, chances])
	
	return succeed()

func _angle_diff(a: float, b: float) -> float:
	var result : float
	var msg := "{0} - {1} = {2}"
	if a < b:
		result = b - a
		msg = msg.format([b, a, result])
	else:
		result = a - b
		msg = msg.format([a, b, result])
	if debug:
		msg += " (%f degrees)" % rad2deg(result)
		print("DEBUG: ", msg)
	return result
