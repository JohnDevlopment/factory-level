extends State

#func _setup() -> void:
#	persistant_state.change_animation_state('Run')

func physics_main(delta: float):
	var velocity : Vector2 = persistant_state.calculate_normal_movement(delta)
	if persistant_state.direction.x == 0.0 and is_zero_approx(velocity.x):
		return persistant_state.STATE_IDLE

func process_main(_delta):
	var anim_state := 'Run'
	if persistant_state._object_picked:
		anim_state += 'Carry'
	
	persistant_state.change_animation_state(anim_state)
