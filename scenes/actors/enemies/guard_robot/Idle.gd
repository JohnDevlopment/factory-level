extends State

func _setup() -> void:
	user_data.frames.play('Idle')

# warning-ignore:unused_argument
func physics_main(delta: float):
	# Triggered when the player enters its range
	var root : Actor = persistant_state
	var player := Game.get_player()
	if Geometry.is_point_in_circle(player.global_position, root.global_position, root.detection_radius):
		var to_player := root.global_position.direction_to(player.global_position)
		if to_player.dot(root.direction) > 0.0:
			return root.STATE_CHARGE
