extends BTConditional

const PLYDIFF := 5.0

# The condition is checked BEFORE ticking. So it should be in _pre_tick.
# warning-ignore:unused_argument
func _pre_tick(agent: Node, blackboard: Blackboard) -> void:
	var rc : RayCast2D = blackboard.get_data('raycast')
	var condition := true
	
	var data := {
		player_position = Game.get_player().get_center(),
		direction = (agent as Enemy).direction
	}
	
	if rc.is_colliding():
		var collider = rc.get_collider()
		if collider is Actor:
			# True if colliding with the player
			condition = (collider == Game.get_player())
		if not condition:
			# Not the player, check if collider blocks shot
			condition = not _is_object_blocking(
				rc.get_collision_point(),
				data
			)
	
	# Set the precondition
	verified = condition

func _is_object_blocking(cp: Vector2, data: Dictionary) -> bool:
	var playerpos : Vector2 = data['player_position']
	
	if data['direction'].x < 0.0:
		return (cp.x >= playerpos.x and abs(playerpos.y - cp.y) < PLYDIFF)
	
	return (cp.x < playerpos.x and abs(playerpos.y - cp.y) < PLYDIFF)
