extends State

#func _setup() -> void:
#	persistant_state.change_animation_state('Run')

func physics_main(delta: float):
	var velocity : Vector2 = persistant_state.update_velocity(delta)
	if persistant_state.input_vector.x == 0.0 and is_zero_approx(velocity.x):
		return persistant_state.STATE_IDLE

func process_main(_delta):
	persistant_state.change_animation_state('Run')
