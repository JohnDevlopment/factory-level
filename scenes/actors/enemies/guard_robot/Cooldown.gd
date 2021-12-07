extends State

func _setup() -> void:
	persistant_state.global_position.x = user_data.initial_position.x
	persistant_state.velocity.x = 0
	persistant_state.distance_met = 0
	user_data.frames.play('Idle')
	user_data.timer.start()
	
	yield(user_data.timer as Timer, "timeout")
	
	emit_signal('state_change_request', persistant_state.STATE_IDLE)
