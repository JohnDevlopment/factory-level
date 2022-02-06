extends State

var _stopping := false

func _setup() -> void:
	user_data.frames.play('Idle', false)
	_stopping = false
	yield(get_tree().create_timer(user_data.delay), 'timeout')
	user_data.frames.play('Move', true)

func physics_main(delta: float):
	var root : Actor = persistant_state
	var velocity : Vector2 = root.velocity
	
	if not is_zero_approx(user_data.delay):
		user_data.delay -= delta
		return
	
	if _stopping:
		if abs(velocity.x) < 0.01:
			velocity.x = 0
			return root.STATE_COOLDOWN
		else:
			# Interpolate speed to zero
			velocity.x = lerp(velocity.x, 0, delta * 30)
	else:
		# Change substate if very close to the initial position
		if Math.is_almost_equal(root.global_position.x, user_data.initial_position.x, 0.01):
			_stopping = true
		
		velocity.x = lerp(velocity.x, 50.0 * -root.direction.x, delta * 10)
	
	root.velocity = velocity
