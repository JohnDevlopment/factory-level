extends State

export(float, 0.1, 2.0, 0.1) var deacceleration_time : float = 1
export(float, 0.1, 2.0, 0.1) var delay : float = 1

var _substate : int
var _destination : float

func _setup() -> void:
	user_data.frames.play('Idle')
	_substate = 0
	yield(get_tree().create_timer(delay), 'timeout')
	user_data.frames.play('Move', true)
	_substate += 1

func physics_main(delta: float):
	match _substate:
		1:
			var root : Enemy = persistant_state
			
			# Move-back speed no smaller than
			if abs(user_data.charge_speed) < 70:
				root.velocity.x = 35.0 * -root.direction.x
			else:
				root.velocity.x = (user_data.charge_speed / 2.0) * -1.0
			
			# Initialize interpolator
			var cintp := user_data.cintp as CubicInterpolator
			cintp.start_interpolation(
				root.velocity.x,
				0,
				deacceleration_time
			)
			_substate += 1
			_destination = (user_data.initial_position as Vector2).x
		2:
			# Advance state when near destination
			var distance = persistant_state.global_position.x - _destination
			if abs(distance) < 9.0:
				_substate += 1
		3:
			# Interpolate velocity to zero
			var cintp := user_data.cintp as CubicInterpolator
			var value = cintp.step(delta)
			assert(value is float)
			persistant_state.velocity.x = value
			if cintp.finished:
				_substate += 1
		4:
			(persistant_state as Enemy).global_position.x = _destination
			return persistant_state.STATE_COOLDOWN
