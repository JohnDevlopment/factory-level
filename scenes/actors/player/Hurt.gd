extends State

var INPUT_TIMER := 0.5

var _current_time : float

func _setup() -> void:
	# Disable collision with enemies
	user_data.hurtbox.set_collision_layer_bit(Globals.CollisionLayers.PLAYER_HURTBOX, false)
	
	_current_time = INPUT_TIMER
	
	# Disable input processing
	(persistant_state as Node).set_process_unhandled_key_input(false)
	persistant_state.input_vector.x = 0
	
	persistant_state.change_animation_state('Hurt')

func cleanup() -> void:
	# Enable collision with enemies
	user_data.hurtbox.set_collision_layer_bit(Globals.CollisionLayers.PLAYER_HURTBOX, true)
	
	# Reenable input processing
	(persistant_state as Node).set_process_unhandled_key_input(true)

func physics_main(delta: float):
	var root : Actor = persistant_state
	
	var friction : float = 10 if root._on_floor else 3
	root.velocity.x = lerp(root.velocity.x, 0, delta * friction)
	
	if root._on_floor:
		# Change state when time runs out
		if is_zero_approx(_current_time):
			return persistant_state.STATE_IDLE
		
		_current_time = max(_current_time - delta, 0)

func process_main(_delta: float):
	if persistant_state._on_floor:
		persistant_state.change_animation_state('Idle')
