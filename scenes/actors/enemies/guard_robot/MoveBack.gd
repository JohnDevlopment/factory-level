extends State

func _setup() -> void:
	persistant_state.direction.x = -(persistant_state.direction.x)
	user_data.frames.play('Move', true)

func cleanup() -> void:
	pass

# warning-ignore:unused_argument
func physics_main(delta: float):
	var root : Actor = persistant_state
	var velocity : Vector2 = root.velocity
	if Math.is_almost_equal(root.global_position.x, user_data.initial_position.x, 0.003):
		if Math.is_almost_zero(velocity.x):
			return root.STATE_COOLDOWN
		else:
			velocity.x = lerp(velocity.x, 0, delta * 30)
	else:
		velocity.x = lerp(velocity.x, 50.0 * root.direction.x, delta * 10)
	
	root.velocity = velocity
