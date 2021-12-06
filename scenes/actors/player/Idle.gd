extends State

#func _setup() -> void:
#	persistant_state.change_animation_state('Idle')

func process_main(_delta):
	persistant_state.change_animation_state('Idle')
	
	if persistant_state.input_vector.x:
		return persistant_state.STATE_RUN
