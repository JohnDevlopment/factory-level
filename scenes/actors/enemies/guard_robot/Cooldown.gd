extends State

func _setup() -> void:
	persistant_state.velocity.x = 0
	persistant_state.direction.x = 0
	persistant_state.distance_met = 0
	user_data.frames.play('Idle')
	user_data.timer.start()
