extends State

#func _setup() -> void:
#	persistant_state.change_animation_state('Idle')

func process_main(_delta):
	var anim_state := 'Idle'
	if persistant_state._object_picked:
		anim_state += 'Carry'
	
	persistant_state.change_animation_state(anim_state)
	
	if persistant_state.direction.x:
		return persistant_state.STATE_RUN
