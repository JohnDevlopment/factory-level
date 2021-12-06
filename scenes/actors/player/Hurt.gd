extends State

# How long to disable input
var INPUT_TIMER := 1.0

var _current_time : float

func _setup() -> void:
	persistant_state.modulate = Color.red
	persistant_state.input_vector.x = 0
	
	# Disable collision with enemies
	user_data.hurtbox.set_collision_layer_bit(Globals.CollisionLayers.PLAYER_HURTBOX, false)
	
	_current_time = 5.0
	
	# Enable input processing after timer
	(persistant_state as Node).set_process_unhandled_key_input(false)
	yield(get_tree().create_timer(INPUT_TIMER), 'timeout')
	(persistant_state as Node).set_process_unhandled_key_input(true)

func cleanup() -> void:
	persistant_state.modulate = Color.white
	
	# Enable collision with enemies
	user_data.hurtbox.set_collision_layer_bit(Globals.CollisionLayers.PLAYER_HURTBOX, true)

func physics_main(delta: float):
	var input_vector : Vector2 = persistant_state.input_vector
	var velocity : Vector2
	
	if input_vector.x:
		velocity = persistant_state.update_velocity(delta)
	else:
		velocity = (persistant_state as Actor).velocity
		
		if Math.is_almost_zero(velocity.x):
			velocity.x = 0
		else:
			velocity.x = lerp(velocity.x, 0, delta * 10)
		
		(persistant_state as Actor).velocity.x = velocity.x
	
	# Change state when time runs out
	if is_zero_approx(_current_time):
		return persistant_state.STATE_IDLE
	
	_current_time = max(_current_time - delta, 0)

func process_main(_delta):
	persistant_state.change_animation_state('Idle')
