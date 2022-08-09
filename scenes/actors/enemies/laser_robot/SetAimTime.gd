extends BTLeaf

func _tick(_agent: Node, blackboard: Blackboard) -> bool:
	# Set the amount of time it takes to rotate
	var tm := rand_range(1.0, 1.75)
	blackboard.set_data('aim_time', tm)
	
	return succeed()

#func _angle_diff(a: float, b: float) -> float:
#	var result : float
#	var msg := "{0} - {1} = {2}"
#	if a < b:
#		result = b - a
#		msg = msg.format([b, a, result])
#	else:
#		result = a - b
#		msg = msg.format([a, b, result])
#	if debug:
#		msg += " (%f degrees)" % rad2deg(result)
#		print("DEBUG: ", msg)
#	return result
